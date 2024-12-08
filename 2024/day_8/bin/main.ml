open Minttea
open Day_8

let solve_part_1 input =
  let _ = Matrix.build_from_string input in
  0

type puzzle = Part1Example | Part1 | Part2Example | Part2

type model = {
  puzzle : puzzle;
  answer : int option;
  example_input : string;
  input : string;
}

let initial_model =
  {
    puzzle = Part1Example;
    answer = None;
    example_input = File_helpers.read_file "./data/example.txt";
    input = File_helpers.read_file "./data/input.txt";
  }

let init _model = Command.Noop

let next_puzzle p =
  match p with
  | Part1Example -> Part1
  | Part1 -> Part2Example
  | Part2Example -> Part2
  | Part2 -> Part1Example

let previous_puzzle p =
  match p with
  | Part1Example -> Part2
  | Part1 -> Part1Example
  | Part2Example -> Part1
  | Part2 -> Part2Example

let update event model =
  match event with
  | Event.KeyDown (Key "q" | Escape) -> (model, Command.Quit)
  | Event.KeyDown (Up | Key "k") ->
      let puzzle = previous_puzzle model.puzzle in
      ({ model with puzzle }, Command.Noop)
  | Event.KeyDown (Down | Key "j") ->
      let puzzle = next_puzzle model.puzzle in
      ({ model with puzzle }, Command.Noop)
  | Event.KeyDown Enter ->
      let answer =
        match model.puzzle with
        | Part1Example -> Some (solve_part_1 model.example_input)
        | Part1 -> Some (solve_part_1 model.input)
        | _ -> None
      in
      ({ model with answer }, Command.Noop)
  | _ -> (model, Command.Noop)

let view model =
  (* we create our options by mapping over them *)
  let options =
    [
      ("Part 1 Example: "
      ^ match model.puzzle with Part1Example -> "[x]" | _ -> "[ ]");
      ("Part 1: " ^ match model.puzzle with Part1 -> "[x]" | _ -> "[ ]");
      ("Part 2 Example: "
      ^ match model.puzzle with Part2Example -> "[x]" | _ -> "[ ]");
      ("Part 2: " ^ match model.puzzle with Part2 -> "[x]" | _ -> "[ ]");
    ]
    |> String.concat "\n"
  in
  Format.sprintf
    {|

      What Puzzle Should We Solve
%s

Press q to quit.

Answer: %s

  |}
    options
    (match model.answer with Some a -> string_of_int a | None -> "???")

let app = Minttea.app ~init ~update ~view ()
let () = Minttea.start app ~initial_model
