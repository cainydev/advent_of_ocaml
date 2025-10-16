open Base
open Stdio

let args = Sys.get_argv ()

let last_year = 
  let today = Unix.time () |> Unix.localtime in
  let month = today.tm_mon + 1 in
  if month = 12 then today.tm_year + 1900 else today.tm_year + 1899

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

