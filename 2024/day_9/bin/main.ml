open Cmdliner

type verbosity = Verbose | Quiet

let verb =
  let quiet =
    let doc = "Just show the answers." in
    (Quiet, Arg.info [ "q"; "quiet"; "silent" ] ~doc)
  in
  let verbose =
    let doc = "Including debugging information." in
    (Verbose, Arg.info [ "v"; "verbose" ] ~doc)
  in
  Arg.(last & vflag_all [ Quiet ] [ quiet; verbose ])

let part_1_example () = print_endline "Part 1 Example"
let part_1_example_t = Term.(const part_1_example $ const ())

let cmd =
  let doc = "Advent of Code - Day 9" in
  let man =
    [ `S Manpage.s_bugs; `P "EMail bug reports to jachin@jachin.rupe.name." ]
  in
  let info = Cmd.info "day_9" ~version:"%‌%VERSION%%" ~doc ~man in
  Cmd.v info part_1_example_t

let main () = exit (Cmd.eval cmd)
let () = main ()
