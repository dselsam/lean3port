prelude
import Leanbin.Init.Data.Nat.Lemmas
import Leanbin.Init.Data.Nat.Gcd

open Nat

inductive Int : Type
  | of_nat : Nat → Int
  | neg_succ_of_nat : Nat → Int
  deriving DecidableEq

instance : Coe Nat Int :=
  ⟨Int.ofNat⟩

notation "-[1+ " n "]" => Int.negSucc n

protected def Int.reprₓ : Int → Stringₓ
  | Int.ofNat n => reprₓ n
  | Int.negSucc n => "-" ++ reprₓ (succ n)

instance : HasRepr Int :=
  ⟨Int.reprₓ⟩

instance : HasToString Int :=
  ⟨Int.reprₓ⟩

namespace Int

protected theorem coe_nat_eq (n : ℕ) : ↑n = Int.ofNat n :=
  rfl

protected def zero : ℤ :=
  of_nat 0

protected def one : ℤ :=
  of_nat 1

instance : HasZero ℤ :=
  ⟨Int.zero⟩

instance : HasOne ℤ :=
  ⟨Int.one⟩

theorem of_nat_zero : of_nat (0 : Nat) = (0 : Int) :=
  rfl

theorem of_nat_one : of_nat (1 : Nat) = (1 : Int) :=
  rfl

def neg_of_nat : ℕ → ℤ
  | 0 => 0
  | succ m => -[1+ m]

def sub_nat_nat (m n : ℕ) : ℤ :=
  match (n - m : Nat) with
  | 0 => of_nat (m - n)
  | succ k => -[1+ k]

theorem sub_nat_nat_of_sub_eq_zero {m n : ℕ} (h : n - m = 0) : sub_nat_nat m n = of_nat (m - n) := by
  unfold sub_nat_nat
  rw [h]
  unfold sub_nat_nat._match_1

theorem sub_nat_nat_of_sub_eq_succ {m n k : ℕ} (h : n - m = succ k) : sub_nat_nat m n = -[1+ k] := by
  unfold sub_nat_nat
  rw [h]
  unfold sub_nat_nat._match_1

protected def neg : ℤ → ℤ
  | of_nat n => neg_of_nat n
  | -[1+ n] => succ n

protected def add : ℤ → ℤ → ℤ
  | of_nat m, of_nat n => of_nat (m + n)
  | of_nat m, -[1+ n] => sub_nat_nat m (succ n)
  | -[1+ m], of_nat n => sub_nat_nat n (succ m)
  | -[1+ m], -[1+ n] => -[1+ succ (m + n)]

protected def mul : ℤ → ℤ → ℤ
  | of_nat m, of_nat n => of_nat (m * n)
  | of_nat m, -[1+ n] => neg_of_nat (m * succ n)
  | -[1+ m], of_nat n => neg_of_nat (succ m * n)
  | -[1+ m], -[1+ n] => of_nat (succ m * succ n)

instance : Neg ℤ :=
  ⟨Int.neg⟩

instance : Add ℤ :=
  ⟨Int.add⟩

instance : Mul ℤ :=
  ⟨Int.mul⟩

protected def sub : ℤ → ℤ → ℤ := fun m n => m + -n

instance : Sub ℤ :=
  ⟨Int.sub⟩

protected theorem neg_zero : -(0 : ℤ) = 0 :=
  rfl

theorem of_nat_add (n m : ℕ) : of_nat (n + m) = of_nat n + of_nat m :=
  rfl

theorem of_nat_mul (n m : ℕ) : of_nat (n * m) = of_nat n * of_nat m :=
  rfl

theorem of_nat_succ (n : ℕ) : of_nat (succ n) = of_nat n + 1 :=
  rfl

theorem neg_of_nat_zero : -of_nat 0 = 0 :=
  rfl

theorem neg_of_nat_of_succ (n : ℕ) : -of_nat (succ n) = -[1+ n] :=
  rfl

theorem neg_neg_of_nat_succ (n : ℕ) : - -[1+ n] = of_nat (succ n) :=
  rfl

theorem of_nat_eq_coe (n : ℕ) : of_nat n = ↑n :=
  rfl

theorem neg_succ_of_nat_coe (n : ℕ) : -[1+ n] = -↑(n + 1) :=
  rfl

