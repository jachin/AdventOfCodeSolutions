module Day3 exposing (..)

import Browser
import Html exposing (Html, div, h1, p, text)
import List.Extra
import Set


main =
    Browser.sandbox { init = init, update = update, view = view }


init : Model
init =
    { test1Part1 = test1
    , test2Part1 = test2
    , answerPart1 = part1
    }


type alias Model =
    { test1Part1 : String
    , test2Part1 : String
    , answerPart1 : String
    }


update : () -> Model -> Model
update _ model =
    model


view : Model -> Html ()
view model =
    div []
        [ h1 []
            [ text "Day 3" ]
        , p [] [ text model.test1Part1 ]
        , p [] [ text model.test2Part1 ]
        , p [] [ text model.answerPart1 ]
        ]


findIntersections wire1Data wire2Data =
    let
        wire1 =
            parseData wire1Data |> List.foldl traceWire [] |> Set.fromList

        wire2 =
            parseData wire2Data |> List.foldl traceWire [] |> Set.fromList
    in
    Set.intersect wire1 wire2


findClosetIntersection wire1Data wire2Data =
    let
        intersections =
            findIntersections wire1Data wire2Data

        calculateDistance ( x, y ) =
            abs x + abs y

        distances =
            Set.toList intersections |> List.map calculateDistance
    in
    List.sort distances |> List.head |> Maybe.withDefault 0 |> String.fromInt


findPointWireLength ( xG, yG ) grid length =
    let
        ( x, y ) =
            case List.head grid of
                Just p ->
                    p

                Nothing ->
                    Debug.todo "wat"

        restOfPoints =
            List.tail grid
    in
    if xG == x && yG == y then
        length

    else
        findPointWireLength ( xG, yG ) restOfPoints length + 1


test1Wire1 =
    "R75,D30,R83,U83,L12,D49,R71,U7,L72"


test1Wire2 =
    "U62,R66,U55,R34,D71,R55,D58,R83"


test1 =
    findClosetIntersection test1Wire1 test1Wire2


test2Wire1 =
    "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"


test2Wire2 =
    "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"


test2 =
    findClosetIntersection test2Wire1 test2Wire2


actualDataWire1 =
    "R1010,D422,L354,U494,L686,U894,R212,U777,L216,U9,L374,U77,R947,U385,L170,U916,R492,D553,L992,D890,L531,U360,R128,U653,L362,U522,R817,U198,L126,D629,L569,U300,L241,U145,R889,D196,L450,D576,L319,D147,R985,U889,L941,U837,L608,D77,L864,U911,L270,D869,R771,U132,L249,U603,L36,D328,L597,U992,L733,D370,L947,D595,L308,U536,L145,U318,R55,D773,R175,D505,R483,D13,R780,U778,R445,D107,R490,U245,L587,U502,R446,U639,R150,U35,L455,D522,R866,U858,R394,D975,R513,D378,R58,D646,L374,D675,R209,U228,R530,U543,L480,U677,L912,D164,L573,U587,L784,D626,L994,U250,L215,U985,R684,D79,L877,U811,L766,U617,L665,D246,L408,U800,L360,D272,L436,U138,R240,U735,L681,U68,L608,D59,R532,D808,L104,U968,R887,U819,R346,U698,L317,U582,R516,U55,L303,U607,L457,U479,L510,D366,L583,U519,R878,D195,R970,D267,R842,U784,R9,D946,R833,D238,L232,D94,L860,D47,L346,U951,R491,D745,R849,U273,R263,U392,L341,D808,R696,U326,R886,D296,L865,U833,R241,U644,R729,D216,R661,D712,L466,D699,L738,U5,L556,D693,R912,D13,R48,U63,L877,U628,L689,D929,R74,U924,R612,U153,R417,U425,L879,D378,R79,D248,L3,U519,R366,U281,R439,D823,R149,D668,R326,D342,L213,D735,R504,U265,L718,D842,L565,U105,L214,U963,R518,D681,R642,U170,L111,U6,R697,U572,R18,U331,L618,D255,R534,D322,L399,U595,L246,U651,L836,U757,R417,D795,R291,U759,L568,U965,R828,D570,R350,U317,R338,D173,L74,D833,L650,D844,L70,U913,R594,U407,R674,D684,L481,D564,L128,D277,R851,D274,L435,D582,R469,U729,R387,D818,R443,U504,R414,U8,L842,U845,R275,U986,R53,U660,R661,D225,R614,U159,R477"


