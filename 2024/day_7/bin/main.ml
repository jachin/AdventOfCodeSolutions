let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

type calibration = Equation of (int * int list)

let parse_input_line l =
  match String.split_on_char ':' l with
  | [ result; factors ] ->
      Some
        (Equation
           ( result |> String.trim |> int_of_string,
             factors |> String.trim |> String.split_on_char ' '
             |> List.map int_of_string ))
  | _ -> None

let debug_equations equations =
  List.iter
    (fun e ->
      match e with
      | Equation (result, factors) ->
          Printf.printf "Equation %i: %s\n" result
            (factors |> List.map string_of_int |> String.concat ", "))
    equations;
  equations

let rec generate_all_lists n elements =
  if n = 0 then [ [] ]
  else
    let rest = generate_all_lists (n - 1) elements in
    List.flatten
      (List.map (fun el -> List.map (fun lst -> el :: lst) rest) elements)

exception Invalid_expression

let eval_rpn tokens =
  let stack = Stack.create () in
  let apply_operator op =
    try
      let b = Stack.pop stack in
      let a = Stack.pop stack in
      let result =
        match op with
        | "+" -> a +. b
        | "-" -> a -. b
        | "*" -> a *. b
        | "/" -> a /. b
        | "||" ->
            float_of_string
              (Printf.sprintf "%i%i" (int_of_float a) (int_of_float b))
        | _ -> raise Invalid_expression
      in
      Stack.push result stack
    with Stack.Empty -> raise Invalid_expression
  in
  let process_token token =
    match float_of_string_opt token with
    | Some number -> Stack.push number stack
    | None -> apply_operator token
  in
  List.iter process_token tokens;
  if Stack.length stack = 1 then Stack.pop stack else raise Invalid_expression

let generate_all_possible_equations factors all_possible_operators =
  let gen operators =
    let o = "" :: operators in
    List.fold_left2
      (fun acc operator factor ->
        if operator = "" then acc ^ string_of_int factor ^ " "
        else acc ^ string_of_int factor ^ " " ^ operator ^ " ")
      "" o factors
  in
  List.map gen all_possible_operators
  |> List.map (String.split_on_char ' ')
  |> List.map (List.filter (fun s -> not (s = " " || s = "")))

(* Function to print a single list of strings *)
(* let print_string_list lst =
     let rec aux = function
       | [] -> print_string "]"
       | [ x ] ->
           print_string x;
           print_string "]"
       | x :: xs ->
           print_string x;
           print_string "; ";
           aux xs
     in
     print_string "[";
     aux lst

   (* Function to print a list of lists of strings *)
   let print_list_of_string_lists lst_lst =
     let rec aux = function
       | [] -> print_endline "]"
       | [ lst ] ->
           print_string "[";
           print_string_list lst;
           print_endline "]"
       | lst :: lsts ->
           print_string "[";
           print_string_list lst;
           print_endline ";";
           aux lsts
     in
     print_endline "[";
     aux lst_lst *)

let test_equation equation =
  match equation with
  | Equation (result, factors) -> (
      let number_of_factors = List.length factors in
      let number_of_operators = number_of_factors - 1 in
      let all_possible_operators =
        generate_all_lists number_of_operators [ "+"; "*" ]
      in
      let all_possible_equations =
        generate_all_possible_equations factors all_possible_operators
      in
      (* print_list_of_string_lists all_possible_equations; *)
      let results = List.map eval_rpn all_possible_equations in
      match List.find_opt (fun r -> int_of_float r = result) results with
      | Some _ -> result
      | None -> 0)

let test_equation_2 equation =
  match equation with
  | Equation (result, factors) -> (
      let number_of_factors = List.length factors in
      let number_of_operators = number_of_factors - 1 in
      let all_possible_operators =
        generate_all_lists number_of_operators [ "+"; "*"; "||" ]
      in
      let all_possible_equations =
        generate_all_possible_equations factors all_possible_operators
      in
      (* print_list_of_string_lists all_possible_equations; *)
      let results = List.map eval_rpn all_possible_equations in
      match List.find_opt (fun r -> int_of_float r = result) results with
      | Some _ -> result
      | None -> 0)

(* part_1_example *)
let () =
  read_file "./data/example.txt"
  |> String.split_on_char '\n' |> List.map parse_input_line
  |> List.filter_map (fun x -> x)
  |> debug_equations
  |> List.fold_left (fun acc e -> test_equation e + acc) 0
  |> string_of_int |> print_endline

(* part_1 *)
(* let () =
   read_file "./data/input.txt"
   |> String.split_on_char '\n' |> List.map parse_input_line
   |> List.filter_map (fun x -> x)
   |> debug_equations
   |> List.fold_left (fun acc e -> test_equation e + acc) 0
   |> string_of_int |> print_endline *)

(* part_2_example *)
let () =
  read_file "./data/example.txt"
  |> String.split_on_char '\n' |> List.map parse_input_line
  |> List.filter_map (fun x -> x)
  |> List.fold_left (fun acc e -> test_equation_2 e + acc) 0
  |> string_of_int |> print_endline

(* part_2 *)
let () =
  read_file "./data/input.txt"
  |> String.split_on_char '\n' |> List.map parse_input_line
  |> List.filter_map (fun x -> x)
  |> List.fold_left (fun acc e -> test_equation_2 e + acc) 0
  |> string_of_int |> print_endline
