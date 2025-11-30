open Base
open Stdio

let args = Sys.get_argv ()

let wait_for_unlock year day =
  (* AoC unlocks at Midnight EST (UTC-5). 
     This is equivalent to 05:00:00 UTC on the same day. *)
  let target_hour_utc = 5 in 

  let current_tz = (try Sys.getenv "TZ" with _ -> None) |> Option.value ~default:"" in
  Unix.putenv "TZ" "UTC";

  let target_tm = {
    Unix.tm_sec = 0; 
    Unix.tm_min = 0; 
    Unix.tm_hour = target_hour_utc;
    Unix.tm_mday = day; 
    Unix.tm_mon = 11;
    Unix.tm_year = year - 1900;
    Unix.tm_wday = 0; 
    Unix.tm_yday = 0; 
    Unix.tm_isdst = false
  } in
  
  let (target_time, _) = Unix.mktime target_tm in

  (* Restore the user's original Timezone *)
  if String.is_empty current_tz then
    Unix.putenv "TZ" "" 
  else
    Unix.putenv "TZ" current_tz;

  let rec loop () =
    let now = Unix.time () in
    let diff = target_time -. now in

    if Float.(diff <= 0.0) then
      printf "\nPuzzle released! Generating setup...\n%!"
    else begin
      let days = Float.to_int (diff /. 86400.0) in
      let hours = Float.to_int (Float.mod_float diff 86400.0 /. 3600.0) in
      let mins = Float.to_int (Float.mod_float diff 3600.0 /. 60.0) in
      let secs = Float.to_int (Float.mod_float diff 60.0) in
      
      printf "\r\027[KWaiting for AoC %d Day %d unlock: %d days, %02d:%02d:%02d...%!" 
        year day days hours mins secs;
      
      Unix.sleep 1;
      loop ()
    end
  in
  loop ()

let last_year = 
  let today = Unix.time () |> Unix.localtime in
  today.tm_year + 1900

module Fetch = Fetch.Make(struct
  let year = Env_manager.get_env_int "YEAR" |> Option.value ~default:last_year
  let session = Env_manager.get_env_string "SESSION" |> Option.value ~default:""
end)

let template_path =
  Printf.sprintf "bin/template.txt"

let folder_path day =
  Printf.sprintf "days/day%02d" day

let module_path day =
  Printf.sprintf "days/day%02d/solution.ml" day

let fetch_input day =
  let input = Fetch.fetch_input day in
  let example = Fetch.fetch_example day in
   
  match input with
  | Ok content -> begin
      try
        Out_channel.write_all (Printf.sprintf "%s/input.txt" @@ folder_path day) ~data:content;
        printf "Input for day %d saved successfully.\n" day
      with _ -> ()
    end
  | Error _ -> printf "Could not fetch input for day %d.\n" day;

  match example with
  | Ok content -> begin
      try
        Out_channel.write_all (Printf.sprintf "%s/test.txt" @@ folder_path day) ~data:content;
        printf "Example for day %d saved successfully.\n" day
      with _ -> ()
    end
  | Error e -> printf "Could not fetch example for day %d.\n" day

let create_day_module year day =
  wait_for_unlock year day;

  if year >= 2025 && day > 12 then
    failwith "Year 2025 and beyond sadly only have puzzles up to day 12."
  else

  let folder = folder_path day in
    if not (Stdlib.Sys.file_exists folder) then Stdlib.Sys.mkdir folder 0o755;

  let module_path = Printf.sprintf "days/day%02d/solution.ml" day in

  if Stdlib.Sys.file_exists module_path then begin
    printf "Day already exists at %s. Not overwriting that.\n" module_path;
    fetch_input day
  end else begin
    let template = In_channel.read_all template_path in
    let replaced_template =
      String.substr_replace_all template ~pattern:"{{day}}" ~with_:(Int.to_string day)
    in
    Out_channel.write_all module_path ~data:replaced_template;

    printf "Created new day module at %s.\n" module_path;
    fetch_input day
  end

let () =
  Env_manager.load ();

  let year =
    Env_manager.get_env_int "YEAR"
    |> Option.value_exn ~message:"YEAR environment variable is not set."
  in
   
  if year < 2015 || year > last_year then
    failwith (Printf.sprintf "Invalid YEAR: %d. Must be between 2015 and %d." year last_year);
   
  let session =
    Env_manager.get_env_string "SESSION"
    |> Option.value_exn ~message:"SESSION environment variable is not set."
  in
   
  Fetch.set_session session;
  Fetch.set_year year;
   
  match args with
  | [|_|] -> begin
      let today = Unix.time () |> Unix.localtime in
      let day = today.tm_mday in
      let month = today.tm_mon + 1 in
      if month = 12 && day <= 25 then
        create_day_module year day
      else
        failwith "No arguments provided. Please specify a day to generate.\n"
  end
  | [|_; day|] -> begin
      match Int.of_string_opt day with
      | Some d when d >= 1 && d <= 25 -> create_day_module year d
      | _ -> failwith (Printf.sprintf "Invalid day: %s. Must be an integer between 1 and 25." day)
  end
  | _ -> failwith "Too many arguments provided. Please specify a single day to generate."
