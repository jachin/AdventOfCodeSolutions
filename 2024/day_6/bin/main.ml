open Day_6

let read_file filename =
  let chan = open_in filename in
  let file_length = in_channel_length chan in
  let content = really_input_string chan file_length in
  close_in chan;
  content

let () =
  read_file "data/example.txt" |> Matrix.build_from_string |> Matrix.print
