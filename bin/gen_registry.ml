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
    |> List.fold_left (fun acc m ->
      Array.set acc (int_of_string (String.sub m 3 2) - 1) (Some m); acc
    ) (Array.init 25 (Fun.const None))

  in

  print_endline "let days : (module Day.S) option array = [|";
  Array.iter (fun m ->
    match m with
    | Some m -> Printf.printf "\tSome (module Aoc_days.%s.Solution);\n" (String.capitalize_ascii m)
    | None -> Printf.printf "\tNone;\n"
  ) day_modules;
  print_endline "|]"
