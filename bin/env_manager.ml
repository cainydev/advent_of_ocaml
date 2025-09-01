let default_filename = ".env"

let env_table : (string, string) Hashtbl.t = Hashtbl.create 32

let normalize_key key = String.lowercase_ascii (String.trim key)

let parse_line line =
  try
    let idx = String.index line '=' in
    let key = String.sub line 0 idx |> String.trim in
    let value = String.sub line (idx + 1) (String.length line - idx - 1) |> String.trim in
    Some (key, value)
  with Not_found -> None

let load ?(filename=default_filename) () =
  if Sys.file_exists filename then
    let ch = open_in filename in
    try
      while true do
        let line = input_line ch in
        match parse_line line with
        | Some (k, v) -> Hashtbl.replace env_table (normalize_key k) v
        | None -> ()
      done
    with End_of_file -> close_in ch

let save ?(filename=default_filename) () =
  let ch = open_out filename in
  Hashtbl.iter
    (fun key value ->
        Printf.fprintf ch "%s=%s\n" key value)
    env_table;
  close_out ch

let get_env_string key =
  let k = normalize_key key in
  try Some (Hashtbl.find env_table k)
  with _ -> None

let set_env_string key value =
  let k = normalize_key key in
  Hashtbl.replace env_table k value

let get_env_int key =
  match get_env_string key with
  | Some v -> (try Some (int_of_string v) with Failure _ -> None)
  | None -> None

let set_env_int key value =
  set_env_string key (string_of_int value)

