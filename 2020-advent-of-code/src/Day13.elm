module Day13 exposing (..)

import Browser
import Html exposing (button, div, h1, h2, p, text)
import Html.Events exposing (onClick)
import List.Extra
import Maybe.Extra
import Process
import Task


main =
    Browser.element
        { init = init
        , subscriptions = subscriptions
        , view = view
        , update = update
        }


subscriptions _ =
    Sub.none


type Msg
    = SolvePart1Test
    | StartPart2Test
    | SolvePart1
    | StartPart2


type alias Model =
    { part1Answer : Int
    , part1StartTime : Int
    , part1BusIds : List Int
    , part1TestAnswer : Int
    , part1TestStartTime : Int
    , part1TestBusTimes : List Int
    , part2BusIds : List (Maybe Int)
    , part2TestBusIds : List (Maybe Int)
    , part2TestTimestamp : Int
    , part2Answer : Int
    , part2TestAnswer : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    let
        testInputs =
            testData
                |> String.trim
                |> String.split "\n"

        inputs =
            data
                |> String.trim
                |> String.split "\n"

        _ =
            Debug.log "test check timestamp" <|
                checkTimeStamp 1068781
                    (testInputs
                        |> List.tail
                        |> Maybe.andThen List.head
                        |> Maybe.withDefault ""
                        |> parseAllBusIds
                    )
    in
    ( { part1Answer = 0
      , part1StartTime =
            inputs
                |> List.head
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 0
      , part1BusIds =
            inputs
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.withDefault ""
                |> parseActiveBusIds
      , part1TestAnswer = 0
      , part1TestStartTime =
            testInputs
                |> List.head
                |> Maybe.andThen String.toInt
                |> Maybe.withDefault 0
      , part1TestBusTimes =
            testInputs
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.withDefault ""
                |> parseActiveBusIds
      , part2BusIds =
            inputs
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.withDefault ""
                |> parseAllBusIds
      , part2TestBusIds =
            testInputs
                |> List.tail
                |> Maybe.andThen List.head
                |> Maybe.withDefault ""
                |> parseAllBusIds
      , part2TestTimestamp = 0
      , part2Answer = 0
      , part2TestAnswer = 0
      }
    , Cmd.none
    )


parseActiveBusIds : String -> List Int
parseActiveBusIds string =
    string
        |> String.split ","
        |> List.filter (\str -> str /= "x")
        |> List.map String.toInt
        |> Maybe.Extra.values


parseAllBusIds : String -> List (Maybe Int)
parseAllBusIds string =
    string
        |> String.split ","
        |> List.map String.toInt


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SolvePart1Test ->
            ( { model
                | part1TestAnswer =
                    busWaitTimes model.part1TestStartTime model.part1TestBusTimes
                        |> List.head
                        |> Maybe.map (\( busId, waitTime ) -> busId * waitTime)
                        |> Maybe.withDefault 0
              }
            , Cmd.none
            )

        StartPart2Test ->
            if checkTimeStamp model.part2TestTimestamp model.part2TestBusIds then
                ( { model | part2TestAnswer = model.part2TestTimestamp }, Cmd.none )

            else
                let
                    increment =
                        List.head model.part2TestBusIds
                            |> Maybe.andThen identity
                            |> Maybe.withDefault 0
                in
                ( { model | part2TestTimestamp = model.part2TestTimestamp + increment }
                , Process.sleep 0.0 |> Task.perform (\_ -> StartPart2Test)
                )

        SolvePart1 ->
            ( { model
                | part1Answer =
                    busWaitTimes model.part1StartTime model.part1BusIds
                        |> List.head
                        |> Maybe.map (\( busId, waitTime ) -> busId * waitTime)
                        |> Maybe.withDefault 0
              }
            , Cmd.none
            )

        StartPart2 ->
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div []
        [ h1 [] [ text "Day 13" ]
        , h2 [] [ text "Part 1" ]
        , p [] [ button [ onClick SolvePart1Test ] [ text "Start Part 1 Test" ] ]
        , p [] [ text ("Answer: " ++ String.fromInt model.part1TestAnswer) ]
        , p [] [ button [ onClick SolvePart1 ] [ text "Start Part 1" ] ]
        , p [] [ text ("Answer: " ++ String.fromInt model.part1Answer) ]
        , h2 [] [ text "Part 2" ]
        , p [] [ button [ onClick StartPart2Test ] [ text "Start Part 2 Test" ] ]
        , p [] [ text ("Answer: " ++ String.fromInt model.part2TestAnswer) ]
        , p [] [ button [ onClick StartPart2 ] [ text "Start Part 2" ] ]
        , p [] [ text ("Answer: " ++ String.fromInt model.part2Answer) ]
        ]


busWaitTimes : Int -> List Int -> List ( Int, Int )
busWaitTimes startTime busIds =
    let
        waitTimes =
            busIds
                |> List.map
                    (\busId ->
                        let
                            x =
                                startTime // busId
                        in
                        ((x * busId) - startTime) + busId
                    )
    in
    List.Extra.zip busIds
        waitTimes
        |> List.sortBy
            (\( _, a ) -> a)


checkTimeStamp : Int -> List (Maybe Int) -> Bool
checkTimeStamp timestamp busIds =
    let
        _ =
            if List.length busIds < 3 then
                Debug.log "bus ids" ( timestamp, busIds )

            else
                ( timestamp, busIds )
    in
    case List.head busIds of
        Just maybeBusId ->
            case maybeBusId of
                Just busId ->
                    if modBy busId timestamp == 0 then
                        case List.tail busIds of
                            Just tailBusIds ->
                                checkTimeStamp (timestamp + 1) tailBusIds

                            Nothing ->
                                True

                    else
                        False

                Nothing ->
                    case List.tail busIds of
                        Just tailBusIds ->
                            checkTimeStamp (timestamp + 1) tailBusIds

                        Nothing ->
                            True

        Nothing ->
            case List.tail busIds of
                Just tailBusIds ->
                    checkTimeStamp (timestamp + 1) tailBusIds

                Nothing ->
                    True


testData =
    """939
7,13,x,x,59,x,31,19
"""


data =
    """1000510
19,x,x,x,x,x,x,x,x,41,x,x,x,x,x,x,x,x,x,523,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,17,13,x,x,x,x,x,x,x,x,x,x,29,x,853,x,x,x,x,x,37,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,23
"""
