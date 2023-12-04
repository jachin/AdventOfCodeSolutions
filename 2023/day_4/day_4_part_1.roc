app "day_4_part_1"
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
            cards = List.keepOks lines parseCard

            cardValues = List.map cards cardValue

            answer = List.sum cardValues |> Num.toStr

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

Card : {
    numbers : Set I32,
    winners : Set I32,
}

parseNumbers : Str -> List I32
parseNumbers = \inputStr ->
    Str.split inputStr " " |> List.map Str.trim |> List.keepOks Str.toI32

parseCard : Str -> Result Card Str
parseCard = \inputStr ->
    when inputStr |> Str.split ":" is
        [_, allTheNumbersStr] ->
            when allTheNumbersStr |> Str.split "|" is
                [numbersStr, winnersStr] ->
                    Ok {
                        numbers: parseNumbers numbersStr |> Set.fromList,
                        winners: parseNumbers winnersStr |> Set.fromList,
                    }

                _ ->
                    Err "Invalid card"

        _ ->
            Err "Invalid card"
double = \n, value ->
    if n <= 1 then
        value
    else
        double (n - 1) value * 2

cardValue : Card -> I32
cardValue = \card ->
    numberOfMatches = Set.intersection card.numbers card.winners |> Set.len |> Num.toI32
    if numberOfMatches == 0 then
        0
    else
        double numberOfMatches 1
