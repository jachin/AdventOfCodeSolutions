open Day_4

let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

(* let chars_to_string chars =
  String.concat "" (List.map (String.make 1) chars) *)

(* let get_chars_to_the_right x y matrix =
  [
      matrix.(x).(y);
      matrix.(x + 1).(y);
      matrix.(x + 2).(y);
      matrix.(x + 3).(y) ] *)

(* let generate_perms matrix =
  let perms = BatDynArray.create () in
  Array.iteri (fun y row ->
      Array.iteri (fun x _ ->
        (* right *)
        let right_chars = get_chars_to_the_right x y matrix in
        BatDynArray.add perms (chars_to_string right_chars );
        BatDynArray.add perms (right_chars |> List.rev |> chars_to_string);

        (* (* down *)
        try
          let down_chars = [ c; matrix.(x).(y + 1); matrix.(x).(y + 2); matrix.(x).(y + 3) ] in
          print_endline (Printf.sprintf "down_chars %i %i %s" x y (chars_to_string down_chars));
          BatDynArray.add perms (chars_to_string down_chars );
          BatDynArray.add perms ( down_chars |> List.rev |> chars_to_string  );
        with
            Invalid_argument _ ->
              print_endline (Printf.sprintf "Not able to go down %i %i" x y);
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
            Invalid_argument _ -> () *)
      ) row
  ) matrix;
  BatDynArray.to_list perms *)

(* let print_perms perms =
  List.iter (fun perm ->
    Printf.printf "%s\n" perm
  ) perms;
  perms *)


(* Part 1 test *)
let () = read_file "data/example.txt"
  |> Matrix.build_from_string
  |> Matrix.print
  (* |> generate_perms
  |> print_perms
  |> List.filter (fun p -> p = "XMAS")
  |> List.length
  |> string_of_int
  |> print_endline *)
