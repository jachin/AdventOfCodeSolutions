open Cmdliner
open Day_9

let info_log_passthrough msg data =
  Logs.info (fun m -> m msg);
  data

let print_disk_map disk_map =
  BatDynArray.(iter (fun block -> print_string block) disk_map);
  print_endline "";
  disk_map

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

let part_1_example () =
  File_helpers.read_file "./data/example.txt" |> solve_part_1

let part_1 () = File_helpers.read_file "./data/input.txt" |> solve_part_1

let setup_log style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ());
  ()

let setup_log =
  Term.(const setup_log $ Fmt_cli.style_renderer () $ Logs_cli.level ())

let main () =
  let info = Cmd.info "day_9" in
  let cmd =
    Cmd.v info
      Term.(
        const
          (part_1_example ();
           part_1)
        $ setup_log)
  in
  exit (Cmd.eval cmd)

let () = main ()
