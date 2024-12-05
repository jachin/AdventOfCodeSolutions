open Day_4

let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

let chars_to_string chars =
  String.concat "" (List.map (String.make 1) chars)

let generate_perms matrix =
  let perms = BatDynArray.create () in
  Matrix.iter (fun cords _ ->
    let (row, col) = cords in
    match Matrix.get_line matrix row col row (col + 3) with
      | Some line ->
        BatDynArray.add perms (line |> chars_to_string);
        BatDynArray.add perms (line |> List.rev |> chars_to_string);
        ()
      | None ->
        ();

    match Matrix.get_line matrix row col (row + 3) col with
      | Some line ->
        BatDynArray.add perms (line |> chars_to_string);
        BatDynArray.add perms (line |> List.rev |> chars_to_string);
        ()
      | None ->
        ();

    match Matrix.get_line matrix row col (row + 3) (col + 3) with
      | Some line ->
        BatDynArray.add perms (line |> chars_to_string);
        BatDynArray.add perms (line |> List.rev |> chars_to_string);
        ()
      | None ->
        ();

    match Matrix.get_line matrix row col (row - 3) (col + 3) with
      | Some line ->
        print_endline ("diag - " ^ (line |> chars_to_string));
        BatDynArray.add perms (line |> chars_to_string);
        BatDynArray.add perms (line |> List.rev |> chars_to_string);
        ()
      | None ->
        ();
    ) matrix;
  BatDynArray.to_list perms

let print_perms perms =
  List.iter (fun perm ->
    Printf.printf "%s\n" perm
  ) perms;
  perms

(* Part 1 test *)
let () = read_file "data/example.txt"
  |> Matrix.build_from_string
  (* |> Matrix.iter (fun cords char ->
    match cords with
    | (col, row) ->
      Printf.printf "(%i, %i) %c\n" col row char
  ) *)
  |> generate_perms
  |> (fun perms -> List.length perms |> string_of_int |> print_endline; perms )
  |> print_perms
  |> List.filter (fun p -> p = "XMAS")
  |> List.length
  |> string_of_int
  |> print_endline
