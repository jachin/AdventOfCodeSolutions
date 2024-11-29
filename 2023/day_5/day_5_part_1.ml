(* OCaml Program to Read and Display Contents of a File - Filename from Command Line *)

(* Function to read lines from a file and return a list of strings *)
let read_file filename =
  let lines = ref [] in
  let chan = open_in filename in
  try
      while true; do
          lines := input_line chan :: !lines
      done; !lines
  with End_of_file ->
      close_in chan;
      List.rev !lines

type seed = { id : int }

type seedToSoilMap = { seedId : int; soilId : int }
type soilToFertilizerMap = { soilId : int; fertilizerId : int }
type fertilizerToWaterMap = { fertilizerId : int; waterId : int }
type waterToLightMap = { waterId : int; lightdId : int }
type lightToTempatureMap = { lightdId : int; tempatureId : int }
type tempatureToHumidityMap = { tempatureId : int; humidityId : int }
type humidityToLocationMap = { humidityId : int; soilId : int }


(* Main Function *)
let () =
  if Array.length Sys.argv <> 2 then
      (print_endline "Usage: ./read_file <filename>"; exit 1)
  else
      let filename = Sys.argv.(1) in
      let lines = read_file filename in
      List.iter print_endline lines
