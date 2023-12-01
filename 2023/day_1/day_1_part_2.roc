app "day_1_part_2"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.6.0/QOQW08n38nHHrVVkJNiPIjzjvbR3iMjXeFY5w1aT46w.tar.br" }
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
            answer = (findCalibrationValues fileContentStr) |> Num.toStr

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

isDigit : Str -> Bool
isDigit = \inputStr ->
    inputStr |> Str.toI32 |> Result.isOk

collaposeNumbers : List Str -> I32
collaposeNumbers = \digits ->
    when List.first digits is
        Err ListWasEmpty ->
            0

        Ok f ->
            when List.last digits is
                Err ListWasEmpty ->
                    0

                Ok l ->
                    when Str.concat f l |> Str.toI32 is
                        Err InvalidNumStr ->
                            0

                        Ok a ->
                            a

findCalibrationValue : Str -> I32
findCalibrationValue = \inputStr ->

    numberChomper "" inputStr
    |> Str.graphemes
    |> collaposeNumbers




findCalibrationValues : Str -> I32
findCalibrationValues = \inputStr ->
    Str.split inputStr "\n" |> List.map findCalibrationValue |> List.sum


numberChomper : Str, Str -> Str
numberChomper = \output, inputStr ->
    if Str.isEmpty inputStr then
        output
    else if Str.startsWith inputStr "one" then
        numberChomper (Str.concat output "1") (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
    else if Str.startsWith inputStr "two" then
        numberChomper (Str.concat output "2") (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
    else if Str.startsWith inputStr "three" then
        numberChomper (Str.concat output "3") (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
    else if Str.startsWith inputStr "four" then
        numberChomper (Str.concat output "4") (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
    else if Str.startsWith inputStr "five" then
        numberChomper (Str.concat output "5") (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
    else if Str.startsWith inputStr "six" then
        numberChomper (Str.concat output "6") (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
    else if Str.startsWith inputStr "seven" then
        numberChomper (Str.concat output "7") (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
    else if Str.startsWith inputStr "eight" then
        numberChomper (Str.concat output "8") (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
    else if Str.startsWith inputStr "nine" then
        numberChomper (Str.concat output "9") (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
    else
        when Str.graphemes inputStr |> List.first is
            Err ListWasEmpty ->
                output

            Ok g ->
                if isDigit g then
                    numberChomper (Str.concat output g) (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )
                else
                    numberChomper (output) (Str.graphemes inputStr |> List.dropFirst 1 |> Str.joinWith "" )

        