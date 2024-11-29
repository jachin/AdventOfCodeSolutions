let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

let is_allowed_char allowed_chars c =
  String.contains allowed_chars c

let first_and_last_char s =
  let len = String.length s in
  if len = 0 then
    ""
  else if len = 1 then
    s ^ s
  else
    let first_char = String.get s 0 in
    let last_char = String.get s (len - 1) in
    String.make 1 first_char ^ String.make 1 last_char

let filter_string allowed_chars input =
  let chars = String.to_seq input in
  let filtered_chars = Seq.filter (is_allowed_char allowed_chars) chars in
  String.of_seq filtered_chars

let string_to_int s =
  try
    Some (int_of_string s)
  with
  | Failure _ -> None

let handle_line l =
  let allowed_chars = "1234567890" in
  let filtered_string = filter_string allowed_chars l in
  let number_str = first_and_last_char filtered_string in
  string_to_int number_str

let map_lines f s =
  let lines = String.split_on_char '\n' s in
  List.map f lines

let answer = List.fold_left (fun acc v ->
  match v with
    | Some i -> acc + i
    | None -> acc
) 0

let recoverCalibrationValues input =
  map_lines handle_line input
  |> answer
  |> string_of_int


let replace_words_with_numbers input =
  (* Handle word replacement logic *)
  let replace_if_match output_stack =
    match List.rev output_stack with
    | 'o' :: 'n' :: 'e' :: rest -> ('1' :: rest)
    | 't' :: 'w' :: 'o' :: rest -> ('2' :: rest)
    | 't' :: 'h' :: 'r' :: 'e' :: 'e' :: rest -> ('3' :: rest)
    | 'f' :: 'o' :: 'u' :: 'r' :: rest -> ('4' :: rest)
    | 'f' :: 'i' :: 'v' :: 'e' :: rest -> ('5' :: rest)
    | 's' :: 'i' :: 'x' :: rest -> ('6' :: rest)
    | 's' :: 'e' :: 'v' :: 'e' :: 'n' :: rest -> ('7' :: rest)
    | 'e' :: 'i' :: 'g' :: 'h' :: 't' :: rest -> ('8' :: rest)
    | 'n' :: 'i' :: 'n' :: 'e' :: rest -> ('9' :: rest)
    | _ -> List.rev output_stack  (* No match, leave unchanged *)
  in

  (* Main loop to process the input and build output *)
  let rec process input_stack output_stack =
    match input_stack with
    | [] -> List.rev output_stack  (* If input is empty, output is complete *)
    | c :: rest ->
      let new_output_stack = c :: output_stack in
      let filtered_output = replace_if_match new_output_stack in
      process rest filtered_output
  in

  let input_chars = String.to_seq input |> List.of_seq in
  let output_chars = process input_chars [] in
  String.of_seq (List.to_seq output_chars)

let recoverMoreCalibrationValues input =
  replace_words_with_numbers input
  |> (fun x -> print_endline ("After replaceWordsWithNumbers: " ^ x); x)
  |> map_lines handle_line
  |> answer
  |> string_of_int


let () = print_endline (recoverCalibrationValues (read_file "data/part_1_example.txt"))
let () = print_endline (recoverCalibrationValues (read_file "data/input.txt"))

let () = print_endline (recoverMoreCalibrationValues (read_file "data/part_2_example.txt"))
(* let () = print_endline (recoverMoreCalibrationValues (read_file "data/input.txt")) *)
