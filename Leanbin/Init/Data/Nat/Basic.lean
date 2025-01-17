prelude
import Leanbin.Init.Logic

namespace Nat

inductive less_than_or_equal (a : ℕ) : ℕ → Prop
  | refl : less_than_or_equal a
  | step : ∀ {b}, less_than_or_equal b → less_than_or_equal (succ b)

instance : LE ℕ :=
  ⟨Nat.LessThanOrEqual⟩

@[reducible]
protected def le (n m : ℕ) :=
  Nat.LessThanOrEqual n m

@[reducible]
protected def lt (n m : ℕ) :=
  Nat.LessThanOrEqual (succ n) m

instance : LT ℕ :=
  ⟨Nat.Lt⟩

def pred : ℕ → ℕ
  | 0 => 0
  | a + 1 => a

protected def sub : ℕ → ℕ → ℕ
  | a, 0 => a
  | a, b + 1 => pred (sub a b)

protected def mul : Nat → Nat → Nat
  | a, 0 => 0
  | a, b + 1 => mul a b + a

instance : Sub ℕ :=
  ⟨Nat.sub⟩

instance : Mul ℕ :=
  ⟨Nat.mul⟩

instance : HasDvd ℕ :=
  HasDvd.mk fun a b => ∃ c, b = a * c

instance : DecidableEq ℕ
  | zero, zero => is_true rfl
  | succ x, zero => is_false fun h => Nat.noConfusion h
  | zero, succ y => is_false fun h => Nat.noConfusion h
  | succ x, succ y =>
    match DecidableEq x y with
    | is_true xeqy => is_true (xeqy ▸ Eq.refl (succ x))
    | is_false xney => is_false fun h => Nat.noConfusion h fun xeqy => absurd xeqy xney

def repeat.{u} {α : Type u} (f : ℕ → α → α) : ℕ → α → α
  | 0, a => a
  | succ n, a => f n (repeat n a)

instance : Inhabited ℕ :=
  ⟨Nat.zero⟩

@[simp]
theorem nat_zero_eq_zero : Nat.zero = 0 :=
  rfl

@[refl]
protected theorem le_refl (a : ℕ) : a ≤ a :=
  less_than_or_equal.refl

theorem le_succ (n : ℕ) : n ≤ succ n :=
  less_than_or_equal.step (Nat.le_reflₓ n)

theorem succ_le_succ {n m : ℕ} : n ≤ m → succ n ≤ succ m := fun h =>
  less_than_or_equal.rec (Nat.le_reflₓ (succ n)) (fun a b => less_than_or_equal.step) h

protected theorem zero_le : ∀ n : ℕ, 0 ≤ n
  | 0 => Nat.le_reflₓ 0
  | n + 1 => less_than_or_equal.step (zero_le n)

theorem zero_lt_succ (n : ℕ) : 0 < succ n :=
  succ_le_succ n.zero_le

theorem succ_pos (n : ℕ) : 0 < succ n :=
  zero_lt_succ n

theorem not_succ_le_zero : ∀ n : ℕ, succ n ≤ 0 → False :=
  fun.

protected theorem not_lt_zero (a : ℕ) : ¬a < 0 :=
  not_succ_le_zero a

theorem pred_le_pred {n m : ℕ} : n ≤ m → pred n ≤ pred m := fun h =>
  less_than_or_equal.rec_on h (Nat.le_reflₓ (pred n)) fun n =>
    Nat.rec (fun a b => b) (fun a b c => less_than_or_equal.step) n

theorem le_of_succ_le_succ {n m : ℕ} : succ n ≤ succ m → n ≤ m :=
  pred_le_pred

instance decidable_le : ∀ a b : ℕ, Decidable (a ≤ b)
  | 0, b => is_true b.zero_le
  | a + 1, 0 => is_false (not_succ_le_zero a)
  | a + 1, b + 1 =>
    match decidable_le a b with
    | is_true h => is_true (succ_le_succ h)
    | is_false h => is_false fun a => h (le_of_succ_le_succ a)

instance decidable_lt : ∀ a b : ℕ, Decidable (a < b) := fun a b => Nat.decidableLe (succ a) b

