prelude
import Leanbin.Init.Meta.Tactic
import Leanbin.Init.Meta.Format
import Leanbin.Init.Function

/-- This is a kind attached to an argument of a congruence lemma that tells the simplifier how to fill it in.
- `fixed`: It is a parameter for the congruence lemma, the parameter occurs in the left and right hand sides.
  For example the α in the congruence generated from `f: Π {α : Type} α → α`.
- `fixed_no_param`: It is not a parameter for the congruence lemma, the lemma was specialized for this parameter.
  This only happens if the parameter is a subsingleton/proposition, and other parameters depend on it.
- `eq`: The lemma contains three parameters for this kind of argument `a_i`, `b_i` and `(eq_i : a_i = b_i)`.
  `a_i` and `b_i` represent the left and right hand sides, and `eq_i` is a proof for their equality.
  For example the second argument in `f: Π {α : Type}, α → α`.
- `cast`: corresponds to arguments that are subsingletons/propositions.
  For example the `p` in the congruence generated from `f : Π (x y : ℕ) (p: x < y), ℕ`.
- `heq` The lemma contains three parameters for this kind of argument `a_i`, `b_i` and `(eq_i : a_i == b_i)`.
   `a_i` and `b_i` represent the left and right hand sides, and eq_i is a proof for their heterogeneous equality.
-/
inductive CongrArgKind
  | fixed
  | fixed_no_param
  | Eq
  | cast
  | HEq

namespace CongrArgKind

def toString : CongrArgKind → Stringₓ
  | fixed => "fixed"
  | fixed_no_param => "fixed_no_param"
  | Eq => "eq"
  | cast => "cast"
  | HEq => "heq"

instance : HasRepr CongrArgKind :=
  ⟨toString⟩

unsafe instance : has_to_format CongrArgKind :=
  ⟨fun x => toString x⟩

end CongrArgKind

/--
A congruence lemma is a proof that two terms are equal using a congruence proof generated by `mk_congr_lemma_simp` and friends.
See the docstring for `mk_congr_lemma_simp` and `congr_arg_kind` for more information.
The conclusion is prepended by a set of arguments. `arg_kinds` gives a suggestion of how that argument should be filled in using a simplifier.
  -/
unsafe structure congr_lemma where
  type : expr
  proof : expr
  arg_kinds : List CongrArgKind

namespace Tactic

/-- `mk_congr_lemma_simp f nargs md`
creates a congruence lemma for the simplifier for the given function argument `f`.
If `nargs` is not none, then it tries to create a lemma for an application of arity `nargs`.
If `nargs` is none then the number of arguments will be guessed from the type signature of `f`.

That is, given `f : Π {α β γ δ : Type}, α → β → γ → δ` and `nargs = some 6`, we get a congruence lemma:
``` lean
{ type := ∀ (α β γ δ : Type), ∀ (a₁ a₂ : α), a₁ = a₂ → ∀ (b₁ b₂ : β), b₁ = b₂ → f a₁ b₁ = f a₂ b₂
, proof := ...
, arg_kinds := [fixed, fixed, fixed, fixed, eq,eq]
}
```
See the docstrings for the cases of `congr_arg_kind` for more detail on how `arg_kinds` are chosen.
The system chooses the `arg_kinds` depending on what the other arguments depend on and whether the arguments have subsingleton types.

Note that the number of arguments that `proof` takes can be inferred from `arg_kinds`: `arg_kinds.sum (fixed,cast ↦ 1 | eq,heq ↦ 3 | fixed_no_param ↦ 0)`.

From `congr_lemma.cpp`:
> Create a congruence lemma that is useful for the simplifier.
> In this kind of lemma, if the i-th argument is a Cast argument, then the lemma
> contains an input a_i representing the i-th argument in the left-hand-side, and
> it appears with a cast (e.g., eq.drec ... a_i ...) in the right-hand-side.
> The idea is that the right-hand-side of this lemma "tells" the simplifier
> how the resulting term looks like.
-/
unsafe axiom mk_congr_lemma_simp (f : expr) (nargs : Option Nat := none) (md := semireducible) : tactic congr_lemma

/-- Create a specialized theorem using (a prefix of) the arguments of the given application.

An example of usage can be found in `tests/lean/simp_subsingleton.lean`.
For more information on specialization see the comment in the method body for `get_specialization_prefix_size` in `src/library/fun_info.cpp`.
 -/
unsafe axiom mk_specialized_congr_lemma_simp (h : expr) (md : transparency := semireducible) : tactic congr_lemma

/-- Similar to `mk_congr_lemma_simp`, this will make a `congr_lemma` object.
The difference is that for each `congr_arg_kind.cast` argument, two proof arguments are generated.

Consider some function `f : Π (x : ℕ) (p : x < 4), ℕ`.
- `mk_congr_simp` will produce a congruence lemma with type `∀ (x x_1 : ℕ) (e_1 : x = x_1) (p : x < 4), f x p = f x_1 _`.
- `mk_congr` will produce a congruence lemma with type `∀ (x x_1 : ℕ) (e_1 : x = x_1) (p : x < 4) (p_1 : x_1 < 4), f x p = f x_1 p_1`.

From `congr_lemma.cpp`:
> Create a congruence lemma for the congruence closure module.
> In this kind of lemma, if the i-th argument is a Cast argument, then the lemma
> contains two inputs a_i and b_i representing the i-th argument in the left-hand-side and
> right-hand-side.
> This lemma is based on the congruence lemma for the simplifier.
> It uses subsinglenton elimination to show that the congr-simp lemma right-hand-side
> is equal to the right-hand-side of this lemma.
 -/
unsafe axiom mk_congr_lemma (h : expr) (nargs : Option Nat := none) (md := semireducible) : tactic congr_lemma

/-- Create a specialized theorem using (a prefix of) the arguments of the given application.

For more information on specialization see the comment in the method body for `get_specialization_prefix_size` in `src/library/fun_info.cpp`.
-/
unsafe axiom mk_specialized_congr_lemma (h : expr) (md := semireducible) : tactic congr_lemma

/-- Make a congruence lemma using hetrogeneous equality `heq` instead of `eq`.
For example `mk_hcongr_lemma (f : Π (α : ℕ → Type) (n:ℕ) (b:α n), ℕ` )` will make

``` lean
{ type := ∀ α α', α = α' → ∀ n n', n = n' → ∀ (b : α n) (b' : α' n'), b == b' → f α n b == f α' n' b'
, proof := ...
, arg_kinds := [eq,eq,heq]
}
```

(Using merely `mk_congr_lemma` instead will produce `[fixed,fixed,eq]` instaed.)
-/
unsafe axiom mk_hcongr_lemma (h : expr) (nargs : Option Nat := none) (md := semireducible) : tactic congr_lemma

end Tactic