protected theorem coe_nat_add (m n : ℕ) : (↑(m + n) : ℤ) = ↑m + ↑n :=
  rfl

protected theorem coe_nat_mul (m n : ℕ) : (↑(m * n) : ℤ) = ↑m * ↑n :=
  rfl

protected theorem coe_nat_zero : ↑(0 : ℕ) = (0 : ℤ) :=
  rfl

protected theorem coe_nat_one : ↑(1 : ℕ) = (1 : ℤ) :=
  rfl

protected theorem coe_nat_succ (n : ℕ) : (↑succ n : ℤ) = ↑n + 1 :=
  rfl

protected theorem coe_nat_add_out (m n : ℕ) : ↑m + ↑n = (m + n : ℤ) :=
  rfl

protected theorem coe_nat_mul_out (m n : ℕ) : ↑m * ↑n = (↑(m * n) : ℤ) :=
  rfl

protected theorem coe_nat_add_one_out (n : ℕ) : ↑n + (1 : ℤ) = ↑succ n :=
  rfl

theorem of_nat_add_of_nat (m n : Nat) : of_nat m + of_nat n = of_nat (m + n) :=
  rfl

theorem of_nat_add_neg_succ_of_nat (m n : Nat) : of_nat m + -[1+ n] = sub_nat_nat m (succ n) :=
  rfl

theorem neg_succ_of_nat_add_of_nat (m n : Nat) : -[1+ m] + of_nat n = sub_nat_nat n (succ m) :=
  rfl

theorem neg_succ_of_nat_add_neg_succ_of_nat (m n : Nat) : -[1+ m] + -[1+ n] = -[1+ succ (m + n)] :=
  rfl

theorem of_nat_mul_of_nat (m n : Nat) : of_nat m * of_nat n = of_nat (m * n) :=
  rfl

theorem of_nat_mul_neg_succ_of_nat (m n : Nat) : of_nat m * -[1+ n] = neg_of_nat (m * succ n) :=
  rfl

theorem neg_succ_of_nat_of_nat (m n : Nat) : -[1+ m] * of_nat n = neg_of_nat (succ m * n) :=
  rfl

theorem mul_neg_succ_of_nat_neg_succ_of_nat (m n : Nat) : -[1+ m] * -[1+ n] = of_nat (succ m * succ n) :=
  rfl

attribute [local simp]
  of_nat_add_of_nat of_nat_mul_of_nat neg_of_nat_zero neg_of_nat_of_succ neg_neg_of_nat_succ of_nat_add_neg_succ_of_nat neg_succ_of_nat_add_of_nat neg_succ_of_nat_add_neg_succ_of_nat of_nat_mul_neg_succ_of_nat neg_succ_of_nat_of_nat mul_neg_succ_of_nat_neg_succ_of_nat

protected theorem coe_nat_inj {m n : ℕ} (h : (↑m : ℤ) = ↑n) : m = n :=
  Int.ofNat.injₓ h

theorem of_nat_eq_of_nat_iff (m n : ℕ) : of_nat m = of_nat n ↔ m = n :=
  Iff.intro Int.ofNat.injₓ (congr_argₓ _)

protected theorem coe_nat_eq_coe_nat_iff (m n : ℕ) : (↑m : ℤ) = ↑n ↔ m = n :=
  of_nat_eq_of_nat_iff m n

theorem neg_succ_of_nat_inj_iff {m n : ℕ} : neg_succ_of_nat m = neg_succ_of_nat n ↔ m = n :=
  ⟨neg_succ_of_nat.inj, fun H => by
    simp [H]⟩

theorem neg_succ_of_nat_eq (n : ℕ) : -[1+ n] = -(n + 1) :=
  rfl

protected theorem neg_neg : ∀ a : ℤ, - -a = a
  | of_nat 0 => rfl
  | of_nat (n + 1) => rfl
  | -[1+ n] => rfl

protected theorem neg_inj {a b : ℤ} (h : -a = -b) : a = b := by
  rw [← Int.neg_neg a, ← Int.neg_neg b, h]

protected theorem sub_eq_add_neg {a b : ℤ} : a - b = a + -b :=
  rfl

