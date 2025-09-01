(** Some useful composition stuff *)
let ( << ) f g x = f (g x)

let ( >> ) f g x = g (f x)

let ( $ ) f x = f x

(** Some useful reexports *)
let const = Fun.const

(** exn helper *)
let exn_opt f x =
  try Some (f x)
  with _ -> None
