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
    List.Extra.uniquePairs numbers
        |> List.map
            (\pair ->
                List.map
                    (\n ->
                        if Tuple.first pair /= n && Tuple.second pair /= n then
                            new (Tuple.first pair) (Tuple.second pair) n

                        else
                            []
                    )
                    numbers
            )
        |> List.concat
        |> List.filter (\l -> l /= [])
        |> List.Extra.unique


type alias Triplet =
    List Int
