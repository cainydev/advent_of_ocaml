open Base

(** Some useful composition stuff *)
let ( << ) f g x = f (g x)
let ( >> ) f g x = g (f x)
let ( $ ) f x = f x

(** Some useful reexports *)
let const = Fn.const

(** exn helper *)
let exn_opt f x =
  try Some (f x)
  with _ -> None

(** math **)
let rec gcd (a: int) (b: int): int = if b = 0 then a else gcd b (a % b)
let gcd_of_list (lst: int list): int = List.fold ~init:1 ~f:gcd lst
let lcm (a: int) (b: int): int = a / (gcd a b) * b
let lcm_of_list (lst: int list): int = List.fold ~init:1 ~f:lcm lst

(** memo **)
let memo f =
  let t = Hashtbl.Poly.create ~growth_allowed:true () in
  (fun p -> Hashtbl.find_or_add t p ~default:(fun () -> f p))

let memo_rec f =
  let t = Hashtbl.Poly.create ~growth_allowed:true () in
  let rec g x =
    Hashtbl.find_or_add t x ~default:(fun () -> f g x)
  in g

(** permutations **)
let permutations xs =
  let rec aux acc xs =
    match xs with
    | [] -> [List.rev acc]
    | _ ->
      List.concat_map xs ~f:(fun x ->
        let rest = List.filter xs ~f:(Poly.(<>) x) in
        aux (x :: acc) rest
      )
  in
  aux [] xs

(** tuples **)
let fst3 (a, _, _) = a
let snd3 (_, b, _) = b
let thrd3 (_, _, c) = c

let fst4 (a, _, _, _) = a
let snd4 (_, b, _, _) = b
let thrd4 (_, _, c, _) = c
let frth4 (_, _, _, d) = d

let curry f a b = f (a, b)
let curry3 f a b c = f (a, b, c)
let curry4 f a b c d = f (a, b, c, d)

let uncurry f (a, b) = f a b
let uncurry3 f (a, b, c) = f a b c
let uncurry4 f (a, b, c, d) = f a b c d

(** list stuff **)
let positive_ints = Sequence.unfold ~init:0 ~f:(fun n -> Some (n, n + 1))

let zip l1 l2 =
  let rec aux acc l1 l2 =
    match l1, l2 with
    | x :: xs, y :: ys -> aux ((x, y) :: acc) xs ys
    | _, _ -> List.rev acc
  in
  aux [] l1 l2

let zipi l1 l2 =
  let rec aux n acc l1 l2 =
    match l1, l2 with
    | x :: xs, y :: ys -> aux (n + 1) ((n, (x, y)) :: acc) xs ys
    | _, _ -> List.rev acc
  in
  aux 0 [] l1 l2

let zip3 l1 l2 l3 =
  let rec aux acc l1 l2 l3 =
    match l1, l2, l3 with
    | x :: xs, y :: ys, z :: zs -> aux ((x, y, z) :: acc) xs ys zs
    | _, _, _ -> List.rev acc
  in
  aux [] l1 l2 l3

let zipi3 l1 l2 l3 =
  let rec aux n acc l1 l2 l3 =
    match l1, l2, l3 with
    | x :: xs, y :: ys, z :: zs -> aux (n + 1) ((n, (x, y, z)) :: acc) xs ys zs
    | _, _, _ -> List.rev acc
  in
  aux 0 [] l1 l2 l3

let zip4 l1 l2 l3 l4 =
  let rec aux acc l1 l2 l3 l4 =
    match l1, l2, l3, l4 with
    | x :: xs, y :: ys, z :: zs, w :: ws ->
        aux ((x, y, z, w) :: acc) xs ys zs ws
    | _, _, _, _ -> List.rev acc
  in
  aux [] l1 l2 l3 l4

let zipi4 l1 l2 l3 l4 =
  let rec aux n acc l1 l2 l3 l4 =
    match l1, l2, l3, l4 with
    | x :: xs, y :: ys, z :: zs, w :: ws ->
        aux (n + 1) ((n, (x, y, z, w)) :: acc) xs ys zs ws
    | _, _, _, _ -> List.rev acc
  in
  aux 0 [] l1 l2 l3 l4
