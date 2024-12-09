open Minttea
open Day_8

type puzzle = Part1Example | Part1 | Part2Example | Part2
type cords = int * int
type antenna = Antenna of (char * cords)
type antinodes = Antinodes of (char * cords)

type model = {
  puzzle : puzzle;
  answer : int option;
  example_input : string;
  input : string;
  antennas : antenna list;
  antinodes : antinodes list;
  map : Matrix.t;
}

let get_antenna_cords a = match a with Antenna (_, cords) -> cords
let get_antenna_label a = match a with Antenna (label, _) -> label

(* let get_distance_to_antenna cords antenna =
   let _, antenna_cords = antenna in
   Matrix.manhattan_distance cords antenna_cords *)

let is_antenna_same_type_but_different_location a b =
  let a_label = get_antenna_label a in
  let a_row, a_col = get_antenna_cords a in
  let b_label = get_antenna_label b in
  let b_row, b_col = get_antenna_cords b in
  a_label = b_label && a_row = b_row && a_col = b_col

let get_antenna_canidates antennas antenna =
  List.filter (is_antenna_same_type_but_different_location antenna) antennas

let is_antinode d1 d2 = d1 / 2 = d2 || d2 / 2 = d1

let is_antinode_at_cords_for_an_antenna cords antenna antennas =
  let antenna_cords = get_antenna_cords antenna in
  let distance = Matrix.manhattan_distance cords antenna_cords in
  let antenna_canidates = get_antenna_canidates antennas antenna in
  let distances_to_canidates =
    List.map
      (fun antenna_canidate ->
        let antenna_canidate_cords = get_antenna_cords antenna_canidate in
        Matrix.manhattan_distance antenna_canidate_cords antenna_cords)
      antenna_canidates
  in
  List.filter (is_antinode distance) distances_to_canidates
  |> List.is_empty |> not

let find_antinodes_at_cords cords antennas =
  List.map
    (fun antenna ->
      if is_antinode_at_cords_for_an_antenna cords antenna antennas then
        Some (Antinodes (get_antenna_label antenna, cords))
      else None)
    antennas
  |> List.filter_map (fun opt -> opt)

let build_matrix input = Matrix.build_from_string input

let build_antennas matrix =
  Matrix.find_antennas matrix |> List.map (fun (c, cords) -> Antenna (c, cords))

let find_antinodes matrix antennas =
  let antinodes = BatDynArray.create () in
  Matrix.iter
    (fun cords _ ->
      find_antinodes_at_cords cords antennas |> fun a ->
      BatDynArray.add antinodes a)
    matrix;
  BatDynArray.to_list antinodes |> List.concat |> BatList.unique

let solve_part_1 antinodes = List.length antinodes

let initial_model =
  {
    puzzle = Part1Example;
    answer = None;
    example_input = File_helpers.read_file "./data/example.txt";
    input = File_helpers.read_file "./data/input.txt";
    antennas = [];
    antinodes = [];
    map = Matrix.build_from_string "";
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
      let input =
        match model.puzzle with
        | Part1Example -> model.example_input
        | Part1 -> model.input
        | Part2Example -> model.example_input
        | Part2 -> model.input
      in
      let map = build_matrix input in
      let antennas = build_antennas map in
      let antinodes = find_antinodes map antennas in
      let answer =
        match model.puzzle with
        | Part1Example -> Some (solve_part_1 antinodes)
        | Part1 -> Some (solve_part_1 antinodes)
        | _ -> None
      in
      ({ model with answer; map; antennas; antinodes }, Command.Noop)
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
  let antennas =
    model.antennas
    |> List.map (fun a ->
           match a with
           | Antenna (c, (row, col)) -> Printf.sprintf "%c (%i, %i)" c row col)
    |> String.concat " | "
  in
  let antinodes =
    model.antinodes
    |> List.map (fun a ->
           match a with
           | Antinodes (c, (row, col)) -> Printf.sprintf "%c (%i, %i)" c row col)
    |> String.concat "  "
  in
  Format.sprintf
    {|

      What Puzzle Should We Solve
%s

Press q to quit.

Antennas: %s

Antinodes: %s

Map
---
%s

Answer: %s

  |}
    options antennas antinodes
    (Matrix.to_string model.map)
    (match model.answer with Some a -> string_of_int a | None -> "???")

let app = Minttea.app ~init ~update ~view ()
let () = Minttea.start app ~initial_model
