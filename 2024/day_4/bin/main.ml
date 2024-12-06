open Day_4

let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

let chars_to_string chars = String.concat "" (List.map (String.make 1) chars)

let get_chars_to_the_right row col matrix =
  Matrix.get_line matrix row col row (col + 3)

let get_chars_going_down row col matrix =
  Matrix.get_line matrix row col (row + 3) col

let get_chars_going_diagonal_down_and_right row col matrix =
  Matrix.get_line matrix row col (row + 3) (col + 3)

let get_chars_going_diagonal_down_and_left row col matrix =
  Matrix.get_line matrix row col (row + 3) (col - 3)

let generate_perms matrix =
  let perms = BatDynArray.create () in
  Matrix.iter
    (fun cords _ ->
      let row, col = cords in
      [
        get_chars_to_the_right row col matrix;
        get_chars_going_down row col matrix;
        get_chars_going_diagonal_down_and_right row col matrix;
        get_chars_going_diagonal_down_and_left row col matrix;
      ]
      |> List.map Option.to_list |> List.concat
      |> List.iter (fun line ->
             BatDynArray.add perms (line |> chars_to_string);
             BatDynArray.add perms (line |> List.rev |> chars_to_string)))
    matrix;
  BatDynArray.to_list perms

let find_x_mas_es matrix =
  let fetch_x cords =
    let row, col = cords in
    [
      Matrix.get_line matrix (row - 1) (col - 1) (row + 1) (col + 1);
      Matrix.get_line matrix (row - 1) (col + 1) (row + 1) (col - 1);
    ]
  in
  let x_mas_es = BatDynArray.create () in
  Matrix.iter
    (fun cords _ ->
      let lines =
        fetch_x cords |> List.map Option.to_list |> List.concat
        |> List.map chars_to_string
        |> List.filter (fun l -> l = "MAS" || l = "SAM")
      in
      if List.length lines = 2 then BatDynArray.add x_mas_es cords else ())
    matrix;

  BatDynArray.to_list x_mas_es

(* let print_perms perms =
   List.iter (fun perm ->
     Printf.printf "%s\n" perm
   ) perms;
   perms *)

(* Part 1 test *)
let () =
  read_file "data/example.txt"
  |> Matrix.build_from_string |> generate_perms
  |> List.filter (fun p -> p = "XMAS")
  |> List.length |> string_of_int |> print_endline

(* Part 1 *)
let () =
  read_file "data/input.txt" |> Matrix.build_from_string |> generate_perms
  |> List.filter (fun p -> p = "XMAS")
  |> List.length |> string_of_int |> print_endline

(* Part 2 test *)
let () =
  read_file "data/example.txt"
  |> Matrix.build_from_string |> find_x_mas_es |> List.length |> string_of_int
  |> print_endline

(* Part 2 *)
let () =
  read_file "data/input.txt" |> Matrix.build_from_string |> find_x_mas_es
  |> List.length |> string_of_int |> print_endline
