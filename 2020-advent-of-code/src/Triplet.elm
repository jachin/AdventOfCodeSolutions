module Triplet exposing (Triplet, generateUnique, multiply, new, sum)

import List.Extra


new : Int -> Int -> Int -> Triplet
new one two three =
    [ one, two, three ] |> List.sort


sum : Triplet -> Int
sum triplet =
    List.foldl (+) 0 triplet


multiply : Triplet -> Int
multiply triplet =
    List.foldl (*) 1 triplet


generateUnique : List Int -> List Triplet
generateUnique numbers =
    List.Extra.cartesianProduct
        [ numbers, numbers, numbers ]
        |> List.map
            (\a ->
                case a of
                    x :: y :: z :: _ ->
                        new x y z

                    _ ->
                        new 0 0 0
            )
        |> List.Extra.unique


type alias Triplet =
    List Int
