open Stdio

let time f x =
    let t = Sys.time () in
    let fx = f x in
    (fx, Sys.time () -. t)

let print_usage () =
  eprintf "Usage: %s [DAY] [PART]\n" Sys.argv.(0);
  eprintf "  DAY:  An integer for the day you want to run (1-25).\n";
  eprintf "  PART: An optional integer (1 or 2) for a specific part.\n\n";
  eprintf "If no arguments are given, you will be prompted to run all days.\n"

let run_part day_module day_num part_num =
  let module D = (val day_module : Aoc_lib.Day.S) in
  let solver = if part_num = 1 then D.part1 else D.part2 in
  let result, duration = time solver () in
  printf "Day %d, Part %d: %-20s (took %.4f ms)\n"
    day_num part_num result (duration *. 1000.0)

let run_day day_module day_num =
  printf "\n------ Day %02d ------\n" day_num;
  run_part day_module day_num 1;
  run_part day_module day_num 2;
  print_endline ""

let run_all_days () =
  print_endline "Running all implemented solutions...";
  print_endline "------------";
  Array.iteri (fun i day_module ->
    let day_num = i + 1 in
    run_day day_module day_num
  ) Registry.days

let () =
  Unix.sleepf 0.1;
  let total_days = Array.length Registry.days in
  match Sys.argv |> Array.to_list with
  | [] | [_] ->
      printf "\nRun all %d implemented days? (Y/n) " total_days;
      flush stdout;
      let response = In_channel.input_line_exn In_channel.stdin in
      if response = "" || String.uppercase_ascii response = "Y" then
        run_all_days ()
      else
        print_endline "Aborting."

  | [_; day_str] ->
      (try
        let day = int_of_string day_str in
        if day >= 1 && day <= total_days then
          run_day Registry.days.(day - 1) day
        else begin
          eprintf "Error: Day must be between 1 and %d.\n" total_days;
          exit 1
        end
       with Failure _ ->
        eprintf "Error: Day must be an integer.\n";
        print_usage ();
        exit 1)

  | [_; day_str; part_str] ->
      (try
        let day = int_of_string day_str in
        let part = int_of_string part_str in
        if day < 1 || day > total_days then begin
          eprintf "Error: Day must be between 1 and %d.\n" total_days;
          exit 1
        end else if part <> 1 && part <> 2 then begin
          eprintf "Error: Part must be 1 or 2.\n";
          exit 1
        end else
          run_part Registry.days.(day - 1) day part
       with Failure _ ->
        eprintf "Error: Day and Part must be integers.\n";
        print_usage ();
        exit 1)

  | _ ->
      print_usage ();
      exit 1