protected theorem eq_or_lt_of_le {a b : ℕ} (h : a ≤ b) : a = b ∨ a < b :=
  less_than_or_equal.cases_on h (Or.inl rfl) fun n h => Or.inr (succ_le_succ h)

theorem lt_succ_of_le {a b : ℕ} : a ≤ b → a < succ b :=
  succ_le_succ

@[simp]
theorem succ_sub_succ_eq_sub (a b : ℕ) : succ a - succ b = a - b :=
  Nat.recOn b (show succ a - succ zero = a - zero from Eq.refl (succ a - succ zero)) fun b => congr_argₓ pred

theorem not_succ_le_self : ∀ n : ℕ, ¬succ n ≤ n := fun n =>
  Nat.rec (not_succ_le_zero 0) (fun a b c => b (le_of_succ_le_succ c)) n

protected theorem lt_irrefl (n : ℕ) : ¬n < n :=
  not_succ_le_self n

protected theorem le_trans {n m k : ℕ} (h1 : n ≤ m) : m ≤ k → n ≤ k :=
  less_than_or_equal.rec h1 fun p h2 => less_than_or_equal.step

theorem pred_le : ∀ n : ℕ, pred n ≤ n
  | 0 => less_than_or_equal.refl
  | succ a => less_than_or_equal.step less_than_or_equal.refl

theorem pred_lt : ∀ {n : ℕ}, n ≠ 0 → pred n < n
  | 0, h => absurd rfl h
  | succ a, h => lt_succ_of_le less_than_or_equal.refl

protected theorem sub_le (a b : ℕ) : a - b ≤ a :=
  Nat.recOn b (Nat.le_reflₓ (a - 0)) fun b₁ => Nat.le_transₓ (pred_le (a - b₁))

protected theorem sub_lt : ∀ {a b : ℕ}, 0 < a → 0 < b → a - b < a
  | 0, b, h1, h2 => absurd h1 (Nat.lt_irreflₓ 0)
  | a + 1, 0, h1, h2 => absurd h2 (Nat.lt_irreflₓ 0)
  | a + 1, b + 1, h1, h2 => Eq.symm (succ_sub_succ_eq_sub a b) ▸ show a - b < succ a from lt_succ_of_le (a.sub_le b)

protected theorem lt_of_lt_of_le {n m k : ℕ} : n < m → m ≤ k → n < k :=
  Nat.le_transₓ

protected theorem zero_add : ∀ n : ℕ, 0 + n = n
  | 0 => rfl
  | n + 1 => congr_argₓ succ (zero_add n)

theorem succ_add : ∀ n m : ℕ, succ n + m = succ (n + m)
  | n, 0 => rfl
  | n, m + 1 => congr_argₓ succ (succ_add n m)

theorem add_succ (n m : ℕ) : n + succ m = succ (n + m) :=
  rfl

protected theorem add_zero (n : ℕ) : n + 0 = n :=
  rfl

theorem add_one (n : ℕ) : n + 1 = succ n :=
  rfl

theorem succ_eq_add_one (n : ℕ) : succ n = n + 1 :=
  rfl

protected theorem bit0_succ_eq (n : ℕ) : bit0 (succ n) = succ (succ (bit0 n)) :=
  show succ (succ n + n) = succ (succ (n + n)) from congr_argₓ succ (succ_add n n)

protected theorem zero_lt_bit0 : ∀ {n : Nat}, n ≠ 0 → 0 < bit0 n
  | 0, h => absurd rfl h
  | succ n, h =>
    calc
      0 < succ (succ (bit0 n)) := zero_lt_succ _
      _ = bit0 (succ n) := (Nat.bit0_succ_eq n).symm
      

protected theorem zero_lt_bit1 (n : Nat) : 0 < bit1 n :=
  zero_lt_succ _

protected theorem bit0_ne_zero : ∀ {n : ℕ}, n ≠ 0 → bit0 n ≠ 0
  | 0, h => absurd rfl h
  | n + 1, h =>
    suffices n + 1 + (n + 1) ≠ 0 from this
    suffices succ (n + 1 + n) ≠ 0 from this
    fun h => Nat.noConfusion h

protected theorem bit1_ne_zero (n : ℕ) : bit1 n ≠ 0 :=
  show succ (n + n) ≠ 0 from fun h => Nat.noConfusion h

end Nat

