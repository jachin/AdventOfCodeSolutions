app "day_2_part_2"
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
            games = fileContentStr |> Str.split "\n" |> List.keepOks parseGame

            gamesPower = List.map
                games
                (\game ->
                    game.red * game.blue * game.green
                )

            answer = gamesPower |> List.sum |> Num.toStr

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

Game : {
    number : I32,
    red : I32,
    blue : I32,
    green : I32,
    draws : List Draw,
}

Draw : {
    blue : I32,
    red : I32,
    green : I32,
}

parseGame : Str -> Result Game Str
parseGame = \inputStr ->
    parts = Str.split inputStr ":"
    when parts is
        [] -> Err "No game found"
        [_] -> Err "No game found"
        [label, data] ->
            draws = parseDraws data
            Ok {
                number: parseGameNumber label,
                red: List.map draws .red
                |> List.max
                |> Result.withDefault 0,
                blue: List.map draws .blue
                |> List.max
                |> Result.withDefault 0,
                green: List.map draws .green
                |> List.max
                |> Result.withDefault 0,
                draws: draws,
            }

        _ -> Err "Invalid game data"

parseGameNumber : Str -> I32
parseGameNumber = \inputStr ->
    when Str.split inputStr " " is
        [] ->
            -1

        [_] ->
            -1

        [_, intStr] ->
            Str.toI32 intStr |> Result.withDefault -1

        [..] -> -1

parseDraws : Str -> List Draw
parseDraws = \inputStr ->
    inputStr |> Str.split ";" |> List.map parseDraw

parseDraw : Str -> Draw
parseDraw = \inputStr ->
    drawData =
        inputStr
        |> Str.split ","
        |> List.map Str.trim
        |> List.map (\str -> Str.split str " ")
        |> List.join
        |> List.map Str.trim
        |> List.chunksOf 2

    draw = List.walk
        drawData
        {
            red: 0,
            blue: 0,
            green: 0,
        }
        (\d, data ->
            when data is
                [intStr, "blue"] ->
                    { d & blue: Str.toI32 intStr |> Result.withDefault 0 }

                [intStr, "red"] ->
                    { d & red: Str.toI32 intStr |> Result.withDefault 0 }

                [intStr, "green"] ->
                    { d & green: Str.toI32 intStr |> Result.withDefault 0 }

                _ ->
                    d
        )

    draw
