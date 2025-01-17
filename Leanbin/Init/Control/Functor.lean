prelude
import Leanbin.Init.Core
import Leanbin.Init.Function
import Leanbin.Init.Meta.Name

open Function

universe u v

class Functor (f : Type u → Type v) : Type max (u + 1) v where
  map : ∀ {α β : Type u}, (α → β) → f α → f β
  mapConst : ∀ {α β : Type u}, α → f β → f α := fun α β => map ∘ const β

infixr:100 " <$> " => Functor.map

infixr:100 " <$ " => Functor.mapConst

@[reducible]
def Functor.mapConstRev {f : Type u → Type v} [Functor f] {α β : Type u} : f β → α → f α := fun a b => b <$ a

infixr:100 " $> " => Functor.mapConstRev

