type t = char array array

let create rows cols init =
  Array.make_matrix rows cols init

let get matrix row col =
  matrix.(row).(col)

let set matrix row col value =
  matrix.(row).(col) <- value

let build_from_string input =
  let lines = String.split_on_char '\n' input |> List.filter (fun line -> line <> "") in
  let num_rows = List.length lines in
  let num_cols = if num_rows > 0 then (String.length (List.hd lines)) else 0 in
  let matrix = Array.make_matrix num_rows num_cols ' ' in
  List.iteri (fun y line ->
      String.iteri (fun x elem ->
        matrix.(y).(x) <- elem
      ) line
    ) lines;
  matrix

let to_string matrix =
  Array.fold_left (fun str_acc row ->
    Array.fold_left (fun s_acc c -> s_acc ^ Printf.sprintf "%c" c) str_acc row ^ "\n"
  ) "" matrix

let print matrix =
  print_endline (to_string matrix)
