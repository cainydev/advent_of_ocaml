(** Environment variable file interface.

    Reads and writes key=value pairs from a .env-style file.
    Keys are case-insensitive. Values are case-sensitive.
*)

(** [load ?filename ()] loads environment variables from the given file
    (default is ".env"). Existing entries in the internal store are overwritten. *)
val load : ?filename : string -> unit -> unit

(** [save ?filename ()] writes the current environment variables to the given file
    (default is ".env"). *)
val save : ?filename : string -> unit -> unit

(** [get_env_string key] retrieves the string value of the given key,
    case-insensitive. Returns [None] if not found. *)
val get_env_string : string -> string option

(** [set_env_string key value] sets the string value of the given key,
    case-insensitive. Overwrites existing value if present. *)
val set_env_string : string -> string -> unit

(** [get_env_int key] retrieves the integer value of the given key,
    case-insensitive. Returns [None] if not found or not a valid integer. *)
val get_env_int : string -> int option

(** [set_env_int key value] sets the given key to the string version of the integer. *)
val set_env_int : string -> int -> unit

