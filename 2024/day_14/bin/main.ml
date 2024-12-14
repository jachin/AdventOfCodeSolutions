open Batteries

let read_file (filename : string) =
  let input = BatFile.open_in filename in
  try
    BatEnum.iter (fun line -> Printf.printf "%s\n" line) (BatIO.lines_of input);

    BatIO.close_in input
  with e ->
    BatIO.close_in input;
    raise e

let () = read_file "./data/example.txt"
