module Day2 exposing (init)

import Array exposing (Array)
import Browser
import Html exposing (Html, div, h1, p, text)
import List.Extra


main =
    Browser.sandbox { init = init, update = update, view = view }


init : Model
init =
    { test1 = solveTestData1
    , answerPart1 = solvePart1
    , answerPart2 = solvePart2
    }


type alias Model =
    { test1 : String
    , answerPart1 : String
    , answerPart2 : String
    }


update : () -> Model -> Model
update _ model =
    model


view : Model -> Html ()
view model =
    div []
        [ h1 []
            [ text "day 2" ]
        , p [] [ text model.test1 ]
        , p [] [ text model.answerPart1 ]
        , p [] [ text model.answerPart2 ]
        ]


testData =
    """1,9,10,3,2,3,11,0,99,30,40,50"""


actualDataPart1 =
    """1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,9,19,1,19,5,23,1,13,23,27,1,27,6,31,2,31,6,35,2,6,35,39,1,39,5,43,1,13,43,47,1,6,47,51,2,13,51,55,1,10,55,59,1,59,5,63,1,10,63,67,1,67,5,71,1,71,10,75,1,9,75,79,2,13,79,83,1,9,83,87,2,87,13,91,1,10,91,95,1,95,9,99,1,13,99,103,2,103,13,107,1,107,10,111,2,10,111,115,1,115,9,119,2,119,6,123,1,5,123,127,1,5,127,131,1,10,131,135,1,135,6,139,1,10,139,143,1,143,6,147,2,147,13,151,1,5,151,155,1,155,5,159,1,159,2,163,1,163,9,0,99,2,14,0,0"""


actualDataPart2 =
    """1,0,0,3,1,1,2,3,1,3,4,3,1,5,0,3,2,1,9,19,1,19,5,23,1,13,23,27,1,27,6,31,2,31,6,35,2,6,35,39,1,39,5,43,1,13,43,47,1,6,47,51,2,13,51,55,1,10,55,59,1,59,5,63,1,10,63,67,1,67,5,71,1,71,10,75,1,9,75,79,2,13,79,83,1,9,83,87,2,87,13,91,1,10,91,95,1,95,9,99,1,13,99,103,2,103,13,107,1,107,10,111,2,10,111,115,1,115,9,119,2,119,6,123,1,5,123,127,1,5,127,131,1,10,131,135,1,135,6,139,1,10,139,143,1,143,6,147,2,147,13,151,1,5,151,155,1,155,5,159,1,159,2,163,1,163,9,0,99,2,14,0,0"""


parseData s =
    String.split "," s |> List.map String.toInt |> List.map (Maybe.withDefault 0) |> Array.fromList


type OptCode
    = Add
    | Multiply
    | Exit
    | Unknown


type Status
    = Running Int (Array Int)
    | Stopped (Array Int)
    | Error (Array Int)


type alias Params =
    { a : Int
    , b : Int
    , output : Int
    }


intToOpCode i =
    case i of
        1 ->
            Add

        2 ->
            Multiply

        99 ->
            Exit

        _ ->
            Unknown


type alias Day2 =
    { answer : String
    , test1 : String
    , answerPart2 : String
    }


getParams : Array Int -> Int -> Params
getParams state index =
    let
        maybeParams =
            Maybe.map3
                (\a b c -> { a = a, b = b, output = c })
                (Array.get (index + 1) state)
                (Array.get (index + 2) state)
                (Array.get (index + 3) state)
    in
    case maybeParams of
        Just params_ ->
            params_

        Nothing ->
            Debug.todo "Error getting params"


addition : Array Int -> Int -> Int -> Int
addition state address1 address2 =
    let
        result =
            Maybe.map2
                (\a b -> a + b)
                (Array.get address1 state)
                (Array.get address2 state)
    in
    case result of
        Just value ->
            value

        Nothing ->
            Debug.todo "Failed to add"


multiplication : Array Int -> Int -> Int -> Int
multiplication state address1 address2 =
    let
        result =
            Maybe.map2
                (\a b -> a * b)
                (Array.get address1 state)
                (Array.get address2 state)
    in
    case result of
        Just value ->
            value

        Nothing ->
            Debug.todo "Failed to multiply"


getNextState : Array Int -> Int -> Status
getNextState state index =
    let
        opCode =
            case Array.get index state of
                Nothing ->
                    Unknown

                Just int ->
                    intToOpCode int
    in
    case opCode of
        Add ->
            let
                params =
                    getParams state index

                additionResult =
                    addition state params.a params.b
            in
            Running (index + 4) (Array.set params.output additionResult state)

        Multiply ->
            let
                params =
                    getParams state index

                multiplicationResult =
                    multiplication state params.a params.b
            in
            Running (index + 4) (Array.set params.output multiplicationResult state)

        Exit ->
            Stopped state

        Unknown ->
            Error state


run : Array Int -> Int
run initialState =
    let
        helper : Array Int -> Int -> Maybe Int
        helper state index =
            case getNextState state index of
                Running newIndex newState ->
                    helper newState newIndex

                Stopped newState ->
                    Array.get 0 newState

                Error _ ->
                    Nothing
    in
    case helper initialState 0 of
        Just result ->
            result

        Nothing ->
            -1


solvePart1 =
    actualDataPart1 |> parseData |> run |> String.fromInt


solveTestData1 =
    testData |> parseData |> run |> String.fromInt


genOptions =
    let
        nouns =
            List.range 0 99

        verbs =
            List.range 0 99
    in
    List.Extra.lift2 (\n v -> ( n, v )) nouns verbs


solvePart2 =
    let
        options =
            Debug.log "options" genOptions

        baseMemory =
            actualDataPart2 |> parseData

        makeMemory memory ( noun_, verb_ ) =
            let
                update1 =
                    Array.set 1 noun_ memory
            in
            Array.set 2 verb_ update1

        memories =
            List.map (makeMemory baseMemory) options

        testOption memory =
            let
                result =
                    run memory
            in
            if result == 19690720 then
                True

            else
                False

        answers =
            List.filter (\memory -> testOption memory) memories

        answer =
            Maybe.withDefault Array.empty (List.head answers)

        noun =
            Maybe.withDefault -1 (Array.get 1 answer)

        verb =
            Maybe.withDefault -1 (Array.get 2 answer)

        output =
            (noun * 100) + verb
    in
    String.fromInt output
