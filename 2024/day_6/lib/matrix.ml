type space =
  | Empty
  | Obstruction
  | GuardGoingUp
  | GuardGoingRight
  | GuardGoingDown
  | GuardGoingLeft
  | OffTheGrid

type t = space array array

let char_of_space s =
  match s with
  | Empty -> '.'
  | Obstruction -> '#'
  | GuardGoingUp -> '^'
  | GuardGoingRight -> '>'
  | GuardGoingDown -> 'v'
  | GuardGoingLeft -> '<'
  | OffTheGrid -> '!'

let space_of_char c =
  match c with
  | '.' -> Empty
  | '#' -> Obstruction
  | '^' -> GuardGoingUp
  | '>' -> GuardGoingRight
  | 'v' -> GuardGoingDown
  | '<' -> GuardGoingLeft
  | _ ->
      raise
        (Invalid_argument (Printf.sprintf "%c is not a valid space character" c))

let create rows cols init = Array.make_matrix rows cols init
let get matrix row col = matrix.(row).(col)
let set matrix row col value = matrix.(row).(col) <- value

let build_from_string input =
  let lines =
    String.split_on_char '\n' input
    |> List.map String.trim
    |> List.filter (fun line -> line <> "")
  in
  let num_rows = List.length lines in
  let num_cols = if num_rows > 0 then String.length (List.hd lines) else 0 in
  let matrix = Array.make_matrix num_rows num_cols Empty in
  List.iteri
    (fun row line ->
      String.iteri
        (fun col elem -> matrix.(row).(col) <- space_of_char elem)
        line)
    lines;
  matrix

let to_string matrix =
  Array.fold_left
    (fun str_acc row ->
      Array.fold_left
        (fun s_acc c -> s_acc ^ Printf.sprintf "%c" (char_of_space c))
        str_acc row
      ^ "\n")
    "" matrix

let print matrix = print_endline (to_string matrix)

let is_in_bounds matrix row col =
  let num_rows = Array.length matrix in
  let num_cols = if num_rows > 0 then Array.length matrix.(0) else 0 in
  row >= 0 && row < num_rows && col >= 0 && col < num_cols

let get_line matrix row1 col1 row2 col2 =
  let bresenham_line x0 y0 x1 y1 =
    let dx = abs (x1 - x0) in
    let dy = abs (y1 - y0) in
    let sx = if x0 < x1 then 1 else -1 in
    let sy = if y0 < y1 then 1 else -1 in
    let rec loop x y err acc =
      if x = x1 && y = y1 then List.rev ((x, y) :: acc)
      else
        let e2 = err * 2 in
        let updated_err, new_x, new_y =
          if e2 > -dy then (err - dy, x + sx, y) else (err, x, y)
        in
        let updated_err, new_x, new_y =
          if e2 < dx then (updated_err + dx, new_x, new_y + sy)
          else (updated_err, new_x, new_y)
        in
        loop new_x new_y updated_err ((x, y) :: acc)
    in
    loop x0 y0 (dx - dy) []
  in

  if is_in_bounds matrix row1 col1 && is_in_bounds matrix row2 col2 then
    let points = bresenham_line row1 col1 row2 col2 in
    Some (List.map (fun (r, c) -> matrix.(r).(c)) points)
  else None

let iter f matrix =
  Array.iteri
    (fun rowi row -> Array.iteri (fun coli char -> f (rowi, coli) char) row)
    matrix

let get_space matrix row col =
  try get matrix row col with Invalid_argument _ -> OffTheGrid

let find_guard matrix =
  let result = ref None in
  iter
    (fun cords s ->
      match s with
      | Empty -> ()
      | Obstruction -> ()
      | GuardGoingUp -> result := Some (cords, s)
      | GuardGoingRight -> result := Some (cords, s)
      | GuardGoingDown -> result := Some (cords, s)
      | GuardGoingLeft -> result := Some (cords, s)
      | OffTheGrid -> ())
    matrix;
  !result

let generate_next_matrix matrix =
  match find_guard matrix with
  | None -> None
  | Some ((row, col), g) -> (
      match g with
      | GuardGoingUp -> (
          let next_space = get_space matrix (row - 1) col in
          match next_space with
          | Empty ->
              set matrix row col Empty;
              set matrix (row - 1) col GuardGoingUp;
              Some (matrix, (row, col))
          | Obstruction ->
              set matrix row col GuardGoingRight;
              Some (matrix, (row, col))
          | OffTheGrid -> None
          | _ -> raise (Invalid_argument "There should only be 1 gard"))
      | GuardGoingRight -> (
          let next_space = get_space matrix row (col + 1) in
          match next_space with
          | Empty ->
              set matrix row col Empty;
              set matrix row (col + 1) GuardGoingRight;
              Some (matrix, (row, col))
          | Obstruction ->
              set matrix row col GuardGoingDown;
              Some (matrix, (row, col))
          | OffTheGrid -> None
          | _ -> raise (Invalid_argument "There should only be 1 gard"))
      | GuardGoingDown -> (
          let next_space = get_space matrix (row + 1) col in
          match next_space with
          | Empty ->
              set matrix row col Empty;
              set matrix (row + 1) col GuardGoingDown;
              Some (matrix, (row, col))
          | Obstruction ->
              set matrix row col GuardGoingLeft;
              Some (matrix, (row, col))
          | OffTheGrid -> None
          | _ -> raise (Invalid_argument "There should only be 1 gard"))
      | GuardGoingLeft -> (
          let next_space = get_space matrix row (col - 1) in
          match next_space with
          | Empty ->
              set matrix row col Empty;
              set matrix row (col - 1) GuardGoingLeft;
              Some (matrix, (row, col))
          | Obstruction ->
              set matrix row col GuardGoingUp;
              Some (matrix, (row, col))
          | OffTheGrid -> None
          | _ -> raise (Invalid_argument "There should only be 1 gard"))
      | _ -> None)

let deep_copy matrix = Array.map Array.copy matrix

let copy_and_obstruct matrix (row, col) =
  let new_matrix = deep_copy matrix in
  set new_matrix row col Obstruction;
  new_matrix
