module Lazy ( force, Lazy, lazy, map, apply, bind
            ) where

{-| Library for Lazy evaluation.

# Delay
@docs lazy

# Evaluate
@docs force

# Transform
@docs map, apply, bind
-}

import Native.Lazy

data Lazy a = L { force : () -> a }

{-| Delay execution of a value -}
lazy : (() -> a) -> Lazy a
lazy t = L { force = (Native.Lazy.lazy t) }

{-| Execute a lazy value. -}
force : Lazy a -> a
force (L r) = r.force ()

{-| Lazily apply a function to a lazy value. The computation
will be delayed until you force the resulting value.
-}
map : (a -> b) -> Lazy a -> Lazy b
map f t = lazy <| \() ->
  f << force <| t

{-| Lazily apply a lazy function to a lazy value. This can
be used to lazily apply a function to many lazy arguments:

```haskell
f `map` a `apply` b `apply` c
```
-}
apply : Lazy (a -> b) -> Lazy a -> Lazy b
apply f x = lazy <| \() ->
  (force f) (force x)

{-| Lazily chain together Lazy computations. -}
bind : Lazy a -> (a -> Lazy b) -> Lazy b
bind x k = lazy <| \() ->
  force << k << force <| x
