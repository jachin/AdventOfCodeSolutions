type t = char array array

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
  let matrix = Array.make_matrix num_rows num_cols ' ' in
  List.iteri
    (fun row line ->
      String.iteri (fun col elem -> matrix.(row).(col) <- elem) line)
    lines;
  matrix

let to_string matrix =
  Array.fold_left
    (fun str_acc row ->
      Array.fold_left (fun s_acc c -> s_acc ^ Printf.sprintf "%c" c) str_acc row
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
