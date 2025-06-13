module type S = sig
  (** The interface that every day's solution must implement. *)

  (** [part1] solves the first part of the day's puzzle. *)
  val part1 : unit -> string

  (** [part2 unit] solves the second part of the day's puzzle. *)
  val part2 : unit -> string
end
