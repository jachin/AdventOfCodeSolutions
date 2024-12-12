open Cmdliner
open Day_9

let info_log_passthrough msg data =
  Logs.info (fun m -> m msg);
  data

let print_disk_map disk_map =
  BatDynArray.(iter (fun block -> print_string block) disk_map);
  print_endline "";
  disk_map

(* let print_disk_map_unit disk_map =
  BatDynArray.(iter (fun block -> print_string block) disk_map);
  print_endline "" *)

let build_disk_map input_data =
  let disk_map = BatDynArray.create () in
  List.iteri
    (fun i (file_length, free_space) ->
      for _ = 0 to file_length - 1 do
        BatDynArray.add disk_map (string_of_int i)
      done;
      for _ = 0 to free_space - 1 do
        BatDynArray.add disk_map "."
      done)
    input_data;
  disk_map

let frag disk_map =
  BatDynArray.(
    let right_pointer = ref (length disk_map - 1) in
    BatDynArray.iteri
      (fun i block ->
        (* BatDynArray.(iter (fun block -> print_string block) disk_map);
        print_endline ""; *)
        if i < !right_pointer then
          match block with
          | "." ->
              while get disk_map !right_pointer = "." && !right_pointer > 0 do
                right_pointer := !right_pointer - 1
              done;
              let time_to_stop = i > !right_pointer in
              if not time_to_stop then (
                let t = get disk_map !right_pointer in
                set disk_map !right_pointer ".";
                set disk_map i t;
                right_pointer := !right_pointer - 1)
              else ()
          | _ -> ()
        else ())
      disk_map);
  disk_map

let find_empty_block disk_map size =
  let is_found = ref false in
  let i = ref 0 in
  let buffer = ref [] in
  let buffer_start = ref 0 in
  let empty_block_index = ref None in
  BatDynArray.(
    while (not !is_found) && !i < length disk_map do
      match get disk_map !i with
      | "." ->
          if List.is_empty !buffer then buffer_start := !i else ();
          buffer := "." :: !buffer;

          if List.length !buffer >= size then is_found := true;
          empty_block_index := Some !buffer_start;
          i := !i + 1
      | _ ->
          buffer := [];
          buffer_start := !i;
          i := !i + 1
    done);
  !empty_block_index

let move_file file_id file_length empty_block_index disk_map =
  BatDynArray.(
    let index = findi (fun a -> a = string_of_int file_id) disk_map in

    if empty_block_index < index then (
      for j = index to index + file_length - 1 do
        Logs.info (fun m -> m "Setting the old disk location %i" j);
        set disk_map j "."
      done;
      for k = empty_block_index to empty_block_index + file_length - 1 do
        Logs.info (fun m -> m "Setting the new disk location %i" k);
        set disk_map k (string_of_int file_id)
      done)
    else ())

let orgnize_files initial_file_state disk_map =
  let file_labels =
    List.mapi (fun i (file_length, _) -> (i, file_length)) initial_file_state
    |> List.rev
  in

  List.iter
    (fun (file_id, file_length) ->
      match find_empty_block disk_map file_length with
      | Some empty_block_index ->
          move_file file_id file_length empty_block_index disk_map
      | None -> ())
    file_labels;

  disk_map

let calculate_checksum disk_map =
  BatDynArray.fold_lefti
    (fun acc i block ->
      match block with "." -> acc | _ -> acc + (i * int_of_string block))
    0 disk_map

let char_to_int c =
  (* Ensure c is a valid digit character *)
  if c >= '0' && c <= '9' then
    (* Subtract the ASCII value of '0' from c to get the integer value *)
    int_of_char c - int_of_char '0'
  else failwith "Input is not a digit character"

let solve_part_1 input =
  input
  |> info_log_passthrough "Input Data Read"
  |> String.trim
  |> String.fold_left
       (fun acc c ->
         match acc with
         | None, disk_map -> (Some c, disk_map)
         | Some file_length, disk_map ->
             (None, (char_to_int file_length, char_to_int c) :: disk_map))
       (None, [])
  |> (fun (tail, disk_map) ->
  match tail with
  | None -> List.rev disk_map
  | Some file_length -> List.rev ((char_to_int file_length, 0) :: disk_map))
  (* |> fun input_data ->
  List.iter
    (fun (file_length, empty_space) ->
      print_endline (Printf.sprintf "%i %i, " file_length empty_space))
    input_data;
  input_data *)
  |> info_log_passthrough "Input Data Ingested"
  |> build_disk_map |> print_disk_map
  |> info_log_passthrough "Disk map built"
  |> frag |> print_disk_map |> calculate_checksum |> string_of_int
  |> print_endline

let solve_part_2 input =
  let initial_file_state =
    input
    |> info_log_passthrough "Input Data Read"
    |> String.trim
    |> String.fold_left
         (fun acc c ->
           match acc with
           | None, disk_map -> (Some c, disk_map)
           | Some file_length, disk_map ->
               (None, (char_to_int file_length, char_to_int c) :: disk_map))
         (None, [])
    |> (fun (tail, disk_map) ->
    match tail with
    | None -> List.rev disk_map
    | Some file_length -> List.rev ((char_to_int file_length, 0) :: disk_map))
    |> info_log_passthrough "Input Data Ingested"
  in
  initial_file_state |> build_disk_map |> print_disk_map
  |> info_log_passthrough "Disk map built"
  |> orgnize_files initial_file_state
  |> print_disk_map |> calculate_checksum |> string_of_int |> print_endline

let part_1_example () =
  File_helpers.read_file "./data/example.txt" |> solve_part_1

let part_1 () = File_helpers.read_file "./data/input.txt" |> solve_part_1

let solve_puzzles () =
  part_1_example ();
  part_1 ();
  File_helpers.read_file "./data/example.txt" |> solve_part_2;
  File_helpers.read_file "./data/input.txt" |> solve_part_2

let setup_log style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ());
  ()

let setup_log =
  Term.(const setup_log $ Fmt_cli.style_renderer () $ Logs_cli.level ())

let main () =
  let info = Cmd.info "day_9" in
  let cmd = Cmd.v info Term.(const solve_puzzles $ setup_log) in
  exit (Cmd.eval cmd)

let () = main ()
