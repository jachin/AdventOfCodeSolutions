module Day8 exposing (..)

import Browser
import Graph exposing (..)
import Html exposing (div, h1, h2, p, text)
import List.Extra
import Maybe.Extra
import Parser exposing ((|.), (|=), Parser)


main =
    Browser.sandbox { init = init, update = update, view = view }


type Msg
    = NoOp


type alias Model =
    { part1 : Int
    , part1Test : Int
    , part2 : Int
    , part2Test : Int
    }


init : Model
init =
    { part1Test = solvePart1 testData
    , part1 = solvePart1 data
    , part2Test = solvePart2 testData
    , part2 = solvePart2 data
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        NoOp ->
            model


view model =
    div []
        [ h1 [] [ text "Day 8" ]
        , h2 [] [ text "Part 1" ]
        , p [] [ text (String.fromInt model.part1Test) ]
        , p [] [ text (String.fromInt model.part1) ]
        , h2 [] [ text "Part 2" ]
        , p [] [ text (String.fromInt model.part2Test) ]
        , p [] [ text (String.fromInt model.part2) ]
        ]


solvePart1 data_ =
    let
        _ =
            data_
                |> List.map (\str -> String.trim str |> Parser.run instructionParser)
                |> Debug.log "instructions"
    in
    0


solvePart2 data_ =
    0


exec : List Instruction -> Int -> List ( Int, Int ) -> Result String Int
exec instructions index state =
    let
        maybeInstruction =
            List.Extra.getAt index instructions

        maybeCurrentState =
            List.head state
    in
    if hasLooped index state then
        maybeCurrentState |> Maybe.map Tuple.first |> Result.fromMaybe

    else
        Maybe.map2
            (\instruction currentState ->

            )
            maybeInstruction
            maybeCurrentState


hasLooped : Int -> List ( Int, Int ) -> Bool
hasLooped index state =
    case List.Extra.find (\( stateIndex, _ ) -> stateIndex == index) state of
        Just _ ->
            True

        Nothing ->
            False


nextState : Instruction -> State -> State
nextState instruction state =
    case instruction of
        Nop ->
            {
                history = [Step state.value (state.index + 1)] ++ state.history
                , value = state.value
                , index = state.index + 1
            }

        Acc int ->
            {
                            history = [Step state.value (state.index + 1)] ++ state.history
                            , value = state.value
                            , index = state.index + 1
                        }

        Jmp int ->

            {
                            history = [Step state.value (state.index + 1)] ++ state.history
                            , value = state.value
                            , index = state.index + 1
                        }



type Instruction
    = Nop
    | Acc Int
    | Jmp Int


type State =
    {
       history: List Step
       value:  Int
       index: Int
    }


type Step =
    Step Int Int


instructionParser : Parser Instruction
instructionParser =
    Parser.oneOf
        [ nopParser
        , accParser
        , jmpParser
        ]


nopParser : Parser Instruction
nopParser =
    Parser.succeed Nop
        |. Parser.symbol "nop"
        |. Parser.spaces
        |. singedIntParser


accParser : Parser Instruction
accParser =
    Parser.succeed Acc
        |. Parser.symbol "acc"
        |. Parser.spaces
        |= singedIntParser


jmpParser : Parser Instruction
jmpParser =
    Parser.succeed Jmp
        |. Parser.symbol "jmp"
        |. Parser.spaces
        |= singedIntParser


singedIntParser : Parser Int
singedIntParser =
    Parser.succeed Tuple.pair
        |= parseSymbol
        |= Parser.int
        |> Parser.andThen
            (\( symbol, i ) ->
                case symbol of
                    "-" ->
                        Parser.succeed (i * -1)

                    "+" ->
                        Parser.succeed i

                    _ ->
                        Parser.succeed i
            )


parseSymbol : Parser String
parseSymbol =
    Parser.getChompedString <|
        Parser.chompWhile (\c -> c == '+' || c == '-')


testData =
    [ "nop +0"
    , "acc +1"
    , "jmp +4"
    , "acc +3"
    , "jmp -3"
    , "acc -99"
    , "acc +1"
    , "jmp -4"
    , "acc +6"
    ]


data =
    []
