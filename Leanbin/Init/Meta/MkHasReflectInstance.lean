prelude
import Leanbin.Init.Meta.RecUtil

namespace Tactic

open Expr Environment List

private unsafe def get_has_reflect_type_name : tactic Name :=
  (do
      let app (const n ls) t ← target
      when (n ≠ `has_reflect) failed
      let const I ls ← return (get_app_fn t)
      return I) <|>
    fail "mk_has_reflect_instance tactic failed, target type is expected to be of the form (has_reflect ...)"

private unsafe def mk_has_reflect_instance_for (a : expr) : tactic expr := do
  let t ← infer_type a
  do
    let m ← mk_app `reflected [a]
    let inst ←
      mk_instance m <|> do
          let f ← pp t
          fail
              (to_fmt "mk_has_reflect_instance failed, failed to generate instance for" ++
                format.nest 2 (format.line ++ f))
    mk_app `reflect [a, inst]

private unsafe def mk_reflect : Name → Name → List Name → Nat → tactic (List expr)
  | I_name, F_name, [], num_rec => return []
  | I_name, F_name, fname :: fnames, num_rec => do
    let field ← get_local fname
    let rec ← is_type_app_of field I_name
    let quote ← if rec then mk_brec_on_rec_value F_name num_rec else mk_has_reflect_instance_for field
    let quotes ← mk_reflect I_name F_name fnames (if rec then num_rec + 1 else num_rec)
    return (quote :: quotes)

private unsafe def has_reflect_case (I_name F_name : Name) (field_names : List Name) : tactic Unit := do
  let field_quotes ← mk_reflect I_name F_name field_names 0
  let quote.1 (reflected (%%ₓfn)) ← target
  let fn := field_names.foldl (fun fn _ => expr.app_fn fn) fn
  let quote ← mk_app `reflected [fn] >>= mk_instance
  let quote ←
    field_quotes.mfoldl (fun quote fquote => to_expr (pquote.1 (reflected.subst (%%ₓquote) (%%ₓfquote)))) quote
  exact quote

private unsafe def for_each_has_reflect_goal : Name → Name → List (List Name) → tactic Unit
  | I_name, F_name, [] => done <|> fail "mk_has_reflect_instance failed, unexpected number of cases"
  | I_name, F_name, ns :: nss => do
    solve1 (has_reflect_case I_name F_name ns)
    for_each_has_reflect_goal I_name F_name nss

/-- Solves a goal of the form `has_reflect α` where α is an inductive type.
    Needs to synthesize a `reflected` instance for each inductive parameter type of α
    and for each constructor parameter of α. -/
unsafe def mk_has_reflect_instance : tactic Unit := do
  let I_name ← get_has_reflect_type_name
  let env ← get_env
  let v_name : Name ← return `_v
  let F_name : Name ← return `_F
  guardₓ (env.inductive_num_indices I_name = 0) <|>
      fail "mk_has_reflect_instance failed, indexed families are currently not supported"
  if is_recursive env I_name then
      intro `_v >>= fun x => induction x [v_name, F_name] (some $ I_name <.> "brec_on") >> return ()
    else intro v_name >> return ()
  let arg_names : List (List Name) ← mk_constructors_arg_names I_name `_p
  get_local v_name >>= fun v => cases v (join arg_names)
  for_each_has_reflect_goal I_name F_name arg_names

end Tactic

