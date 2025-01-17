prelude
import Leanbin.Init.Control.Functor

open Function

universe u v

class Pure (f : Type u → Type v) where
  pure {α : Type u} : α → f α

export Pure (pure)

class Seqₓ (f : Type u → Type v) : Type max (u + 1) v where
  seq : ∀ {α β : Type u}, f (α → β) → f α → f β

infixl:60 " <*> " => Seqₓ.seq

class SeqLeftₓ (f : Type u → Type v) : Type max (u + 1) v where
  seqLeft : ∀ {α β : Type u}, f α → f β → f α

infixl:60 " <* " => SeqLeftₓ.seqLeft

class SeqRightₓ (f : Type u → Type v) : Type max (u + 1) v where
  seqRight : ∀ {α β : Type u}, f α → f β → f β

infixl:60 " *> " => SeqRightₓ.seqRight

class Applicativeₓ (f : Type u → Type v) extends Functor f, Pure f, Seqₓ f, SeqLeftₓ f, SeqRightₓ f where
  map := fun _ _ x y => pure x <*> y
  seqLeft := fun α β a b => const β <$> a <*> b
  seqRight := fun α β a b => const α id <$> a <*> b

