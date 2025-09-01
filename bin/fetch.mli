(** Interface for fetching Advent of Code problems and input using a session cookie.
    The module is parameterized by a [Config] specifying the year and session token.
*)

open Base

(** Configuration for the fetcher module. *)
module type Config = sig
  val year : int
  val session : string
end

(** [Make(Config)] creates a module with fetching capabilities for a specific year and session. *)
module Make (C : Config) : sig
  (** Set the year. *)
  val set_year : int -> unit

  (** Set the session cookie. *)
  val set_session : string -> unit
  
  (** Check if session is valid by fetching an input. *)
  val session_valid : string -> bool

  (** Fetch the puzzle input text file for the given day. *)
  val fetch_input : int -> (string, string) Result.t

  (** Fetch and parse the example input for the given day. *)
  val fetch_example : int -> (string, string) Result.t
end

