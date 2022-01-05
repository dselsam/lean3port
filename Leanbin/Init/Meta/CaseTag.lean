prelude
import Leanbin.Init.Meta.Tactic

/-!
# Case tags

Case tags are an internal mechanism used by certain tactics to communicate with
each other. They are generated by the tactics `cases`, `induction` and
`with_cases` ('cases-like tactics'), which generate goals corresponding to the
'cases' of an inductive hypothesis. Each of these goals carries a case tag. They
are consumed by the `case` tactic, which focuses on one of these cases. Their
purpose is twofold:

1. Give intuitive names to case goals. For example, when performing induction on
   a natural number, two cases are generated: one tagged with `nat.zero` and
   one tagged with `nat.succ`. Users can then focus on e.g. the second goal with
   `case succ {...}`.
2. Communicate which new hypotheses were introduced by the cases-like tactic
   that generated the goal. For example, when performing induction on a
   `list α`, the `cons` case introduces two hypotheses corresponding to the two
   arguments of the `cons` constructor. `case` allows users to name these with
   `case cons : x xs {...}`. To perform this renaming, `case` needs to know
   which hypotheses to rename; this information is contained in the case tag for
   the `cons` goal.

## Module contents

This module defines

1. what a case tag is (see `case_tag`);
2. how to render a `case_tag` as a list of names (see `render`);
3. how to parse  a `case_tag` from a list of names (see `parse`);
4. how to match a `case_tag` with a sequence of names given by the user
   (see `match_tag`).
-/


namespace Tactic

namespace Interactive

/-- A case tag carries the following information:

1. A list of names identifying the case ('case names'). This is usually a list
   of constructor names, one for each case split that was performed. For
   example, the sequence of tactics `cases n; cases xs`, where `n` is a natural
   number and `xs` is a list, will generate four cases tagged as follows:

   ```
   nat.zero, list.nil
   nat.zero, list.cons
   nat.succ, list.nil
   nat.succ, list.cons
   ```

   Note: In the case tag, the case names are stored in reverse order. Thus, the
   case names of the first case tag would be `list.nil, nat.zero`. This is
   because when printing a goal tag (as part of a goal state), Lean prints all
   non-internal names in reverse order.

2. Information about the arguments introduced by the cases-like tactic.
   Different tactics work slightly different in this regard:

   1. The `with_cases` tactic generates goals where the target quantifies over
      any added hypotheses. For example, `with_cases { cases xs }`, where `xs`
      is a `list α`, will generate a target of the form `α → list α → ...` in
      the `cons` case, where the two arguments correspond to the two arguments
      of the `cons` constructor. Goals of this form are tagged with a `pi` case
      tag (since the target is a pi type). In addition to the case names, it
      contains a natural number, `num_arguments`, which specifies how many of
      the arguments that the target quantifies over were introduced by
      `with_cases`.

      For example, given `n : ℕ` and `xs : list α`, the fourth goal generated by
      `with_cases { cases n; induction xs }` has this form:

      ```
      ...
      ⊢ ℕ → α → ∀ (xs' : list α), P xs' → ...
      ```

      The corresponding case tag is

      ```
      pi [`list.cons, `nat.succ] 4
      ```

      since the first four arguments of the target were introduced by
      `with_cases {...}`.

   2. The `cases` and `induction` tactics do not add arguments to the target,
      but rather introduce them as hypotheses in the local context. Goals of
      this form are tagged with a `hyps` case tag. In addition to the case
      names, it contains a list of *unique* names of the hypotheses that were
      introduced.

      For example, given `xs : list α`, the second goal generated by
      `induction xs` has this form:

      ```
      ...
      x : α
      xs' : list α
      ih_xs' : P xs'
      ⊢ ...
      ```

      The corresponding goal tag is

      ```
      hyps [`list.cons] [`<x>, `<xs'>, `<ih_xs'>]
      ```

      where ````<h>``` denotes the unique name of a hypothesis `h`.

      Note: Many tactics do not preserve the unique names of hypotheses
      (particularly those tactics that use `revert`). Therefore, a `hyps` case
      tag is only guaranteed to be valid directly after it was generated.
-/
inductive case_tag
  | pi (names : List Name) (num_arguments : ℕ)
  | hyps (names : List Name) (arguments : List Name)

open CaseTag

section

open Format

protected unsafe def case_tag.to_format : case_tag → format
  | pi names num_arguments =>
    join ["(pi ", group $ nest 4 $ join $ List.intersperse line [names.to_format, format.of_nat num_arguments], ")"]
  | hyps names arguments =>
    join ["(hyps ", group $ nest 6 $ join $ List.intersperse line [names.to_format, arguments.to_format], ")"]

end

protected def case_tag.repr : case_tag → Stringₓ
  | pi names num_arguments => "(pi " ++ names.repr ++ " " ++ num_arguments.repr ++ ")"
  | hyps names arguments => "(hyps " ++ names.repr ++ " " ++ arguments.repr ++ ")"

protected def case_tag.to_string : case_tag → Stringₓ
  | pi names num_arguments => "(pi " ++ names.to_string ++ " " ++ toString num_arguments ++ ")"
  | hyps names arguments => "(hyps " ++ names.to_string ++ " " ++ arguments.to_string ++ ")"

namespace CaseTag

