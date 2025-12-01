open Minttea
open Batteries

type cords = { x_pos : int; y_pos : int }
type velocity = { x_direction : int; y_direction : int }
type robot = { position : cords; velocities : velocity }
type model = { robots : robot list }

let initial_model = { robots = [] }

let input_data_regexp =
  Str.regexp {|p=\([0-9]+\),\([0-9]+\) v=\([0-9]+\),\([0-9]+\)|}

let parse_robot line =
  if Str.string_match input_data_regexp line 0 then
    let x_pos = int_of_string (Str.matched_group 1 line) in
    let y_pos = int_of_string (Str.matched_group 2 line) in
    let x_direction = int_of_string (Str.matched_group 3 line) in
    let y_direction = int_of_string (Str.matched_group 4 line) in
    Some
      { position = { x_pos; y_pos }; velocities = { x_direction; y_direction } }
  else None

let read_robot_data_file (filename : string) : robot list =
  let input = BatFile.open_in filename in
  try BatIO.lines_of input |> BatEnum.filter_map parse_robot |> List.of_enum
  with e ->
    BatIO.close_in input;
    raise e

let init _model = Command.Noop

let update event model =
  match event with
  | Event.KeyDown Enter ->
      let robots = read_robot_data_file "./data/example.txt" in
      ({ robots }, Command.Noop)
  | _ -> (model, Command.Noop)

let view _ = Format.sprintf {|
      Go Robots!
      |}

let app = Minttea.app ~init ~update ~view ()
let () = Minttea.start app ~initial_model
let () = ignore (read_robot_data_file "./data/example.txt")
