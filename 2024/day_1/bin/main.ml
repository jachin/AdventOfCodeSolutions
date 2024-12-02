let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content


let split_on_whitespace_and_newline s =
  let regexp = Str.regexp "[ \t\n\r]+" in  (* Define a regular expression for space, tabs, and newlines *)
  Str.split regexp s


let build_lists data =
  let split_list = split_on_whitespace_and_newline data |> List.map int_of_string in
  let left = BatDynArray.create () in
  let right = BatDynArray.create () in
  List.iteri (fun i n ->
    if i mod 2 = 0 then
      BatDynArray.add left n
    else
      BatDynArray.add right n
        ) split_list;
  (BatDynArray.to_list left, BatDynArray.to_list right)


let sort_lists lists =
  let (left, right) = lists in
  (List.sort compare left, List.sort compare right)


let calculate_distances lists =
  let (left, right) = lists in
  List.map2 (fun ln rn -> abs(ln - rn)) left right


let calculate_simularities lists =
  let (left, right) = lists in
  List.map (fun ln -> (List.filter (fun n -> n = ln) right |> List.length) * ln ) left

(* Part 1 test *)
let () = read_file "data/example.txt"
    |> build_lists
    |> sort_lists
    |> calculate_distances
    |> List.fold_left (fun acc x -> acc + x) 0
    |> string_of_int
    |> print_endline

(* Part 1 *)
let () = read_file "data/input.txt"
    |> build_lists
    |> sort_lists
    |> calculate_distances
    |> List.fold_left (fun acc x -> acc + x) 0
    |> string_of_int
    |> print_endline

(* Part 2 test *)
let () = read_file "data/example.txt"
    |> build_lists
    |> sort_lists
    |> calculate_simularities
    |> List.fold_left (fun acc x -> acc + x) 0
    |> string_of_int
    |> print_endline

(* Part 2 *)
let () = read_file "data/input.txt"
    |> build_lists
    |> sort_lists
    |> calculate_simularities
    |> List.fold_left (fun acc x -> acc + x) 0
    |> string_of_int
    |> print_endline
