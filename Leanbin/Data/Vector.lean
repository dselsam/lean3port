prelude
import Leanbin.Init.Data.List.Default
import Leanbin.Init.Data.Subtype.Default
import Leanbin.Init.Meta.Interactive
import Leanbin.Init.Data.Fin.Default

universe u v w

def Vector (α : Type u) (n : ℕ) :=
  { l : List α // l.length = n }

namespace Vector

variable {α : Type u} {β : Type v} {φ : Type w}

variable {n : ℕ}

instance [DecidableEq α] : DecidableEq (Vector α n) := by
  unfold Vector
  infer_instance

@[matchPattern]
def nil : Vector α 0 :=
  ⟨[], rfl⟩

@[matchPattern]
def cons : α → Vector α n → Vector α (Nat.succ n)
  | a, ⟨v, h⟩ => ⟨a :: v, congr_argₓ Nat.succ h⟩

@[reducible]
def length (v : Vector α n) : ℕ :=
  n

open Nat

def head : Vector α (Nat.succ n) → α
  | ⟨[], h⟩ => by
    contradiction
  | ⟨a :: v, h⟩ => a

theorem head_cons (a : α) : ∀ v : Vector α n, head (cons a v) = a
  | ⟨l, h⟩ => rfl

def tail : Vector α n → Vector α (n - 1)
  | ⟨[], h⟩ => ⟨[], congr_argₓ pred h⟩
  | ⟨a :: v, h⟩ => ⟨v, congr_argₓ pred h⟩

theorem tail_cons (a : α) : ∀ v : Vector α n, tail (cons a v) = v
  | ⟨l, h⟩ => rfl

@[simp]
theorem cons_head_tail : ∀ v : Vector α (succ n), cons (head v) (tail v) = v
  | ⟨[], h⟩ => by
    contradiction
  | ⟨a :: v, h⟩ => rfl

def to_list (v : Vector α n) : List α :=
  v.1

def nth : ∀ v : Vector α n, Finₓ n → α
  | ⟨l, h⟩, i =>
    l.nth_le i.1
      (by
        rw [h] <;> exact i.2)

def append {n m : Nat} : Vector α n → Vector α m → Vector α (n + m)
  | ⟨l₁, h₁⟩, ⟨l₂, h₂⟩ =>
    ⟨l₁ ++ l₂, by
      simp [*]⟩

@[elab_as_eliminator]
def elim {α} {C : ∀ {n}, Vector α n → Sort u} (H : ∀ l : List α, C ⟨l, rfl⟩) {n : Nat} : ∀ v : Vector α n, C v
  | ⟨l, h⟩ =>
    match n, h with
    | _, rfl => H l

def map (f : α → β) : Vector α n → Vector β n
  | ⟨l, h⟩ =>
    ⟨List.map f l, by
      simp [*]⟩

@[simp]
theorem map_nil (f : α → β) : map f nil = nil :=
  rfl

theorem map_cons (f : α → β) (a : α) : ∀ v : Vector α n, map f (cons a v) = cons (f a) (map f v)
  | ⟨l, h⟩ => rfl

def map₂ (f : α → β → φ) : Vector α n → Vector β n → Vector φ n
  | ⟨x, _⟩, ⟨y, _⟩ =>
    ⟨List.map₂ₓ f x y, by
      simp [*]⟩

def repeat (a : α) (n : ℕ) : Vector α n :=
  ⟨List.repeat a n, List.length_repeat a n⟩

def drop (i : ℕ) : Vector α n → Vector α (n - i)
  | ⟨l, p⟩ =>
    ⟨List.dropₓ i l, by
      simp [*]⟩

def take (i : ℕ) : Vector α n → Vector α (min i n)
  | ⟨l, p⟩ =>
    ⟨List.takeₓ i l, by
      simp [*]⟩

def remove_nth (i : Finₓ n) : Vector α n → Vector α (n - 1)
  | ⟨l, p⟩ =>
    ⟨List.removeNthₓ l i.1, by
      rw [l.length_remove_nth i.1] <;> rw [p] <;> exact i.2⟩

def of_fn : ∀ {n}, (Finₓ n → α) → Vector α n
  | 0, f => nil
  | n + 1, f => cons (f 0) (of_fn fun i => f i.succ)

section Accum

open Prod

variable {σ : Type}

def map_accumr (f : α → σ → σ × β) : Vector α n → σ → σ × Vector β n
  | ⟨x, px⟩, c =>
    let res := List.mapAccumr f x c
    ⟨res.1, res.2, by
      simp [*]⟩

def map_accumr₂ {α β σ φ : Type} (f : α → β → σ → σ × φ) : Vector α n → Vector β n → σ → σ × Vector φ n
  | ⟨x, px⟩, ⟨y, py⟩, c =>
    let res := List.mapAccumr₂ f x y c
    ⟨res.1, res.2, by
      simp [*]⟩

end Accum

protected theorem Eq {n : ℕ} : ∀ a1 a2 : Vector α n, to_list a1 = to_list a2 → a1 = a2
  | ⟨x, h1⟩, ⟨_, h2⟩, rfl => rfl

protected theorem eq_nil (v : Vector α 0) : v = nil :=
  v.eq nil (List.eq_nil_of_length_eq_zero v.2)

@[simp]
theorem to_list_mk (v : List α) (P : List.length v = n) : to_list (Subtype.mk v P) = v :=
  rfl

@[simp]
theorem to_list_nil : to_list nil = @List.nil α :=
  rfl

@[simp]
theorem to_list_length (v : Vector α n) : (to_list v).length = n :=
  v.2

@[simp]
theorem to_list_cons (a : α) (v : Vector α n) : to_list (cons a v) = a :: to_list v := by
  cases v
  rfl

@[simp]
theorem to_list_append {n m : Nat} (v : Vector α n) (w : Vector α m) : to_list (append v w) = to_list v ++ to_list w :=
  by
  cases v
  cases w
  rfl

@[simp]
theorem to_list_drop {n m : ℕ} (v : Vector α m) : to_list (drop n v) = List.dropₓ n (to_list v) := by
  cases v
  rfl

@[simp]
theorem to_list_take {n m : ℕ} (v : Vector α m) : to_list (take n v) = List.takeₓ n (to_list v) := by
  cases v
  rfl

end Vector

