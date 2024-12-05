type page_ordering_rule =
  | Rule of (int * int)

type saftey_manual_update =
  | Update of (int list)

let string_to_rule s =
  match String.split_on_char '|' s with
    | [first; second] ->
      Some (Rule (int_of_string first, int_of_string second) )
    | _ ->
      None

let string_to_saftey_manual_update s =
  Update (String.split_on_char ',' s |> List.map int_of_string)

let string_to_rules s =
  String.split_on_char '\n' s
    |> List.map string_to_rule
    |> List.filter_map (fun opt -> opt)

let string_to_saftey_manual_updates s =
  String.split_on_char '\n' s
    |> List.filter (fun line -> line <> "")
    |> List.map string_to_saftey_manual_update

let split_on_blank_lines input =
  let blank_line_pattern = Str.regexp "\n[ \t\r]*\n" in
  Str.split blank_line_pattern input

let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

let parse_data s =
  match split_on_blank_lines s with
    | [rule_data; manual_data] ->
      (string_to_rules rule_data, string_to_saftey_manual_updates manual_data)
    | _ ->
      ([], [])

let index_of item lst =
  let rec aux idx = function
    | [] -> None
    | x :: xs ->
        if x = item then Some idx
        else aux (idx + 1) xs
  in
  aux 0 lst

let manual_update_passes_rule rule manual_date =
  match rule with
    | Rule (first, second) ->
      match manual_date with
        | Update pages_numbers ->
          match index_of first pages_numbers with
            | None -> true
            | Some i1 ->
              match index_of second pages_numbers with
                | Some i2 ->
                  i1 < i2
                | None -> true

let all_true lst =
  List.for_all (fun x -> x) lst

let any_false lst =
  List.exists (fun x -> not x) lst

let manual_update_passes_rules rules manual_update  =
  List.map (fun rule -> manual_update_passes_rule rule manual_update ) rules
    |> all_true

let filter_valid_manual_updates rules manual_updates =
  List.filter (manual_update_passes_rules rules) manual_updates

let filter_invalid_manual_updates rules manual_updates =
  List.filter (fun manual_update ->
    List.map (fun rule -> manual_update_passes_rule rule manual_update ) rules
      |> any_false
  ) manual_updates

let get_middle lst =
  let len = List.length lst in
  if len = 0 then raise (Invalid_argument "Empty list")
  else
    let middle_index = len / 2 in
    let rec find_at idx = function
      | [] -> raise Not_found
      | x :: _ when idx = 0 -> x
      | _ :: tl -> find_at (idx - 1) tl
    in
    find_at middle_index lst

let sum_middle_page_manual_updates manual_updates =
  List.map (fun manual_update ->
    match manual_update with
      | Update pages_numbers ->
        get_middle pages_numbers) manual_updates
  |> List.fold_left (fun acc n -> n + acc) 0

let swap_pages manual_update page_a page_b =
  match manual_update with
    Update pages ->
      let p = Array.of_list pages in
      if Array.exists (fun x -> x = page_a) p && Array.exists (fun x -> x = page_b) p then
        let page_a_i = BatArray.findi (fun x -> x = page_a) p in
        let page_b_i = BatArray.findi (fun x -> x = page_b) p in
        Array.set p page_b_i page_a;
        Array.set p page_a_i page_b;
        Update (Array.to_list p)
      else
        manual_update


let maybe_apply_rule_fix manual_update rule =
  if manual_update_passes_rule rule manual_update then
    manual_update
  else
    match rule with
      | Rule (page_a, page_b) ->
          swap_pages manual_update page_a page_b


let rec fix_manual_update rules manual_update =
  let improved_manual_update = List.fold_left
    (fun mc rule -> maybe_apply_rule_fix mc rule)
    manual_update
    rules in
  if manual_update_passes_rules rules improved_manual_update then
    improved_manual_update
  else
    fix_manual_update rules improved_manual_update

let fix_manual_updates rules manual_updates =
  manual_updates
    |> List.map (fix_manual_update rules)

let () = read_file "data/example.txt"
  |> parse_data
  |> (fun data -> let (rules, manuals) = data in
        filter_valid_manual_updates rules manuals
      )
      |> sum_middle_page_manual_updates
      |> string_of_int
      |> print_endline


let () = read_file "data/input.txt"
  |> parse_data
  |> (fun data -> let (rules, manuals) = data in
        filter_valid_manual_updates rules manuals
      )
      |> sum_middle_page_manual_updates
      |> string_of_int
      |> print_endline


let () = read_file "data/example.txt"
  |> parse_data
  |> (fun data -> let (rules, manuals) = data in
        filter_invalid_manual_updates rules manuals
        |> fix_manual_updates rules
      )
      |> sum_middle_page_manual_updates
      |> string_of_int
      |> print_endline


let () = read_file "data/input.txt"
  |> parse_data
  |> (fun data -> let (rules, manuals) = data in
        filter_invalid_manual_updates rules manuals
        |> fix_manual_updates rules
      )
      |> sum_middle_page_manual_updates
      |> string_of_int
      |> print_endline