open name (mk_string mk_numeral)

unsafe instance : has_to_format case_tag :=
  ⟨case_tag.to_format⟩

instance : HasRepr case_tag :=
  ⟨case_tag.repr⟩

instance : HasToString case_tag :=
  ⟨case_tag.to_string⟩

/-- The constructor names associated with a case tag.
-/
unsafe def case_names : case_tag → List Name
  | pi ns _ => ns
  | hyps ns _ => ns

private unsafe def render_arguments (args : List Name) : List Name :=
  args.map (Name.mk_string "_arg")

/-- Renders a case tag to a goal tag (i.e. a list of names), according to the
following schema:

- A `pi` tag with names `N₀ ... Nₙ` and number of arguments `a` is rendered as
  ```
  [`_case.pi.a, N₀, ..., Nₙ]
  ```
- A `hyps` tag with names `N₀ ... Nₙ` and argument names `A₀ ... Aₘ` is rendered
  as
  ```
  [`_case.hyps, A₀._arg, ..., Aₘ._arg, N₀, ..., Nₙ]
  ```
-/
unsafe def render : case_tag → List Name
  | pi names num_arguments => mk_numeral (Unsigned.ofNat' num_arguments) `_case.pi :: names
  | hyps names arguments => `_case.hyps :: render_arguments arguments ++ names

/-- Creates a `pi` case tag from an input tag `in_tag`. The `names` of the resulting
tag are the non-internal names in `in_tag` (in the order in which they appear in
`in_tag`). `num_arguments` is the number of arguments of the resulting tag.
-/
unsafe def from_tag_pi (in_tag : tag) (num_arguments : ℕ) : case_tag :=
  pi (in_tag.filter fun n => ¬n.is_internal) num_arguments

/-- Creates a `hyps` case tag from an input tag `in_tag`. The `names` of the
resulting tag are the non-internal names in `in_tag` (in the order in which they
appear in `in_tag`). `arguments` is the list of unique hypothesis names of the
resulting tag.
-/
unsafe def from_tag_hyps (in_tag : tag) (arguments : List Name) : case_tag :=
  hyps (in_tag.filter fun n => ¬n.is_internal) arguments

private unsafe def parse_marker : Name → Option (Option Nat)
  | mk_numeral n `_case.pi => some (some n.to_nat)
  | `_case.hyps => some none
  | _ => none

private unsafe def parse_arguments : List Name → List Name × List Name
  | [] => ⟨[], []⟩
  | mk_string "_arg" n :: ns =>
    let ⟨args, rest⟩ := parse_arguments ns
    ⟨n :: args, rest⟩
  | ns => ⟨[], ns⟩

/-- Parses a case tag from the list of names produced by `render`.
-/
unsafe def parse : List Name → Option case_tag
  | [] => none
  | mk_numeral n `_case.pi :: ns => do
    guardₓ $ ns.all fun n => ¬n.is_internal
    some $ pi ns n.to_nat
  | `_case.hyps :: ns => do
    let ⟨args, ns⟩ := parse_arguments ns
    guardₓ $ ns.all fun n => ¬n.is_internal
    some $ hyps ns args
  | _ => none

/-- Indicates the result of matching a list of names against the names of a case
tag. See `match_tag`.
-/
inductive match_result
  | exact_match
  | fuzzy_match
  | no_match

open MatchResult

namespace MatchResult

/-- The 'minimum' of two match results:

- If any of the arguments is `no_match`, the result is `no_match`.
- Otherwise, if any of the arguments is `fuzzy_match`, the result is `fuzzy_match`.
- Otherwise (iff both arguments are `exact_match`), the result is `exact_match`.
-/
def combine : match_result → match_result → match_result
  | exact_match, exact_match => exact_match
  | exact_match, fuzzy_match => fuzzy_match
  | exact_match, no_match => no_match
  | fuzzy_match, no_match => no_match
  | fuzzy_match, _ => fuzzy_match
  | no_match, _ => no_match

end MatchResult

private unsafe def name_match (suffix : Name) (n : Name) : match_result :=
  if suffix = n then exact_match else if suffix.is_suffix_of n then fuzzy_match else no_match

private unsafe def names_match : List Name → List Name → match_result
  | [], [] => exact_match
  | [], _ => fuzzy_match
  | _ :: _, [] => no_match
  | n :: ns, n' :: ns' => (name_match n n').combine (names_match ns ns')

/-- Match the `names` of a case tag against a user-supplied list of names `ns`. For
this purpose, we consider the `names` in reverse order, i.e. in the order in
which they are displayed to the user. The matching then uses the following
rules:

- If `ns` is exactly the same sequence of names as `names`, this is an exact
  match.
- If `ns` is a *suffix* of `names`, this is a fuzzy match. Additionally, each of
  the names in `ns` may be a suffix of the corresponding name in `names`.
- Otherwise, we have no match.

Thus, the tag
```
nat.zero, list.nil
```
is matched by any of these tags:
```
nat.zero, list.nil (exact match)
nat.zero, nil      (fuzzy match)
zero, nil          (fuzzy match)
nil                (fuzzy match)
```
-/
unsafe def match_tag (ns : List Name) (t : case_tag) : match_result :=
  names_match ns.reverse t.case_names

end CaseTag

end Interactive

end Tactic

