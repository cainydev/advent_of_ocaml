module type S = sig
  (** The interface that every day's solution must implement. *)

  (** [t] represents the input type for the day's puzzle. *)
  type t
  
  (** [day] is the day number of the puzzle. *)
  val day : int

  (** [parse_input] parses the input file to the input format *)
  val parse_input : string -> t

  (** [part1] solves the first part of the day's puzzle. *)
  val part1 : t -> string

  (** [part2] solves the second part of the day's puzzle. *)
  val part2 : t -> string
end