theorem sub_nat_nat_elim (m n : ℕ) (P : ℕ → ℕ → ℤ → Prop) (hp : ∀ i n, P (n + i) n (of_nat i))
    (hn : ∀ i m, P m (m + i + 1) -[1+ i]) : P m n (sub_nat_nat m n) := by
  have H : ∀ k, n - m = k → P m n (Nat.casesOn k (of_nat (m - n)) fun a => -[1+ a]) := by
    intro k
    cases k
    · intro e
      cases' Nat.Le.dest (Nat.le_of_sub_eq_zeroₓ e) with k h
      rw [h.symm, Nat.add_sub_cancel_left]
      apply hp
      
    · intro heq
      have h : m ≤ n := Nat.le_of_ltₓ (Nat.lt_of_sub_eq_succₓ HEq)
      rw [Nat.sub_eq_iff_eq_addₓ h] at heq
      rw [HEq, Nat.add_comm]
      apply hn
      
  delta' sub_nat_nat
  exact H _ rfl

theorem sub_nat_nat_add_left {m n : ℕ} : sub_nat_nat (m + n) m = of_nat n := by
  dunfold sub_nat_nat
  rw [Nat.sub_eq_zero_of_leₓ]
  dunfold sub_nat_nat._match_1
  rw [Nat.add_sub_cancel_left]
  apply Nat.le_add_rightₓ

theorem sub_nat_nat_add_right {m n : ℕ} : sub_nat_nat m (m + n + 1) = neg_succ_of_nat n :=
  calc
    sub_nat_nat._match_1 m (m + n + 1) (m + n + 1 - m) = sub_nat_nat._match_1 m (m + n + 1) (m + (n + 1) - m) := by
      rw [Nat.add_assoc]
    _ = sub_nat_nat._match_1 m (m + n + 1) (n + 1) := by
      rw [Nat.add_sub_cancel_left]
    _ = neg_succ_of_nat n := rfl
    

theorem sub_nat_nat_add_add (m n k : ℕ) : sub_nat_nat (m + k) (n + k) = sub_nat_nat m n :=
  sub_nat_nat_elim m n (fun m n i => sub_nat_nat (m + k) (n + k) = i)
    (fun i n => by
      have : n + i + k = n + k + i := by
        simp [Nat.add_comm, Nat.add_left_comm]
      rw [this]
      exact sub_nat_nat_add_left)
    fun i m => by
    have : m + i + 1 + k = m + k + i + 1 := by
      simp [Nat.add_comm, Nat.add_left_comm]
    rw [this]
    exact sub_nat_nat_add_right

theorem sub_nat_nat_of_le {m n : ℕ} (h : n ≤ m) : sub_nat_nat m n = of_nat (m - n) :=
  sub_nat_nat_of_sub_eq_zero (Nat.sub_eq_zero_of_leₓ h)

theorem sub_nat_nat_of_lt {m n : ℕ} (h : m < n) : sub_nat_nat m n = -[1+ pred (n - m)] := by
  have : n - m = succ (pred (n - m)) := Eq.symm (succ_pred_eq_of_pos (Nat.sub_pos_of_ltₓ h))
  rw [sub_nat_nat_of_sub_eq_succ this]

@[simp]
def nat_abs : ℤ → ℕ
  | of_nat m => m
  | -[1+ m] => succ m

theorem nat_abs_of_nat (n : ℕ) : nat_abs (↑n) = n :=
  rfl

