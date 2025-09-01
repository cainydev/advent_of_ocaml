open Base
open Stdio

module type Config = sig
  val year : int
  val session : string
end

module Make (C : Config) = struct
  let year = ref C.year
  let session = ref C.session
  
  let set_year y = year := y
  let set_session s = session := s

  let fetch_with_header ~url ~header : (string, string) Result.t =
    let buffer = Buffer.create 65536 in
    let connection = Curl.init () in
    try
      Curl.set_url connection url;
      Curl.set_httpheader connection [header];
      Curl.set_writefunction connection (fun s -> Buffer.add_string buffer s; String.length s);
      Curl.perform connection;
      let code = Curl.get_responsecode connection in
      Curl.cleanup connection;
      match code with
      | 200 -> Ok (Buffer.contents buffer)
      | 400 -> Error "Authentication failed (HTTP 400). Is your session token correct?"
      | 404 -> Error "Resource not found (HTTP 404). Does this year/day exists?"
      | _   -> Error (Printf.sprintf "Unexpected response code: %d" code)
    with
    | Curl.CurlException (err, _, _) ->
        Curl.cleanup connection;
        Error (Printf.sprintf "Curl error: %s" (Curl.strerror err))
  
  let fetch ~url =
    fetch_with_header ~header:("Cookie: session=" ^ !session) ~url
  
  let session_valid s =
    let old_session = !session in
    session := s;
    match fetch ~url:"https://adventofcode.com/2015/day/1/input" with
    | Ok _ -> true
    | Error e -> printf "%s" e; session := old_session; false

  let problem_url day =
    Printf.sprintf "https://adventofcode.com/%d/day/%d" !year day

  let input_url day =
    Printf.sprintf "https://adventofcode.com/%d/day/%d/input" !year day

  let fetch_problem day = fetch ~url:(problem_url day) 

  let extract_example html =
    let re = Str.regexp "<pre><code>\\(.*?\\)</code></pre>" in
    try
      ignore (Str.search_forward re html 0);
      Ok (Str.matched_group 1 html)
    with _ ->
      Error "Couldn't extract example input from the problem HTML."

  let fetch_input day = fetch ~url:(input_url day)

  let fetch_example day =
    fetch_problem day |> Result.bind ~f:extract_example
end
