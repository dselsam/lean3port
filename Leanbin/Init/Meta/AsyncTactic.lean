prelude
import Leanbin.Init.Meta.Tactic
import Leanbin.Init.Meta.Interactive

namespace Tactic

private unsafe def report {α} (s : tactic_state) : Option (Unit → format) → α
  | some fmt => undefined_core $ format.to_string $ fmt () ++ format.line ++ to_fmt s
  | none => undefined_core "silent failure"

private unsafe def run_or_fail {α} (s : tactic_state) (tac : tactic α) : α :=
  match tac s with
  | result.success a s => a
  | result.exception fmt _ s' => report s' fmt

unsafe def run_async {α : Type} (tac : tactic α) : tactic (task α) := do
  let s ← read
  return $
      task.delay $ fun _ =>
        match tac s with
        | result.success a s => a
        | result.exception fmt _ s' => report s' fmt

unsafe def prove_goal_async (tac : tactic Unit) : tactic Unit := do
  let ctx ← local_context
  revert_lst ctx
  let tgt ← target
  let tgt ← instantiate_mvars tgt
  let env ← get_env
  let tgt ← return $ env.unfold_untrusted_macros tgt
  when tgt.has_meta_var (fail "goal contains metavariables")
  let params ← return tgt.collect_univ_params
  let lemma_name ← new_aux_decl_name
  let proof ←
    run_async do
        let goal_meta ← mk_meta_var tgt
        set_goals [goal_meta]
        ctx.mmap' fun c => intro c.local_pp_name
        tac
        let proof ← instantiate_mvars goal_meta
        let proof ← return $ env.unfold_untrusted_macros proof
        when proof.has_meta_var $ fail "async proof failed: contains metavariables"
        return proof
  add_decl $ declaration.thm lemma_name params tgt proof
  exact (expr.const lemma_name (params.map level.param))

namespace Interactive

open Interactive.Types

/-- Proves the first goal asynchronously as a separate lemma. -/
unsafe def async (tac : itactic) : tactic Unit :=
  prove_goal_async tac

end Interactive

end Tactic

