let () =
  let days_dir =
    if Array.length Sys.argv > 1 then
      Sys.argv.(1)
    else (
      prerr_endline "Error: Please provide the path to the 'days' directory.";
      exit 1
    )
  in

  let entries = Sys.readdir days_dir |> Array.to_list in
  let day_modules =
    entries
    |> List.filter (fun f ->
        String.starts_with ~prefix:"Day" f || String.starts_with ~prefix:"day" f)
    |> List.map Filename.remove_extension
    |> List.sort String.compare
  in

  (* 2. Print the generated code to standard output. Do not open any files. *)
  print_endline "let days : (module Aoc_lib.Day.S) array = [|";
  List.iter (fun m ->
    Printf.printf "  (module Aoc_days.%s.Main);\n" (String.capitalize_ascii m)
  ) day_modules;
  print_endline "|]"
