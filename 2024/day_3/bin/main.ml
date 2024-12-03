let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

let regexp = Str.regexp {|mul(\([0-9][0-9]?[0-9]?\),\([0-9][0-9]?[0-9]?\))\|do()\|don't()|}

type instruction =
  | Do
  | Dont
  | Multiply of (int * int)


let find_next_instruction input start  =
  let _ = Str.search_forward regexp input start in
  let ins = Str.matched_group 0 input in
  match ins with
    | "do()" ->
        let () = print_endline "do" in
        (Do, Str.match_end ())

    | "don't()" ->
      let () = print_endline "don't()" in
      (Dont, Str.match_end ())
    | _ ->
        let x = Str.matched_group 1 input in
        let y = Str.matched_group 2 input in
        let () = print_endline ("(" ^ x ^ "," ^ y ^ ")") in
        (Multiply (int_of_string x, int_of_string y ), Str.match_end ())

let search_instructions input =
  let index = ref 0 in
  let result = BatDynArray.create () in
  let more_instructions = ref true in
    while !more_instructions do
      try
        let (ins, match_end) = find_next_instruction input !index in
        index := match_end;
        BatDynArray.add result ins;
      with
        Not_found -> more_instructions := false
    done;
  BatDynArray.to_list result


let run_instruction_1 state instruction =
  let (is_enabled, acc) = state in
  match instruction with
    | Do ->
      (true, acc)
    | Dont ->
      (true, acc)
    | Multiply (x,  y) -> (is_enabled, (x * y) + acc)


let run_instruction_2 state instruction =
  let (is_enabled, acc) = state in
  match instruction with
    | Do ->
      (true, acc)
    | Dont ->
      (false, acc)
    | Multiply (x,  y) ->
        if is_enabled then
          (is_enabled, (x * y) + acc)
        else
          (is_enabled, acc)

(* Part 1 test *)
let () = read_file "data/example.txt"
  |> search_instructions
  |> List.fold_left run_instruction_1 (true, 0)
  |> (fun r -> let (_, a) = r in a )
  |> string_of_int
  |> print_endline

(* Part 1 *)
let () = read_file "data/input.txt"
  |> search_instructions
  |> List.fold_left run_instruction_1 (true, 0)
  |> (fun r -> let (_, a) = r in a )
  |> string_of_int
  |> print_endline


(* Part 2 test *)
let () = read_file "data/example_part_2.txt"
  |> search_instructions
  |> List.fold_left run_instruction_2 (true, 0)
  |> (fun r -> let (_, a) = r in a )
  |> string_of_int
  |> print_endline

(* Part 2 *)
let () = read_file "data/input.txt"
  |> search_instructions
  |> List.fold_left run_instruction_2 (true, 0)
  |> (fun r -> let (_, a) = r in a )
  |> string_of_int
  |> print_endline
