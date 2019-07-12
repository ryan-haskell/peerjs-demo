module Grid exposing
    ( Grid
    , every
    , get
    , init
    , map
    , set
    , toListOfLists
    )

import Array exposing (Array)


type Grid a
    = Grid (Array (Array a))


init : ( Int, Int ) -> a -> Grid a
init ( width, height ) initialValue =
    Grid
        (Array.initialize height
            (always (Array.initialize width (always initialValue)))
        )


get : ( Int, Int ) -> Grid a -> Maybe a
get ( x, y ) (Grid grid) =
    Array.get y grid
        |> Maybe.andThen (\row -> Array.get x row)


set : a -> ( Int, Int ) -> Grid a -> Grid a
set value ( x, y ) (Grid grid) =
    Grid
        (Array.get y grid
            |> Maybe.map (\row -> Array.set y (Array.set x value row) grid)
            |> Maybe.withDefault grid
        )


map : (a -> b) -> Grid a -> Grid b
map fn (Grid grid) =
    Grid (Array.map (Array.map fn) grid)


toListOfLists : Grid a -> List (List a)
toListOfLists (Grid grid) =
    Array.toList grid
        |> List.map Array.toList


every : (a -> Bool) -> Grid a -> Bool
every predicate =
    toListOfLists
        >> List.concat
        >> List.all predicate
