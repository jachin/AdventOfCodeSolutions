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
        print_newline (Matrix.print next_matrix);
        BatDynArray.add visited_spaced guard_cords;
        current_matrix := Some next_matrix
    | None -> current_matrix := None
  done;
  BatDynArray.to_list visited_spaced

let () =
  read_file "data/example.txt"
  |> Matrix.build_from_string |> find_guarded_spaces |> BatList.unique
  |> List.length
  |> (fun x -> x + 1)
  |> string_of_int |> print_endline

let () =
  read_file "data/input.txt" |> Matrix.build_from_string |> find_guarded_spaces
  |> BatList.unique |> List.length
  |> (fun x -> x + 1)
  |> string_of_int |> print_endline
