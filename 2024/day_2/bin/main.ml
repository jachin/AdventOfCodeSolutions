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



let remove_at_index lst index =
  let rec remove i acc = function
    | [] -> List.rev acc  (* Reverse the accumulated list to maintain order *)
    | x :: xs ->
        if i = index then
          List.rev_append acc xs  (* Skip the current element and append the rest *)
        else
          remove (i + 1) (x :: acc) xs  (* Include the current element and continue *)
  in
  remove 0 [] lst


let generate_alterative_reports report =
  List.mapi (fun i _ -> remove_at_index report i ) report


let identity x = x

let any lst =
  List.filter identity lst |> List.length > 0

let is_report_mostly_safe report =
  if is_report_safe 0 report then
    true
  else
    let alternative_reports = generate_alterative_reports report in
      List.map (is_report_safe 0) alternative_reports |> any


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
  |> List.filter is_report_mostly_safe
  |> List.length
  |> string_of_int
  |> print_endline

(* Part 2 *)
let () = read_file "data/input.txt"
  |> build_reports
  |> List.filter is_report_mostly_safe
  |> List.length
  |> string_of_int
  |> print_endline
