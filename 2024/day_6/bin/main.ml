open Day_6

let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

let find_guarded_spaces matrix =
  let visited_spaced = BatDynArray.create () in
  let current_matrix = ref (Some matrix) in
  while Option.is_some !current_matrix do
    match Matrix.generate_next_matrix matrix with
    | Some (next_matrix, guard_cords) ->
        (* print_newline (Matrix.print next_matrix); *)
        BatDynArray.add visited_spaced guard_cords;
        current_matrix := Some next_matrix
    | None -> current_matrix := None
  done;
  BatDynArray.to_list visited_spaced

let does_guard_loop matrix =
  let loop_detected log =
    if BatDynArray.length log < 6 then false
    else
      let tail_section = BatDynArray.sub log (BatDynArray.length log - 3) 3 in
      let log_as_str =
        log
        |> BatDynArray.map (fun (row, col) -> Printf.sprintf "(%i,%i)" row col)
        |> BatDynArray.to_list |> String.concat " "
      in
      (* print_endline log_as_str; *)
      let tail_section_as_str =
        tail_section
        |> BatDynArray.map (fun (row, col) -> Printf.sprintf "(%i,%i)" row col)
        |> BatDynArray.to_list |> String.concat " "
      in
      (* print_endline tail_section_as_str; *)
      BatString.find_all log_as_str tail_section_as_str
      |> BatList.of_enum |> List.length
      |> fun n -> n > 1
  in

  let visited_spaced = BatDynArray.create () in
  let current_matrix = ref (Some matrix) in
  let current_guard_cords = ref None in
  while Option.is_some !current_matrix && not (loop_detected visited_spaced) do
    try
      let next_matrix, guard_cords =
        Matrix.generate_next_matrix_2 matrix !current_guard_cords
      in

      current_guard_cords := Some guard_cords;
      (* print_newline (Matrix.print next_matrix); *)
      let cords, _ = guard_cords in
      BatDynArray.add visited_spaced cords;
      current_matrix := Some next_matrix
    with Matrix.Off_the_grid -> current_matrix := None
  done;
  loop_detected visited_spaced

(*Part 1 test*)
let () =
  read_file "data/example.txt"
  |> Matrix.build_from_string |> find_guarded_spaces |> BatList.unique
  |> List.length
  |> (fun x -> x + 1)
  |> string_of_int |> print_endline

(*Part 1*)
let () =
  read_file "data/input.txt" |> Matrix.build_from_string |> find_guarded_spaces
  |> BatList.unique |> List.length
  |> (fun x -> x + 1)
  |> string_of_int |> print_endline

(*Part 2 test*)
let () =
  let matrix = read_file "data/example.txt" |> Matrix.build_from_string in
  let guarded_spaces =
    matrix |> Matrix.deep_copy |> find_guarded_spaces |> BatList.unique
  in
  let obstruction_possibilities =
    guarded_spaces
    |> List.map (fun cords -> Matrix.copy_and_obstruct matrix cords)
  in
  (* List.iter Matrix.print obstruction_possibilities; *)
  obstruction_possibilities |> List.map does_guard_loop
  |> List.filter (fun x -> x)
  |> List.length
  |> (fun x -> x + 1)
  |> string_of_int |> print_endline

(*Part 2*)
let () =
  let matrix = read_file "data/input.txt" |> Matrix.build_from_string in
  let guarded_spaces =
    matrix |> Matrix.deep_copy |> find_guarded_spaces |> BatList.unique
  in
  let obstruction_possibilities =
    guarded_spaces
    |> List.map (fun cords -> Matrix.copy_and_obstruct matrix cords)
  in
  (* List.iter Matrix.print obstruction_possibilities; *)
  print_endline (List.length obstruction_possibilities |> string_of_int);
  obstruction_possibilities
  |> List.mapi (fun i m ->
         print_endline (string_of_int i);
         does_guard_loop m)
  |> List.filter (fun x -> x)
  |> List.length
  |> (fun x -> x + 1)
  |> string_of_int |> print_endline