actualDataWire2 =
    "L1010,D698,R442,U660,L719,U702,L456,D86,R938,D177,L835,D639,R166,D285,L694,U468,L569,D104,L234,D574,L669,U299,L124,D275,L179,D519,R617,U72,L985,D248,R257,D276,L759,D834,R490,U864,L406,U181,R911,U873,R261,D864,R260,U759,R648,U158,R308,D386,L835,D27,L745,U91,R840,U707,R275,U543,L663,U736,L617,D699,R924,U103,R225,U455,R708,U319,R569,U38,R315,D432,L179,D975,R519,D546,L295,U680,L685,U603,R262,D250,R7,U171,R261,U519,L832,U534,L471,U431,L474,U886,R10,D179,L79,D555,R452,U452,L832,U863,L367,U538,L237,D160,R441,U605,R942,U259,L811,D552,R646,D353,L225,D94,L35,D307,R752,U23,R698,U610,L379,D932,R698,D751,R178,D347,R325,D156,R471,D555,R558,D593,R773,U2,L955,U764,L735,U438,R364,D640,L757,U534,R919,U409,R361,U407,R336,D808,R877,D648,R610,U198,R340,U94,R795,D667,R811,U975,L965,D224,R565,D681,L64,U567,R621,U922,L665,U329,R242,U592,L727,D481,L339,U402,R213,D280,R656,U169,R976,D962,L294,D505,L251,D689,L497,U133,R230,D441,L90,D220,L896,D657,L500,U331,R502,U723,R762,D613,L447,D256,L226,U309,L935,U384,L740,D459,R309,D707,R952,D747,L304,D105,R977,D539,R941,D21,R291,U216,R132,D543,R515,U453,L854,D42,R982,U102,L469,D639,R559,D68,R302,U734,R980,D214,R107,D191,L730,D793,L63,U17,R807,U196,R412,D592,R330,D941,L87,D291,L44,D94,L272,D780,R968,U837,L712,D704,R163,U981,R537,U778,R220,D303,L196,D951,R163,D446,R11,D623,L72,D778,L158,U660,L189,D510,L247,D716,L89,U887,L115,U114,L36,U81,R927,U293,L265,U183,R331,D267,R745,D298,L561,D918,R299,U810,L322,U679,L739,D854,L581,U34,L862,D779,R23"


pointsAreEqual : ( int, int ) -> ( int, int ) -> Bool
pointsAreEqual ( x1, y1 ) ( x2, y2 ) =
    x1 == x2 && y1 == y2


part1 =
    findClosetIntersection actualDataWire1 actualDataWire2


part2 =
    let
        grid1 =
            parseData actualDataWire1 |> List.foldl traceWire []

        grid2 =
            parseData actualDataWire2 |> List.foldl traceWire []

        intersections =
            Set.intersect (Set.fromList grid1) (Set.fromList grid2) |> Set.toList

        wireLength p =
            let
                l1 =
                    List.Extra.findIndex (pointsAreEqual p) grid1

                l2 =
                    List.Extra.findIndex (pointsAreEqual p) grid2
            in
            Maybe.map2 (\a b -> a + b) l1 l2
    in
    List.map wireLength intersections |> List.maximum


type WireDirection
    = Up Int
    | Right Int
    | Down Int
    | Left Int


stringToWireDirection s =
    let
        parseLength str =
            String.dropLeft 1 str
                |> String.toInt
                |> Maybe.withDefault 0
    in
    case String.left 1 s of
        "U" ->
            Up (parseLength s)

        "R" ->
            Right (parseLength s)

        "D" ->
            Down (parseLength s)

        "L" ->
            Left (parseLength s)

        _ ->
            Debug.todo "Invalid direction"


parseData : String -> List WireDirection
parseData s =
    String.split "," s |> List.map stringToWireDirection


traceWire : WireDirection -> List ( Int, Int ) -> List ( Int, Int )
traceWire wireDirection grid =
    let
        ( x, y ) =
            List.Extra.last grid |> Maybe.withDefault ( 0, 0 )
    in
    case wireDirection of
        Up int ->
            List.range 1 int |> List.map (\y1 -> ( x, y + y1 )) |> List.append grid

        Right int ->
            List.range 1 int |> List.map (\x1 -> ( x + x1, y )) |> List.append grid

        Down int ->
            List.range 1 int |> List.map (\y1 -> ( x, y - y1 )) |> List.append grid

        Left int ->
            List.range 1 int |> List.map (\x1 -> ( x - x1, y )) |> List.append grid
