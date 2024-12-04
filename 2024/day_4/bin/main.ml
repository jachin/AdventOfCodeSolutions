let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

let build_matrix input =
  let lines = String.split_on_char '\n' input |> List.filter (fun line -> line <> "") in
  let num_rows = List.length lines in
  let num_cols = if num_rows > 0 then (String.length (List.hd lines)) else 0 in
  let () = print_endline (Printf.sprintf "%i %i" num_rows num_cols) in
  let matrix = Array.make_matrix num_rows num_cols ' ' in
  List.iteri (fun y line ->
      String.iteri (fun x elem ->
        matrix.(x).(y) <- elem
      ) line
    ) lines;
  matrix

let print_matrix matrix =
  Array.iter (fun row ->
    Array.iter (fun elem -> Printf.printf "%c" elem) row;
    print_newline ()
  ) matrix;
  matrix

let chars_to_string chars =
  String.concat "" (List.map (String.make 1) chars)

let generate_perms matrix =
  let perms = BatDynArray.create () in
  Array.iteri (fun x row ->
      Array.iteri (fun y c ->
        (* down *)
        try
          let right_chars = [ c; matrix.(x + 1).(y); matrix.(x + 2).(y); matrix.(x + 3).(y) ] in
          BatDynArray.add perms (chars_to_string right_chars );
          BatDynArray.add perms ( right_chars |> List.rev |> chars_to_string  )
        with
            Invalid_argument _ -> ();
        (* down *)
        try
          let down_chars = [ c; matrix.(x).(y + 1); matrix.(x).(y + 2); matrix.(x).(y + 3) ] in
          BatDynArray.add perms (chars_to_string down_chars );
          BatDynArray.add perms ( down_chars |> List.rev |> chars_to_string  )
        with
            Invalid_argument _ -> ();
        (* diagonal *)
        try
          let diagonal_chars = [ c; matrix.(x + 1).(y + 1); matrix.(x + 2).(y + 2); matrix.(x + 3).(y + 3) ] in
          BatDynArray.add perms (chars_to_string diagonal_chars );
          BatDynArray.add perms ( diagonal_chars |> List.rev |> chars_to_string  )
        with
            Invalid_argument _ -> ();
        (* diagonal *)
        try
          let diagonal_chars = [ c; matrix.(x - 1).(y - 1); matrix.(x - 2).(y - 2); matrix.(x - 3).(y - 3) ] in
          BatDynArray.add perms (chars_to_string diagonal_chars );
          BatDynArray.add perms ( diagonal_chars |> List.rev |> chars_to_string  )
        with
            Invalid_argument _ -> ()
      ) row
  ) matrix;
  BatDynArray.to_list perms

let print_perms perms =
  List.iter (fun perm ->
    Printf.printf "%s\n" perm
  ) perms;
  perms


(* Part 1 test *)
let () = read_file "data/example.txt"
  |> build_matrix
  |> print_matrix
  |> generate_perms
  |> print_perms
  |> List.filter (fun p -> p = "XMAS")
  |> List.length
  |> string_of_int
  |> print_endline