theorem eq_zero_of_nat_abs_eq_zero : ∀ {a : ℤ}, nat_abs a = 0 → a = 0
  | of_nat m, H => congr_argₓ of_nat H
  | -[1+ m'], H => absurd H (succ_ne_zero _)

theorem nat_abs_pos_of_ne_zero {a : ℤ} (h : a ≠ 0) : 0 < nat_abs a :=
  (Nat.eq_zero_or_posₓ _).resolve_left $ mt eq_zero_of_nat_abs_eq_zero h

theorem nat_abs_zero : nat_abs (0 : Int) = (0 : Nat) :=
  rfl

theorem nat_abs_one : nat_abs (1 : Int) = (1 : Nat) :=
  rfl

theorem nat_abs_mul_self : ∀ {a : ℤ}, ↑(nat_abs a * nat_abs a) = a * a
  | of_nat m => rfl
  | -[1+ m'] => rfl

@[simp]
theorem nat_abs_neg (a : ℤ) : nat_abs (-a) = nat_abs a := by
  cases' a with n n
  cases n <;> rfl
  rfl

theorem nat_abs_eq : ∀ a : ℤ, a = nat_abs a ∨ a = -nat_abs a
  | of_nat m => Or.inl rfl
  | -[1+ m'] => Or.inr rfl

theorem eq_coe_or_neg (a : ℤ) : ∃ n : ℕ, a = n ∨ a = -n :=
  ⟨_, nat_abs_eq a⟩

def sign : ℤ → ℤ
  | (n + 1 : ℕ) => 1
  | 0 => 0
  | -[1+ n] => -1

@[simp]
theorem sign_zero : sign 0 = 0 :=
  rfl

@[simp]
theorem sign_one : sign 1 = 1 :=
  rfl

@[simp]
theorem sign_neg_one : sign (-1) = -1 :=
  rfl

protected def div : ℤ → ℤ → ℤ
  | (m : ℕ), (n : ℕ) => of_nat (m / n)
  | (m : ℕ), -[1+ n] => -of_nat (m / succ n)
  | -[1+ m], 0 => 0
  | -[1+ m], (n + 1 : ℕ) => -[1+ m / succ n]
  | -[1+ m], -[1+ n] => of_nat (succ (m / succ n))

protected def mod : ℤ → ℤ → ℤ
  | (m : ℕ), n => (m % nat_abs n : ℕ)
  | -[1+ m], n => sub_nat_nat (nat_abs n) (succ (m % nat_abs n))

def fdiv : ℤ → ℤ → ℤ
  | 0, _ => 0
  | (m : ℕ), (n : ℕ) => of_nat (m / n)
  | (m + 1 : ℕ), -[1+ n] => -[1+ m / succ n]
  | -[1+ m], 0 => 0
  | -[1+ m], (n + 1 : ℕ) => -[1+ m / succ n]
  | -[1+ m], -[1+ n] => of_nat (succ m / succ n)

def fmod : ℤ → ℤ → ℤ
  | 0, _ => 0
  | (m : ℕ), (n : ℕ) => of_nat (m % n)
  | (m + 1 : ℕ), -[1+ n] => sub_nat_nat (m % succ n) n
  | -[1+ m], (n : ℕ) => sub_nat_nat n (succ (m % n))
  | -[1+ m], -[1+ n] => -of_nat (succ m % succ n)

def Quot : ℤ → ℤ → ℤ
  | of_nat m, of_nat n => of_nat (m / n)
  | of_nat m, -[1+ n] => -of_nat (m / succ n)
  | -[1+ m], of_nat n => -of_nat (succ m / n)
  | -[1+ m], -[1+ n] => of_nat (succ m / succ n)

def rem : ℤ → ℤ → ℤ
  | of_nat m, of_nat n => of_nat (m % n)
  | of_nat m, -[1+ n] => of_nat (m % succ n)
  | -[1+ m], of_nat n => -of_nat (succ m % n)
  | -[1+ m], -[1+ n] => -of_nat (succ m % succ n)

instance : Div ℤ :=
  ⟨Int.divₓ⟩

instance : Mod ℤ :=
  ⟨Int.modₓ⟩

def gcd (m n : ℤ) : ℕ :=
  gcd (nat_abs m) (nat_abs n)

protected theorem add_comm : ∀ a b : ℤ, a + b = b + a
  | of_nat n, of_nat m => by
    simp [Nat.add_comm]
  | of_nat n, -[1+ m] => rfl
  | -[1+ n], of_nat m => rfl
  | -[1+ n], -[1+ m] => by
    simp [Nat.add_comm]

protected theorem add_zero : ∀ a : ℤ, a + 0 = a
  | of_nat n => rfl
  | -[1+ n] => rfl

protected theorem zero_add (a : ℤ) : 0 + a = a :=
  Int.add_comm a 0 ▸ Int.add_zero a

theorem sub_nat_nat_sub {m n : ℕ} (h : n ≤ m) (k : ℕ) : sub_nat_nat (m - n) k = sub_nat_nat m (k + n) :=
  calc
    sub_nat_nat (m - n) k = sub_nat_nat (m - n + n) (k + n) := by
      rw [sub_nat_nat_add_add]
    _ = sub_nat_nat m (k + n) := by
      rw [Nat.sub_add_cancelₓ h]
    

theorem sub_nat_nat_add (m n k : ℕ) : sub_nat_nat (m + n) k = of_nat m + sub_nat_nat n k := by
  have h := le_or_ltₓ k n
  cases' h with h' h'
  · rw [sub_nat_nat_of_le h']
    have h₂ : k ≤ m + n := le_transₓ h' (Nat.le_add_leftₓ _ _)
    rw [sub_nat_nat_of_le h₂]
    simp
    rw [Nat.add_sub_assocₓ h']
    
  rw [sub_nat_nat_of_lt h']
  simp
  rw [succ_pred_eq_of_pos (Nat.sub_pos_of_ltₓ h')]
  trans
  rw [← Nat.sub_add_cancelₓ (le_of_ltₓ h')]
  apply sub_nat_nat_add_add

theorem sub_nat_nat_add_neg_succ_of_nat (m n k : ℕ) : sub_nat_nat m n + -[1+ k] = sub_nat_nat m (n + succ k) := by
  have h := le_or_ltₓ n m
  cases' h with h' h'
  · rw [sub_nat_nat_of_le h']
    simp
    rw [sub_nat_nat_sub h', Nat.add_comm]
    
  have h₂ : m < n + succ k := Nat.lt_of_lt_of_leₓ h' (Nat.le_add_rightₓ _ _)
  have h₃ : m ≤ n + k := le_of_succ_le_succ h₂
  rw [sub_nat_nat_of_lt h', sub_nat_nat_of_lt h₂]
  simp [Nat.add_comm]
  rw [← add_succ, succ_pred_eq_of_pos (Nat.sub_pos_of_ltₓ h'), add_succ, succ_sub h₃, pred_succ]
  rw [Nat.add_comm n, Nat.add_sub_assocₓ (le_of_ltₓ h')]

theorem add_assoc_aux1 (m n : ℕ) : ∀ c : ℤ, of_nat m + of_nat n + c = of_nat m + (of_nat n + c)
  | of_nat k => by
    simp [Nat.add_assoc]
  | -[1+ k] => by
    simp [sub_nat_nat_add]

theorem add_assoc_aux2 (m n k : ℕ) : -[1+ m] + -[1+ n] + of_nat k = -[1+ m] + (-[1+ n] + of_nat k) := by
  simp [add_succ]
  rw [Int.add_comm, sub_nat_nat_add_neg_succ_of_nat]
  simp [add_succ, succ_add, Nat.add_comm]

protected theorem add_assoc : ∀ a b c : ℤ, a + b + c = a + (b + c)
  | of_nat m, of_nat n, c => add_assoc_aux1 _ _ _
  | of_nat m, b, of_nat k => by
    rw [Int.add_comm, ← add_assoc_aux1, Int.add_comm (of_nat k), add_assoc_aux1, Int.add_comm b]
  | a, of_nat n, of_nat k => by
    rw [Int.add_comm, Int.add_comm a, ← add_assoc_aux1, Int.add_comm a, Int.add_comm (of_nat k)]
  | -[1+ m], -[1+ n], of_nat k => add_assoc_aux2 _ _ _
  | -[1+ m], of_nat n, -[1+ k] => by
    rw [Int.add_comm, ← add_assoc_aux2, Int.add_comm (of_nat n), ← add_assoc_aux2, Int.add_comm -[1+ m]]
  | of_nat m, -[1+ n], -[1+ k] => by
    rw [Int.add_comm, Int.add_comm (of_nat m), Int.add_comm (of_nat m), ← add_assoc_aux2, Int.add_comm -[1+ k]]
  | -[1+ m], -[1+ n], -[1+ k] => by
    simp [add_succ, Nat.add_comm, Nat.add_left_comm, neg_of_nat_of_succ]

theorem sub_nat_self : ∀ n, sub_nat_nat n n = 0
  | 0 => rfl
  | succ m => by
    rw [sub_nat_nat_of_sub_eq_zero, Nat.sub_self, of_nat_zero]
    rw [Nat.sub_self]

attribute [local simp] sub_nat_self

protected theorem add_left_neg : ∀ a : ℤ, -a + a = 0
  | of_nat 0 => rfl
  | of_nat (succ m) => by
    simp
  | -[1+ m] => by
    simp

protected theorem add_right_neg (a : ℤ) : a + -a = 0 := by
  rw [Int.add_comm, Int.add_left_neg]

protected theorem mul_comm : ∀ a b : ℤ, a * b = b * a
  | of_nat m, of_nat n => by
    simp [Nat.mul_comm]
  | of_nat m, -[1+ n] => by
    simp [Nat.mul_comm]
  | -[1+ m], of_nat n => by
    simp [Nat.mul_comm]
  | -[1+ m], -[1+ n] => by
    simp [Nat.mul_comm]

theorem of_nat_mul_neg_of_nat (m : ℕ) : ∀ n, of_nat m * neg_of_nat n = neg_of_nat (m * n)
  | 0 => rfl
  | succ n => by
    unfold neg_of_nat
    simp

theorem neg_of_nat_mul_of_nat (m n : ℕ) : neg_of_nat m * of_nat n = neg_of_nat (m * n) := by
  rw [Int.mul_comm]
  simp [of_nat_mul_neg_of_nat, Nat.mul_comm]

theorem neg_succ_of_nat_mul_neg_of_nat (m : ℕ) : ∀ n, -[1+ m] * neg_of_nat n = of_nat (succ m * n)
  | 0 => rfl
  | succ n => by
    unfold neg_of_nat
    simp

theorem neg_of_nat_mul_neg_succ_of_nat (m n : ℕ) : neg_of_nat n * -[1+ m] = of_nat (n * succ m) := by
  rw [Int.mul_comm]
  simp [neg_succ_of_nat_mul_neg_of_nat, Nat.mul_comm]

attribute [local simp]
  of_nat_mul_neg_of_nat neg_of_nat_mul_of_nat neg_succ_of_nat_mul_neg_of_nat neg_of_nat_mul_neg_succ_of_nat

protected theorem mul_assoc : ∀ a b c : ℤ, a * b * c = a * (b * c)
  | of_nat m, of_nat n, of_nat k => by
    simp [Nat.mul_assoc]
  | of_nat m, of_nat n, -[1+ k] => by
    simp [Nat.mul_assoc]
  | of_nat m, -[1+ n], of_nat k => by
    simp [Nat.mul_assoc]
  | of_nat m, -[1+ n], -[1+ k] => by
    simp [Nat.mul_assoc]
  | -[1+ m], of_nat n, of_nat k => by
    simp [Nat.mul_assoc]
  | -[1+ m], of_nat n, -[1+ k] => by
    simp [Nat.mul_assoc]
  | -[1+ m], -[1+ n], of_nat k => by
    simp [Nat.mul_assoc]
  | -[1+ m], -[1+ n], -[1+ k] => by
    simp [Nat.mul_assoc]

protected theorem mul_zero : ∀ a : ℤ, a * 0 = 0
  | of_nat m => rfl
  | -[1+ m] => rfl

protected theorem zero_mul (a : ℤ) : 0 * a = 0 :=
  Int.mul_comm a 0 ▸ Int.mul_zero a

theorem neg_of_nat_eq_sub_nat_nat_zero : ∀ n, neg_of_nat n = sub_nat_nat 0 n
  | 0 => rfl
  | succ n => rfl

theorem of_nat_mul_sub_nat_nat (m n k : ℕ) : of_nat m * sub_nat_nat n k = sub_nat_nat (m * n) (m * k) := by
  have h₀ : m > 0 ∨ 0 = m := Decidable.lt_or_eq_of_leₓ m.zero_le
  cases' h₀ with h₀ h₀
  · have h := Nat.lt_or_geₓ n k
    cases' h with h h
    · have h' : m * n < m * k := Nat.mul_lt_mul_of_pos_leftₓ h h₀
      rw [sub_nat_nat_of_lt h, sub_nat_nat_of_lt h']
      simp
      rw [succ_pred_eq_of_pos (Nat.sub_pos_of_ltₓ h)]
      rw [← neg_of_nat_of_succ, Nat.mul_sub_left_distrib]
      rw [← succ_pred_eq_of_pos (Nat.sub_pos_of_ltₓ h')]
      rfl
      
    have h' : m * k ≤ m * n := Nat.mul_le_mul_leftₓ _ h
    rw [sub_nat_nat_of_le h, sub_nat_nat_of_le h']
    simp
    rw [Nat.mul_sub_left_distrib]
    
  have h₂ : of_nat 0 = 0 := rfl
  subst h₀
  simp [h₂, Int.zero_mul, Nat.zero_mul]

theorem neg_of_nat_add (m n : ℕ) : neg_of_nat m + neg_of_nat n = neg_of_nat (m + n) := by
  cases m
  · cases n
    · simp
      rfl
      
    simp [Nat.zero_add]
    rfl
    
  cases n
  · simp
    rfl
    
  simp [Nat.succ_add]
  rfl

theorem neg_succ_of_nat_mul_sub_nat_nat (m n k : ℕ) :
    -[1+ m] * sub_nat_nat n k = sub_nat_nat (succ m * k) (succ m * n) := by
  have h := Nat.lt_or_geₓ n k
  cases' h with h h
  · have h' : succ m * n < succ m * k := Nat.mul_lt_mul_of_pos_leftₓ h (Nat.succ_posₓ m)
    rw [sub_nat_nat_of_lt h, sub_nat_nat_of_le (le_of_ltₓ h')]
    simp [succ_pred_eq_of_pos (Nat.sub_pos_of_ltₓ h), Nat.mul_sub_left_distrib]
    
  have h' : n > k ∨ k = n := Decidable.lt_or_eq_of_leₓ h
  cases' h' with h' h'
  · have h₁ : succ m * n > succ m * k := Nat.mul_lt_mul_of_pos_leftₓ h' (Nat.succ_posₓ m)
    rw [sub_nat_nat_of_le h, sub_nat_nat_of_lt h₁]
    simp [Nat.mul_sub_left_distrib, Nat.mul_comm]
    rw [Nat.mul_comm k, Nat.mul_comm n, ← succ_pred_eq_of_pos (Nat.sub_pos_of_ltₓ h₁), ← neg_of_nat_of_succ]
    rfl
    
  subst h'
  simp
  rfl

attribute [local simp] of_nat_mul_sub_nat_nat neg_of_nat_add neg_succ_of_nat_mul_sub_nat_nat

protected theorem distrib_left : ∀ a b c : ℤ, a * (b + c) = a * b + a * c
  | of_nat m, of_nat n, of_nat k => by
    simp [Nat.left_distrib]
  | of_nat m, of_nat n, -[1+ k] => by
    simp [neg_of_nat_eq_sub_nat_nat_zero]
    rw [← sub_nat_nat_add]
    rfl
  | of_nat m, -[1+ n], of_nat k => by
    simp [neg_of_nat_eq_sub_nat_nat_zero]
    rw [Int.add_comm, ← sub_nat_nat_add]
    rfl
  | of_nat m, -[1+ n], -[1+ k] => by
    simp
    rw [← Nat.left_distrib, add_succ, succ_add]
  | -[1+ m], of_nat n, of_nat k => by
    simp [Nat.mul_comm]
    rw [← Nat.right_distrib, Nat.mul_comm]
  | -[1+ m], of_nat n, -[1+ k] => by
    simp [neg_of_nat_eq_sub_nat_nat_zero]
    rw [Int.add_comm, ← sub_nat_nat_add]
    rfl
  | -[1+ m], -[1+ n], of_nat k => by
    simp [neg_of_nat_eq_sub_nat_nat_zero]
    rw [← sub_nat_nat_add]
    rfl
  | -[1+ m], -[1+ n], -[1+ k] => by
    simp
    rw [← Nat.left_distrib, add_succ, succ_add]

protected theorem distrib_right (a b c : ℤ) : (a + b) * c = a * c + b * c := by
  rw [Int.mul_comm, Int.distrib_left]
  simp [Int.mul_comm]

protected theorem zero_ne_one : (0 : Int) ≠ 1 := fun h : 0 = 1 => succ_ne_zero _ (Int.ofNat.injₓ h).symm

theorem of_nat_sub {n m : ℕ} (h : m ≤ n) : of_nat (n - m) = of_nat n - of_nat m :=
  show of_nat (n - m) = of_nat n + neg_of_nat m from
    match m, h with
    | 0, h => rfl
    | succ m, h =>
      show of_nat (n - succ m) = sub_nat_nat n (succ m) by
        delta' sub_nat_nat <;> rw [Nat.sub_eq_zero_of_leₓ h] <;> rfl

protected theorem add_left_comm (a b c : ℤ) : a + (b + c) = b + (a + c) := by
  rw [← Int.add_assoc, Int.add_comm a, Int.add_assoc]

protected theorem add_left_cancel {a b c : ℤ} (h : a + b = a + c) : b = c := by
  have : -a + (a + b) = -a + (a + c) := by
    rw [h]
  rwa [← Int.add_assoc, ← Int.add_assoc, Int.add_left_neg, Int.zero_add, Int.zero_add] at this

protected theorem neg_add {a b : ℤ} : -(a + b) = -a + -b :=
  calc
    -(a + b) = -(a + b) + (a + b) + -a + -b := by
      rw [Int.add_assoc, Int.add_comm (-a), Int.add_assoc, Int.add_assoc, ← Int.add_assoc b]
      rw [Int.add_right_neg, Int.zero_add, Int.add_right_neg, Int.add_zero]
    _ = -a + -b := by
      rw [Int.add_left_neg, Int.zero_add]
    

theorem neg_succ_of_nat_coe' (n : ℕ) : -[1+ n] = -↑n - 1 := by
  rw [Int.sub_eq_add_neg, ← Int.neg_add] <;> rfl

protected theorem coe_nat_sub {n m : ℕ} : n ≤ m → (↑(m - n) : ℤ) = ↑m - ↑n :=
  of_nat_sub

attribute [local simp] Int.sub_eq_add_neg

protected theorem sub_nat_nat_eq_coe {m n : ℕ} : sub_nat_nat m n = ↑m - ↑n :=
  sub_nat_nat_elim m n (fun m n i => i = ↑m - ↑n)
    (fun i n => by
      simp [Int.coe_nat_add, Int.add_left_comm, Int.add_assoc, Int.add_right_neg]
      rfl)
    fun i n => by
    rw [Int.coe_nat_add, Int.coe_nat_add, Int.coe_nat_one, Int.neg_succ_of_nat_eq, Int.sub_eq_add_neg, Int.neg_add,
      Int.neg_add, Int.neg_add, ← Int.add_assoc, ← Int.add_assoc, Int.add_right_neg, Int.zero_add]

def to_nat : ℤ → ℕ
  | (n : ℕ) => n
  | -[1+ n] => 0

theorem to_nat_sub (m n : ℕ) : to_nat (m - n) = m - n := by
  rw [← Int.sub_nat_nat_eq_coe] <;>
    exact
      sub_nat_nat_elim m n (fun m n i => to_nat i = m - n)
        (fun i n => by
          rw [Nat.add_sub_cancel_left] <;> rfl)
        fun i n => by
        rw [Nat.add_assoc, Nat.sub_eq_zero_of_leₓ (Nat.le_add_rightₓ _ _)] <;> rfl

def nat_mod (m n : ℤ) : ℕ :=
  (m % n).toNat

protected theorem one_mul : ∀ a : ℤ, (1 : ℤ) * a = a
  | of_nat n =>
    show of_nat (1 * n) = of_nat n by
      rw [Nat.one_mul]
  | -[1+ n] =>
    show -[1+ 1 * n] = -[1+ n] by
      rw [Nat.one_mul]

protected theorem mul_one (a : ℤ) : a * 1 = a := by
  rw [Int.mul_comm, Int.one_mul]

protected theorem neg_eq_neg_one_mul : ∀ a : ℤ, -a = -1 * a
  | of_nat 0 => rfl
  | of_nat (n + 1) =>
    show _ = -[1+ 1 * n + 0] by
      rw [Nat.one_mul]
      rfl
  | -[1+ n] =>
    show _ = of_nat _ by
      rw [Nat.one_mul]
      rfl

theorem sign_mul_nat_abs : ∀ a : ℤ, sign a * nat_abs a = a
  | (n + 1 : ℕ) => Int.one_mul _
  | 0 => rfl
  | -[1+ n] => (Int.neg_eq_neg_one_mul _).symm

end Int

