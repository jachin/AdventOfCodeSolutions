module Main exposing (..)

import Browser
import Day1 exposing (solvePart1, solvePart2)
import Html exposing (div, h1, h2, p, text)


main =
    Browser.sandbox { init = init, update = update, view = view }


type Msg
    = NoOp


init : Model
init =
    { day1part1 = solvePart1
    , day1part2 = solvePart2
    }


type alias Model =
    { day1part1 : Int
    , day1part2 : Int
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model


view model =
    div []
        [ h1 [] [ text "Day 1" ]
        , h2 [] [ text "Part 1" ]
        , p [] [ text (String.fromInt model.day1part1) ]
        , h2 [] [ text "Part 2" ]
        , p [] [ text (String.fromInt model.day1part2) ]
        ]
