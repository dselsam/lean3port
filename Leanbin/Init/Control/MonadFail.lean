prelude
import Leanbin.Init.Control.Lift
import Leanbin.Init.Data.String.Basic

universe u v

class MonadFail (m : Type u → Type v) where
  fail : ∀ {a}, Stringₓ → m a

def matchFailed {α : Type u} {m : Type u → Type v} [MonadFail m] : m α :=
  MonadFail.fail "match failed"

instance (priority := 100) monadFailLift (m n : Type u → Type v) [Monadₓ n] [MonadFail m] [HasMonadLift m n] :
    MonadFail n where
  fail := fun α s => monad_lift (MonadFail.fail s : m α)

