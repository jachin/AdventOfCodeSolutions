let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content


let split_on_newline s =
  let regexp = Str.regexp "[\n\r]+" in
  Str.split regexp s


let split_on_whitespace s =
  let regexp = Str.regexp "[ \t]+" in
  Str.split regexp s

(* let report_to_string report =
  report |> List.map string_of_int |> String.concat " " *)

let build_reports input =
  input |> split_on_newline
    |> List.map (fun s -> s |> split_on_whitespace |> List.map int_of_string )

let is_increasing problem_limit report =
  let (number_of_problems, _) = List.fold_left (fun acc v ->
    let (number_of_problems, last_value) = acc in
    if last_value = -1 || v > last_value && abs (v - last_value) > 0 && abs (v - last_value) < 4 then
      (number_of_problems, v)
    else
      (number_of_problems + 1, v)
  ) (0, -1) report in
  number_of_problems <= problem_limit

let is_decreasing problem_limit report =
  report |> List.rev |> is_increasing problem_limit

let is_report_safe problem_limit report =
  let is_safe = is_increasing problem_limit report || is_decreasing problem_limit report  in
  is_safe

(* Part 1 test *)
let () = read_file "data/example.txt"
  |> build_reports
  |> List.filter (is_report_safe 0)
  |> List.length
  |> string_of_int
  |> print_endline

(* Part 1 *)
let () = read_file "data/input.txt"
  |> build_reports
  |> List.filter (is_report_safe 0)
  |> List.length
  |> string_of_int
  |> print_endline

(* Part 2 test *)
let () = read_file "data/example.txt"
  |> build_reports
  |> List.filter (is_report_safe 1)
  |> List.length
  |> string_of_int
  |> print_endline

(* Part 2 *)
let () = read_file "data/input.txt"
  |> build_reports
  |> List.filter (is_report_safe 1)
  |> List.length
  |> string_of_int
  |> print_endline
