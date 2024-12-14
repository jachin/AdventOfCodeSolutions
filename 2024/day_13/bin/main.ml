open Cmdliner
open Day_13

type cords = { point_x : int; point_y : int }
type move_claw = { x : int; y : int }

type claw_machine = {
  button_a : move_claw;
  button_b : move_claw;
  prize : cords;
}

let split_on_blank_lines input =
  let blank_line_pattern = Str.regexp "\n[ \t\r]*\n" in
  Str.split blank_line_pattern input

let button_a_regexp = Str.regexp {|Button A: X\+\([0-9]+\), Y\+\([0-9]+\)|}
let button_b_regexp = Str.regexp {|Button B: X\+\([0-9]+\), Y\+\([0-9]+\)|}
let prize_regexp = Str.regexp {|Prize: X=\([0-9]+\), Y=\([0-9]+\)|}

let try_button_a_match input =
  try
    ignore (Str.search_forward button_a_regexp input 0);
    let x = Str.matched_group 1 input in
    let y = Str.matched_group 2 input in
    Some { x = int_of_string x; y = int_of_string y }
  with Not_found ->
    Logs.err (fun m -> m "No button for A: \n%s\n\n" input);
    None

let try_button_b_match input =
  try
    ignore (Str.search_forward button_b_regexp input 0);
    let x = Str.matched_group 1 input in
    let y = Str.matched_group 2 input in
    Some { x = int_of_string x; y = int_of_string y }
  with Not_found ->
    Logs.err (fun m -> m "No button for B: \n%s\n\n" input);
    None

let try_prize_match input =
  try
    ignore (Str.search_forward prize_regexp input 0);
    let x = Str.matched_group 1 input in
    let y = Str.matched_group 2 input in
    Some { point_x = int_of_string x; point_y = int_of_string y }
  with Not_found ->
    Logs.err (fun m -> m "No Prize: \n%s\n\n" input);
    None

let map3_options f o1 o2 o3 =
  match (o1, o2, o3) with
  | Some x1, Some x2, Some x3 -> Some (f x1 x2 x3)
  | _ -> None

let parse_machine_str input =
  map3_options
    (fun button_a button_b prize -> { button_a; button_b; prize })
    (try_button_a_match input) (try_button_b_match input)
    (try_prize_match input)

let parse_input input = split_on_blank_lines input |> List.map parse_machine_str

let test_solution claw_machine a_button_pushes b_button_pushes =
  claw_machine.prize.point_x
  = (claw_machine.button_a.x * a_button_pushes)
    + (claw_machine.button_b.x * b_button_pushes)
  && claw_machine.prize.point_y
     = (claw_machine.button_a.y * a_button_pushes)
       + (claw_machine.button_b.y * b_button_pushes)

let cartesian_product list1 list2 =
  List.fold_left
    (fun acc x -> List.fold_left (fun acc y -> (x, y) :: acc) acc list2)
    [] list1

let range start stop = List.init (stop - start + 1) (fun i -> start + i)

let solve_claw_machine claw_machine =
  let solutions =
    cartesian_product (range 1 100) (range 1 100)
    |> List.filter (fun (button_a_pushes, button_b_pushs) ->
           test_solution claw_machine button_a_pushes button_b_pushs)
  in
  if List.is_empty solutions then None else Some (List.hd solutions)

let count_tokens (button_a_pushes, button_b_pushs) =
  (button_a_pushes * 3) + button_b_pushs

let solve_part_1 input =
  Logs.info (fun m -> m "Solving part 1");
  let result =
    input |> parse_input
    |> List.filter_map (fun x -> x)
    |> List.map solve_claw_machine
    |> List.filter_map (fun x -> x)
    |> List.map count_tokens |> List.fold_left ( + ) 0 |> string_of_int
    |> print_endline
  in
  ignore result;
  ()

let solve_part_2 input =
  Logs.info (fun m -> m "Solving part 2");
  let result = parse_machine_str input in
  ignore result;
  ()

let solve_puzzles () =
  File_helpers.read_file "./data/example.txt" |> solve_part_1;
  File_helpers.read_file "./data/input.txt" |> solve_part_1;
  File_helpers.read_file "./data/example.txt" |> solve_part_2;
  File_helpers.read_file "./data/input.txt" |> solve_part_2

let setup_log style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ());
  ()

let setup_log =
  Term.(const setup_log $ Fmt_cli.style_renderer () $ Logs_cli.level ())

let main () =
  let info = Cmd.info "day_9" in
  let cmd = Cmd.v info Term.(const solve_puzzles $ setup_log) in
  exit (Cmd.eval cmd)

let () = main ()
