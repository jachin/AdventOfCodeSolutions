module Day11 exposing (..)

import Browser
import Dict exposing (Dict)
import Html exposing (button, div, h1, h2, p, pre, table, td, text, tr)
import Html.Events exposing (onClick)
import Maybe.Extra
import Parser exposing ((|.), (|=), Parser)
import Process
import Set
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
    = NoOp
    | StartPart1Test
    | StartPart2Test
    | StartPart1
    | StartPart2


type alias Model =
    { part1 : Dict ( Int, Int ) Space
    , part1Size : ( Int, Int )
    , part1Answer : Int
    , part1Test : Dict ( Int, Int ) Space
    , part1TestSize : ( Int, Int )
    , part1TestAnswer : Int
    , part2 : Dict ( Int, Int ) Space
    , part2Size : ( Int, Int )
    , part2Answer : Int
    , part2Test : Dict ( Int, Int ) Space
    , part2TestSize : ( Int, Int )
    , part2TestAnswer : Int
    , part2TestIterations : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { part1 = makeInitialFloorState data
      , part1Size = calculateFloorSize data
      , part1Answer = 0
      , part1TestSize = calculateFloorSize testData
      , part1Test = makeInitialFloorState testData
      , part1TestAnswer = 0
      , part2 = makeInitialFloorState data
      , part2Answer = 0
      , part2Size = calculateFloorSize data
      , part2Test = makeInitialFloorState testData
      , part2TestSize = calculateFloorSize testData
      , part2TestAnswer = 0
      , part2TestIterations = 0
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        StartPart1Test ->
            let
                nextFloorState =
                    part1MakeNextFloorState model.part1Test
            in
            if nextFloorState == model.part1Test then
                ( { model
                    | part1Test = nextFloorState
                    , part1TestAnswer = nextFloorState |> numberOfOccupiedSeats
                  }
                , Cmd.none
                )

            else
                ( { model | part1Test = nextFloorState }
                , Process.sleep 2.0 |> Task.perform (\_ -> StartPart1Test)
                )

        StartPart2Test ->
            let
                nextFloorState =
                    part2MakeNextFloorState model.part2Test
            in
            if isEqual nextFloorState model.part2Test then
                ( { model
                    | part2Test = nextFloorState
                    , part2TestAnswer = nextFloorState |> numberOfOccupiedSeats
                  }
                , Cmd.none
                )

            else
                ( { model
                    | part2Test = nextFloorState
                    , part2TestIterations = model.part2TestIterations + 1
                  }
                , Process.sleep 2.0 |> Task.perform (\_ -> StartPart2Test)
                )

        StartPart1 ->
            let
                nextFloorState =
                    part1MakeNextFloorState model.part1
            in
            if nextFloorState == model.part1 then
                ( { model
                    | part1 = nextFloorState
                    , part1Answer = nextFloorState |> numberOfOccupiedSeats
                  }
                , Cmd.none
                )

            else
                ( { model | part1 = nextFloorState }
                , Process.sleep 2.0 |> Task.perform (\_ -> StartPart1)
                )

        StartPart2 ->
            ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    div []
        [ h1 [] [ text "Day 11" ]
        , h2 [] [ text "Part 1" ]
        , p [] [ button [ onClick StartPart1Test ] [ text "Start Part 1 Test" ] ]
        , p [] [ text ("Answer: " ++ String.fromInt model.part1TestAnswer) ]
        , floorMarkup model.part1TestSize model.part1Test
        , p [] [ button [ onClick StartPart1 ] [ text "Start Part 1" ] ]
        , floorMarkup model.part1Size model.part1
        , p [] [ text ("Answer: " ++ String.fromInt model.part1Answer) ]
        , h2 [] [ text "Part 2" ]
        , p [] [ button [ onClick StartPart2Test ] [ text "Start Part 2 Test" ] ]
        , p [] [ text ("Iterations: " ++ String.fromInt model.part2TestIterations) ]
        , p [] [ text ("Answer: " ++ String.fromInt model.part2TestAnswer) ]
        , p [] [ button [ onClick StartPart2 ] [ text "Start Part 2" ] ]
        , p [] [ text ("Answer: " ++ String.fromInt model.part2Answer) ]
        ]


floorMarkup : ( Int, Int ) -> Dict ( Int, Int ) Space -> Html.Html Msg
floorMarkup ( x, y ) floor =
    table []
        (List.range 0 (x - 1)
            |> List.map
                (\x_ ->
                    tr []
                        (List.range 0 (y - 1)
                            |> List.map
                                (\y_ ->
                                    td []
                                        [ pre []
                                            [ text
                                                (Dict.get ( x_, y_ ) floor
                                                    |> Maybe.map spaceToString
                                                    |> Maybe.withDefault "."
                                                )
                                            ]
                                        ]
                                )
                        )
                )
        )


makeInitialFloorState : String -> Dict ( Int, Int ) Space
makeInitialFloorState string =
    string
        |> String.trim
        |> String.split "\n"
        |> List.map String.toList
        |> List.map (\row -> List.map String.fromChar row)
        |> List.indexedMap
            (\x row ->
                List.indexedMap
                    (\y space ->
                        Parser.run spaceParser space
                            |> Result.withDefault Floor
                            |> FloorSquare x y
                    )
                    row
            )
        |> List.concat
        |> makeFloorDict


calculateFloorSize : String -> ( Int, Int )
calculateFloorSize string =
    string
        |> String.trim
        |> String.split "\n"
        |> (\strings ->
                ( List.length strings
                , List.head strings |> Maybe.map String.length |> Maybe.withDefault 0
                )
           )


part1GetNewSpaceValue : Space -> List Space -> Space
part1GetNewSpaceValue space neighbors =
    case space of
        EmptySeat ->
            if noOccupiedSeats neighbors then
                FullSeat

            else
                EmptySeat

        FullSeat ->
            if fourOrMoreOccupiedSeats neighbors then
                EmptySeat

            else
                FullSeat

        Floor ->
            Floor


part1MakeNextFloorState : Dict ( Int, Int ) Space -> Dict ( Int, Int ) Space
part1MakeNextFloorState previous =
    previous
        |> Dict.map (\cords space -> getNeighbors cords previous |> part1GetNewSpaceValue space)


part2GetNewSpaceValue : Space -> List Space -> Space
part2GetNewSpaceValue space neighbors =
    case space of
        EmptySeat ->
            if noOccupiedSeats neighbors then
                FullSeat

            else
                EmptySeat

        FullSeat ->
            if fiveOrMoreOccupiedSeats neighbors then
                EmptySeat

            else
                FullSeat

        Floor ->
            Floor


part2MakeNextFloorState : Dict ( Int, Int ) Space -> Dict ( Int, Int ) Space
part2MakeNextFloorState previous =
    previous
        |> Dict.map (\cords space -> getVisibleNeighbors cords previous |> part2GetNewSpaceValue space)


isEqual : Dict ( Int, Int ) Space -> Dict ( Int, Int ) Space -> Bool
isEqual a b =
    let
        aSet =
            Dict.toList a
                |> List.map (\( ( x, y ), space ) -> String.fromInt x ++ String.fromInt y ++ spaceToString space)
                |> Set.fromList

        bSet =
            Dict.toList b
                |> List.map (\( ( x, y ), space ) -> String.fromInt x ++ String.fromInt y ++ spaceToString space)
                |> Set.fromList
    in
    Set.diff aSet bSet |> Set.isEmpty


spaceToString : Space -> String
spaceToString space =
    case space of
        EmptySeat ->
            "L"

        FullSeat ->
            "#"

        Floor ->
            "."


solvePart1 data_ =
    let
        initialFloorState =
            data_
                |> String.trim
                |> String.split "\n"
                |> List.map String.toList
                |> List.map (\row -> List.map String.fromChar row)
                |> List.indexedMap
                    (\x row ->
                        List.indexedMap
                            (\y space ->
                                Parser.run spaceParser space
                                    |> Result.withDefault Floor
                                    |> FloorSquare x y
                            )
                            row
                    )
                |> List.concat

        initialFloorDict =
            makeFloorDict initialFloorState

        getNewSpaceValue : Space -> List Space -> Space
        getNewSpaceValue space neighbors =
            case space of
                EmptySeat ->
                    if noOccupiedSeats neighbors then
                        FullSeat

                    else
                        EmptySeat

                FullSeat ->
                    if fourOrMoreOccupiedSeats neighbors then
                        EmptySeat

                    else
                        FullSeat

                Floor ->
                    Floor

        makeNextFloorState : Dict ( Int, Int ) Space -> Dict ( Int, Int ) Space
        makeNextFloorState previous =
            previous
                |> Dict.map (\cords space -> getNeighbors cords previous |> getNewSpaceValue space)

        solver : Dict ( Int, Int ) Space -> Dict ( Int, Int ) Space
        solver floorState =
            let
                nextFloorState =
                    makeNextFloorState floorState
            in
            if nextFloorState == floorState then
                floorState

            else
                solver nextFloorState
    in
    solver initialFloorDict
        |> numberOfOccupiedSeats


solvePart2 data_ =
    let
        initialFloorState =
            data_
                |> String.trim
                |> String.split "\n"
                |> List.map String.toList
                |> List.map (\row -> List.map String.fromChar row)
                |> List.indexedMap
                    (\x row ->
                        List.indexedMap
                            (\y space ->
                                Parser.run spaceParser space
                                    |> Result.withDefault Floor
                                    |> FloorSquare x y
                            )
                            row
                    )
                |> List.concat

        initialFloorDict =
            makeFloorDict initialFloorState

        getNewSpaceValue : Space -> List Space -> Space
        getNewSpaceValue space neighbors =
            case space of
                EmptySeat ->
                    if noOccupiedSeats neighbors then
                        FullSeat

                    else
                        EmptySeat

                FullSeat ->
                    if fiveOrMoreOccupiedSeats neighbors then
                        EmptySeat

                    else
                        FullSeat

                Floor ->
                    Floor

        makeNextFloorState : Dict ( Int, Int ) Space -> Dict ( Int, Int ) Space
        makeNextFloorState previous =
            previous
                |> Dict.map (\cords space -> getVisibleNeighbors cords previous |> getNewSpaceValue space)

        solver : Dict ( Int, Int ) Space -> Dict ( Int, Int ) Space
        solver floorState =
            let
                nextFloorState =
                    makeNextFloorState floorState
                        |> Debug.log "nextFloorState"
            in
            if nextFloorState == floorState then
                floorState

            else
                solver nextFloorState
    in
    solver initialFloorDict
        |> numberOfOccupiedSeats


numberOfOccupiedSeats : Dict ( Int, Int ) Space -> Int
numberOfOccupiedSeats dict =
    Dict.filter
        (\_ space ->
            case space of
                EmptySeat ->
                    False

                FullSeat ->
                    True

                Floor ->
                    False
        )
        dict
        |> Dict.size


getNeighbors : ( Int, Int ) -> Dict ( Int, Int ) Space -> List Space
getNeighbors ( x, y ) dict =
    [ Dict.get ( x + 1, y + 1 ) dict
    , Dict.get ( x, y + 1 ) dict
    , Dict.get ( x - 1, y + 1 ) dict
    , Dict.get ( x + 1, y ) dict
    , Dict.get ( x - 1, y ) dict
    , Dict.get ( x + 1, y - 1 ) dict
    , Dict.get ( x, y - 1 ) dict
    , Dict.get ( x - 1, y - 1 ) dict
    ]
        |> Maybe.Extra.values


getVisibleNeighbors : ( Int, Int ) -> Dict ( Int, Int ) Space -> List Space
getVisibleNeighbors ( x, y ) dict =
    let
        upToTheLeft : Int -> Int -> Space
        upToTheLeft x_ y_ =
            case Dict.get ( x_ + 1, y_ + 1 ) dict of
                Just space ->
                    case space of
                        EmptySeat ->
                            EmptySeat

                        FullSeat ->
                            FullSeat

                        Floor ->
                            upToTheLeft (x_ + 1) (y_ + 1)

                Nothing ->
                    Floor

        up : Int -> Int -> Space
        up x_ y_ =
            case Dict.get ( x_, y_ + 1 ) dict of
                Just space ->
                    case space of
                        EmptySeat ->
                            EmptySeat

                        FullSeat ->
                            FullSeat

                        Floor ->
                            upToTheLeft x_ (y_ + 1)

                Nothing ->
                    Floor

        upToTheRight : Int -> Int -> Space
        upToTheRight x_ y_ =
            case Dict.get ( x_ - 1, y_ + 1 ) dict of
                Just space ->
                    case space of
                        EmptySeat ->
                            EmptySeat

                        FullSeat ->
                            FullSeat

                        Floor ->
                            upToTheLeft (x_ - 1) (y_ + 1)

                Nothing ->
                    Floor

        left : Int -> Int -> Space
        left x_ y_ =
            case Dict.get ( x_ + 1, y_ ) dict of
                Just space ->
                    case space of
                        EmptySeat ->
                            EmptySeat

                        FullSeat ->
                            FullSeat

                        Floor ->
                            upToTheLeft (x_ + 1) y_

                Nothing ->
                    Floor

        right : Int -> Int -> Space
        right x_ y_ =
            case Dict.get ( x_ - 1, y_ ) dict of
                Just space ->
                    case space of
                        EmptySeat ->
                            EmptySeat

                        FullSeat ->
                            FullSeat

                        Floor ->
                            upToTheLeft (x_ - 1) y_

                Nothing ->
                    Floor

        downToTheLeft : Int -> Int -> Space
        downToTheLeft x_ y_ =
            case Dict.get ( x_ - 1, y_ - 1 ) dict of
                Just space ->
                    case space of
                        EmptySeat ->
                            EmptySeat

                        FullSeat ->
                            FullSeat

                        Floor ->
                            upToTheLeft (x_ - 1) (y_ - 1)

                Nothing ->
                    Floor

        down : Int -> Int -> Space
        down x_ y_ =
            case Dict.get ( x_, y_ - 1 ) dict of
                Just space ->
                    case space of
                        EmptySeat ->
                            EmptySeat

                        FullSeat ->
                            FullSeat

                        Floor ->
                            upToTheLeft x_ (y_ - 1)

                Nothing ->
                    Floor

        downToTheRight : Int -> Int -> Space
        downToTheRight x_ y_ =
            case Dict.get ( x_ - 1, y_ - 1 ) dict of
                Just space ->
                    case space of
                        EmptySeat ->
                            EmptySeat

                        FullSeat ->
                            FullSeat

                        Floor ->
                            upToTheLeft (x_ - 1) (y_ - 1)

                Nothing ->
                    Floor
    in
    [ upToTheLeft x y
    , up x y
    , upToTheRight x y
    , left x y
    , right x y
    , downToTheLeft x y
    , down x y
    , downToTheRight x y
    ]


noOccupiedSeats : List Space -> Bool
noOccupiedSeats spaces =
    List.filter
        (\space ->
            case space of
                EmptySeat ->
                    False

                FullSeat ->
                    True

                Floor ->
                    False
        )
        spaces
        |> List.isEmpty


fourOrMoreOccupiedSeats : List Space -> Bool
fourOrMoreOccupiedSeats spaces =
    List.filter
        (\space ->
            case space of
                EmptySeat ->
                    False

                FullSeat ->
                    True

                Floor ->
                    False
        )
        spaces
        |> List.length
        |> (\length -> length >= 4)


fiveOrMoreOccupiedSeats : List Space -> Bool
fiveOrMoreOccupiedSeats spaces =
    List.filter
        (\space ->
            case space of
                EmptySeat ->
                    False

                FullSeat ->
                    True

                Floor ->
                    False
        )
        spaces
        |> List.length
        |> (\length -> length >= 4)


makeFloorDict : List FloorSpace -> Dict ( Int, Int ) Space
makeFloorDict floorLists =
    floorLists
        |> List.map floorSpaceToTuple
        |> Dict.fromList


floorSpaceToTuple : FloorSpace -> ( ( Int, Int ), Space )
floorSpaceToTuple floorSpace =
    case floorSpace of
        FloorSquare x y space ->
            ( ( x, y ), space )


type FloorSpace
    = FloorSquare Int Int Space


type Space
    = EmptySeat
    | FullSeat
    | Floor


spaceParser : Parser Space
spaceParser =
    Parser.oneOf
        [ emptySeatParser, fullSeatParser, floorParser ]


emptySeatParser : Parser Space
emptySeatParser =
    Parser.succeed EmptySeat
        |. Parser.symbol "L"


fullSeatParser : Parser Space
fullSeatParser =
    Parser.succeed FullSeat
        |. Parser.symbol "#"


floorParser : Parser Space
floorParser =
    Parser.succeed Floor
        |. Parser.symbol "."



--noinspection SpellCheckingInspection


testData =
    """
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
"""



--noinspection SpellCheckingInspection


data =
    """
LLLLLL.LLLLL.LLLL..LLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLL.LLLLL..LLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.L.LLLLLLL.LLLLLLLLLLLLLLL.LLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLLLLL
...L....L.LLL.L.L....LL..LL....L.L..L.....L....LLL..L....LL....LLLL.L.........L..LL..............
LLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL
LLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLL..LLLLLLL.LLLLLL..LLLLLLLLLLLL.LLLLLLLL..LLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLL
LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLL...L.L..L.LL.L.L...L....L..L.LLL.L..L....L.L.L...LLL..L...LLL..L..LL.L.L.LL.LL..L...L......L.L
LLLLLL.LLLL.LLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLL.LLLL.LLLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLL..LLLLLLLLLLLLLL..LLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LL.LLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLLLLLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLLLL
......L.L.L...LLLL.L....L...LL....LL.LL..L.L..L..L..LL.....L..LL...LLL...L.LL.L.L...L.L.......L..
LLLLLL.LLLLLLLLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLL..LLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLL.LLLLLLLLL
..L...LL..L.LL..L.L.LL.LLLL......L...LLL..L.L.L..L...LL.LLL..L..L....L.L.LLL..L..L...LL...L.L..LL
LLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.L.LLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLLLLLLLL.LLLLLLLLL.LLLLLLLLL.LLLL.LL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLLLLL
..L.......L.LL..LL..L.L....LLL.L....LL...L.L...L.....L...LL..LL....LL.....LL.L....L..............
LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLL.LL.LLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLL.LL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LL.......L...L..L.L.LL...LL...........LL.L...L.....LL.......LL....LLL.L.LLL..L.L.L.L...LL..LL....
LLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLL..LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLLLLLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLLLLLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLL
L....L.L.L...LL...LL.....L..L.LLLLLL.L...........L..LL.L....L.....LL..LL.L...L..LLL........L.LLL.
LLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLL.LLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL..LLLLLLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LL.L..................L..L..L..L..L...LL....LL.L......L..LL...LL...........LL....LL..L...L.......
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLL.LL.LLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.L.LLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLLL.LL.LLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLL..L.LLLLL
L...L.LL.....L...L....L...L...L..L.L..L..L..LL.L.LL..L....L.L.L..L.L.L.LL......LL.L.L.LLLLL...L.L
LLLL.L.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLLLL.LLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLL.L.LLLLLLLLLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL..LLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLLL.LLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLLLLLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLL
..L..L.....LLL.......LL....L...L..LLL..L.......L......L.L....L..L....LLL.LL.L.....LL...L..LLLL...
LLLLLL.LLLLL.LLLLL.LL.LLLLLL.LLLLLLLLLLLLLLLL..LLLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLLL.L.LLLL.LLLLLLL
LLL.LL.LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLLLLLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLL.LLL.LLL.LLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LL.LLLLLLLLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LL.LLLLLL..LLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLLL.LLLL.LLLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.L.LLLLLL.LLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLL
...LLLL.LL.L.L........LLL...L.LLL....L.L..LLL.L..L..L...L.L..L...LL..LL.L.LL..LLL.L....L....L.L..
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLL...LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLLL.LLLLL.LLLL.LLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLL.LLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLLLLL.LL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLL.LLLLLLLLLLL.LLLLLLLLL.LLLLLL.LLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLL..LLL.LLLLLLLLLLLLLLLLLLLL
.....L.L.LL.....L.L.LL.L...L....LLL........LL.L....LLL..LLL.L..LL..L......L..L...L.L.L.....L.L...
LLLLLLLLLLLLLLLLLL.LL.LLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLL.LLLLL..LLLLLLL
LLLLLL.LLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLL
LLLLL..LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLL
LLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLL.L.LL.LL.LLLLLLLLLLLLLL
LLLLLL.LLLLLLLLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLL
LLLLLLLLLLLL.LLLLL.LLLLLLLLL.LL.LLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLL
LLLLLL.LLLLL..LLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
LLLLLLLLLLLL.LLLL.LLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLLLLLLLLLL
LLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLL.L.LLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLLL.LL.LLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLLLLLLLLL.LLLLLLL
LLLLL.LLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLL.LLLLL.LLLLLL.LLLLLLL
"""
