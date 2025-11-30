open Base
open Stdio

let args = Sys.get_argv ()

let last_year = 
  let today = Unix.time () |> Unix.localtime in
  today.tm_year + 1900

module Fetch = Fetch.Make(struct
  let year = Env_manager.get_env_int "YEAR" |> Option.value ~default:last_year
  let session = Env_manager.get_env_string "SESSION" |> Option.value ~default:""
end)

let time f x =
    let t = Unix.gettimeofday () in
    let fx = f x in
    (fx, Unix.gettimeofday () -. t)

let print_usage () =
  printf ">> Usage: %s [DAY] [PART]\n" args.(0);
  printf "     DAY:  An integer for the day you want to run (1-25).\n";
  printf "     PART: An optional integer (1 or 2) for a specific part.\n\n";
  printf "   If no arguments are given, all days will run consecutively.\n"

let print_header () =
  printf "⁘⁙⁘⁙⁘ Advent of Code %d ⁘⁙⁘⁙⁘%!\n" (Env_manager.get_env_int "YEAR" |> Option.value ~default:last_year)

let run_part day_module day_num part_num =
  let module D = (val day_module : Day.S) in
  let solver = if part_num = 1 then D.part1 else D.part2 in
  let input_file = Printf.sprintf "days/day%02d/input.txt" day_num in
  let input = In_channel.read_lines input_file |> String.concat ~sep:"\n" in
  let result, duration = time solver (D.parse_input input) in
  if part_num = 1 then
    printf "├─ Part 1 ⇒ %-20s (took %.4f ms)%!\n" result (duration *. 1000.0)
  else
  printf "└─ Part 2 ⇒ %-20s (took %.4f ms)%!\n" result (duration *. 1000.0)

let run_part_alone day_module day_num part_num =
  let module D = (val day_module : Day.S) in
  let solver = if part_num = 1 then D.part1 else D.part2 in
  let input_file = Printf.sprintf "days/day%02d/input.txt" day_num in
  printf " Day %d%!\n" day_num;
  try
    let input = In_channel.read_lines input_file |> String.concat ~sep:"\n" in
    let result, duration = time solver (D.parse_input input) in
    printf "└─ Part %d ⇒ %-20s (took %.4f ms)%!\n" part_num result (duration *. 1000.0)
  with
  | exn ->
      printf "└─ Part %d - ERROR: %s%!\n" part_num (Exn.to_string exn)

let run_day day_module day_num =
  printf " Day %d%!\n" day_num;
  run_part day_module day_num 1;
  run_part day_module day_num 2;
  print_endline ""

let run_day_safe day_module day_num =
  printf " Day %d%!\n" day_num;
  (try
    run_part day_module day_num 1;
  with 
  | exn -> 
      printf "├─ Part 1 - ERROR: %s%!\n" (Exn.to_string exn);
  );
  (try
    run_part day_module day_num 2;
    print_endline ""
  with 
  | exn -> 
      printf "└─ Part 2 - ERROR: %s%!\n" (Exn.to_string exn);
      print_endline "")

let run_all_days () =
  let (_, t) = time (fun () ->
    Array.iteri ~f:(fun i day_module ->
      let day_num = i + 1 in
      match day_module with
      | Some m -> run_day_safe m day_num
      | None -> ()
    ) Registry.days
  ) ()
  in
  printf " Total time: %.4fs%!\n" t


let get_input_opt day file =
  let input_file = Printf.sprintf "days/day%02d/%s" day file in
  try Some (In_channel.read_all input_file)
  with Sys_error _ -> None

let rec check_and_set_year (): unit =
  let read_year () =
    Out_channel.flush Stdio.stdout; 
    match Stdlib.In_channel.input_line In_channel.stdin with
      | None ->
          check_and_set_year ()
      | Some y ->
          match Int.of_string_opt y with
          | None -> check_and_set_year ()
          | Some y -> begin
              printf "   Setting YEAR to %d.\n" y;
              Env_manager.set_env_int "YEAR" y;
              Env_manager.save ();
              Fetch.set_year y;
              check_and_set_year ()
          end
  in
  match Env_manager.get_env_int "YEAR" with
  | Some year when year >= 2015 && year <= last_year -> ()
  | Some year -> begin
      printf "\n>> Error: YEAR must be between 2015 and %d." last_year;
      printf "\n   Please enter a correct year: ";
      read_year ()
  end
  | None -> begin 
      printf "\n>> Error: YEAR environment variable is not set.";
      printf "\n   Please enter a year between 2015 and %d: " last_year;
      read_year ()
  end

let rec check_and_set_session (): unit =
  let rec read_session () =
    Out_channel.flush Stdio.stdout;
    match In_channel.input_line ~fix_win_eol:true In_channel.stdin with
      | None -> read_session ()
      | Some s when String.length (String.strip s) > 0 ->
          let session = String.strip s in
          printf "   Setting SESSION.\n";
          Env_manager.set_env_string "SESSION" session;
          Env_manager.save ();
          Fetch.set_session session
      | Some _ -> 
          printf "   Invalid session. Please enter a valid session cookie: ";
          read_session ()
  in
  match Env_manager.get_env_string "SESSION" with
  | Some session when String.length (String.strip session) > 0 ->
      Fetch.set_session (String.strip session)
  | _ -> begin
      printf "\n>> Error: SESSION environment variable is not set.\n";
      printf "   Please enter your AoC session cookie: ";
      read_session ()
  end

let () =
  Env_manager.load ();

  check_and_set_year ();
  check_and_set_session ();

  let total_days = Array.length Registry.days in
  match args with
  | [||] | [|_|] ->
      run_all_days ()

  | [|_; day_str|] -> begin
      (* First, validate the day argument *)
      (match Int.of_string_opt day_str with
      | None ->
          eprintf "Error: Day must be an integer.\n";
          print_usage ();
          Stdlib.exit 1
      | Some day ->
          if day < 1 || day > total_days then begin
            eprintf "Error: Day must be between 1 and %d.\n" total_days;
            Stdlib.exit 1
          end else
            match Registry.days.(day - 1) with
            | Some m -> 
                run_day_safe m day
            | None -> 
                eprintf "Error: Day %d is not implemented yet.\n" day;
                Stdlib.exit 1)
    end

  | [|_; day_str; part_str|] -> begin
       (* First, validate both arguments *)
       (match Int.of_string_opt day_str, Int.of_string_opt part_str with
       | None, _ | _, None ->
           eprintf "Error: Day and Part must be integers.\n";
           print_usage ();
           Stdlib.exit 1
       | Some day, Some part ->
           if day < 1 || day > total_days then begin
             eprintf "Error: Day must be between 1 and %d.\n" total_days;
             Stdlib.exit 1
           end else if part <> 1 && part <> 2 then begin
             eprintf "Error: Part must be 1 or 2.\n";
             Stdlib.exit 1
           end else
             match Registry.days.(day - 1) with
             | Some m -> 
                 (* Run the part - let any exceptions propagate *)
                 run_part_alone m day part
             | None -> 
                 eprintf "Error: Day %d is not implemented yet.\n" day;
                 Stdlib.exit 1)
  end
  | _ ->
      print_usage ();
      Stdlib.exit 1
