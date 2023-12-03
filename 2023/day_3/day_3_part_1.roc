app "day_3_part_1"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.7.0/bkGby8jb0tmZYsy2hg1E_B2QrCgcSTxdUlHtETwm5m4.tar.br" }
    imports [
        pf.Stdout,
        pf.Stderr,
        pf.File,
        pf.Path,
        pf.Task,
        pf.Arg,
    ]
    provides [main] to pf

main =
    finalTask =
        # try to read the first command line argument
        pathArg <- Task.await readFirstArgT

        readFileToStr (Path.fromStr pathArg)

    finalResult <- Task.attempt finalTask

    when finalResult is
        Err ZeroArgsGiven ->
            {} <- Stderr.line "Error ZeroArgsGiven:\n\tI expected one argument, but I got none.\n\tRun the app like this: `roc command-line-args.roc -- path/to/input.txt`" |> Task.await

            Task.err 1 # 1 is an exit code to indicate failure

        Err (ReadFileErr errMsg) ->
            indentedErrMsg = indentLines errMsg
            {} <- Stderr.line "Error ReadFileErr:\n\(indentedErrMsg)" |> Task.await

            Task.err 1 # 1 is an exit code to indicate failure

        Ok fileContentStr ->
            lines = fileContentStr |> Str.split "\n"

            schematic = parseInput lines

            dbg
                schematic.symbols

            symbols = schematic.symbols |> List.map .cords |> Set.fromList

            actualPartNumbers =
                schematic.parts
                |> List.dropIf
                    (\part ->
                        agacentSpaces = Set.fromList part.agacentSpaces
                        Set.intersection agacentSpaces symbols |> Set.isEmpty
                    )
                |> List.map .number

            dbg
                actualPartNumbers

            answer = List.sum actualPartNumbers |> Num.toStr
            Stdout.line "answer: \(answer)"

# Task to read the first CLI arg (= Str)
readFirstArgT : Task.Task Str [ZeroArgsGiven]_
readFirstArgT =
    # read all command line arguments
    args <- Arg.list |> Task.await

    # get the second argument, the first is the executable's path
    List.get args 1 |> Result.mapErr (\_ -> ZeroArgsGiven) |> Task.fromResult

# reads a file and puts all lines in one Str
readFileToStr : Path.Path -> Task.Task Str [ReadFileErr Str]_
readFileToStr = \path ->
    path
    |> File.readUtf8 # Make a nice error message
    |> Task.mapErr
        (\fileReadErr ->
            pathStr = Path.display path
            # TODO use FileReadErrToErrMsg when it is implemented: https://github.com/roc-lang/basic-cli/issues/44
            when fileReadErr is
                FileReadErr _ readErr ->
                    readErrStr = File.readErrToStr readErr
                    ReadFileErr "Failed to read file at:\n\t\(pathStr)\n\(readErrStr)"

                FileReadUtf8Err _ _ ->
                    ReadFileErr "I could not read the file:\n\t\(pathStr)\nIt contains charcaters that are not valid UTF-8:\n\t- Check if the file is encoded using a different format and convert it to UTF-8.\n\t- Check if the file is corrupted.\n\t- Find the characters that are not valid UTF-8 and fix or remove them."
        )

# indent all lines in a Str with a single tab
indentLines : Str -> Str
indentLines = \inputStr ->
    Str.split inputStr "\n"
    |> List.map (\line -> Str.concat "\t" line)
    |> Str.joinWith "\n"

Cords : {
    x : I32,
    y : I32,
}

PartNumber : {
    number : Nat,
    agacentSpaces : List Cords,
}

Symbol : {
    symbol : Str,
    cords : Cords,
}

Schematic : {
    parts : List PartNumber,
    symbols : List Symbol,
}

parseInput : List Str -> Schematic
parseInput = \inputLines ->
    List.walkWithIndex
        inputLines
        { parts: [], symbols: [] }
        (\schematicY, line, y ->
            r = List.walkWithIndex
                (Str.graphemes line)
                { parts: schematicY.parts, symbols: schematicY.symbols, currentNumber: "" }
                (\schematicX, char, x ->
                    when char is
                        "." ->
                            if Str.isEmpty schematicX.currentNumber then
                                schematicX
                            else
                                newPartNumber = Str.toNat schematicX.currentNumber
                                newPart = Result.map
                                    newPartNumber
                                    (\partNumber -> {
                                        number: partNumber,
                                        agacentSpaces: makeListOfAgacentCords partNumber { x: Num.toI32 x, y: Num.toI32 y },
                                    })
                                { schematicX &
                                    parts: List.appendIfOk schematicX.parts newPart,
                                    currentNumber: "",
                                }

                        "0" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "0" }

                        "1" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "1" }

                        "2" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "2" }

                        "3" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "3" }

                        "4" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "4" }

                        "5" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "5" }

                        "6" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "6" }

                        "7" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "7" }

                        "8" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "8" }

                        "9" ->
                            { schematicX & currentNumber: Str.concat schematicX.currentNumber "9" }

                        symbol ->
                            if Str.isEmpty schematicX.currentNumber then
                                newSymbol = {
                                    symbol: symbol,
                                    cords: { x: Num.toI32 x, y: Num.toI32 y },
                                }
                                { schematicX &
                                    symbols: List.append schematicX.symbols newSymbol,
                                }
                            else
                                newPartNumber = Str.toNat schematicX.currentNumber
                                newPart = Result.map
                                    newPartNumber
                                    (\partNumber -> {
                                        number: partNumber,
                                        agacentSpaces: makeListOfAgacentCords partNumber { x: Num.toI32 x, y: Num.toI32 y },
                                    })
                                { schematicX &
                                    parts: List.appendIfOk schematicX.parts newPart,
                                    symbols: List.append schematicX.symbols { symbol: symbol, cords: { x: Num.toI32 x, y: Num.toI32 y } },
                                    currentNumber: "",
                                }
                )
            { parts: r.parts, symbols: r.symbols }
        )

makeListOfAgacentCords : Nat, Cords -> List Cords
makeListOfAgacentCords = \number, cords ->
    startX = cords.x - (Num.toStr number |> Str.graphemes |> List.len |> Num.toI32)
    List.range { start: At startX, end: At cords.x }
    |> List.map (\x -> { x: x, y: cords.y })
    |> List.map generateCordsAroundPoint
    |> List.join
    |> Set.fromList
    |> Set.toList

generateCordsAroundPoint : Cords -> List Cords
generateCordsAroundPoint = \cords -> [
    { x: cords.x - 1, y: cords.y - 1 }, # NW
    { x: cords.x, y: cords.y - 1 }, # N
    { x: cords.x - 1, y: cords.y + 1 }, # NE
    { x: cords.x + 1, y: cords.y }, # E
    { x: cords.x + 1, y: cords.y + 1 }, # SE
    { x: cords.x, y: cords.y + 1 }, # S
    { x: cords.x + 1, y: cords.y - 1 }, # SW
    { x: cords.x - 1, y: cords.y },
    # W
]
