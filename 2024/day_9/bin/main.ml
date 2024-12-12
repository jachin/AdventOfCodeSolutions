open Cmdliner

let setup_log style_renderer level =
  Fmt_tty.setup_std_outputs ?style_renderer ();
  Logs.set_level level;
  Logs.set_reporter (Logs_fmt.reporter ());
  ()

let part_1_example () =
  print_endline "Part 1 Example!!!";
  Logs.info (fun m -> m "Part 1 Example - Verbose mode.");
  Logs.err (fun m -> m "Beeb Boop.")

let setup_log =
  Term.(const setup_log $ Fmt_cli.style_renderer () $ Logs_cli.level ())

let main () =
  let info = Cmd.info "day_9" in
  let cmd = Cmd.v info Term.(const part_1_example $ setup_log) in
  exit (Cmd.eval cmd)

let () = main ()
