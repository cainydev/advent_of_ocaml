open Base

module type Weight = sig
  type t [@@deriving sexp]
  val zero : t
  val add : t -> t -> t
  val compare : t -> t -> int
  val min_bound : t
  val max_bound : t
  val is_valid : t -> bool
  val to_string : t -> string
end

module Int_weight : Weight with type t = int = struct
  type t = int [@@deriving sexp]
  let zero = 0
  let add = ( + )
  let compare = Int.compare
  let min_bound = Int.min_value
  let max_bound = Int.max_value
  let is_valid x = x <> min_bound && x <> max_bound
  let to_string = Int.to_string
end

module Float_weight : Weight with type t = float = struct
  type t = float [@@deriving sexp]
  let zero = 0.
  let add = ( +. )
  let compare = Float.compare
  let min_bound = Float.neg_infinity
  let max_bound = Float.infinity
  let is_valid x = not (Float.is_nan x)
  let to_string = Float.to_string
end

module Make (W : Weight) = struct
  let hamiltonian_path ~maximize ~cost : W.t * int list =
    let n = Array.length cost in
    let size = 1 lsl n in
    let sentinel = if maximize then W.min_bound else W.max_bound in
    let dp = Array.make_matrix ~dimx:size ~dimy:n sentinel in
    let parent = Array.make_matrix ~dimx:size ~dimy:n (-1) in
    for i = 0 to n - 1 do
      dp.(1 lsl i).(i) <- W.zero
    done;
    for s = 1 to size - 1 do
      for j = 0 to n - 1 do
        if (s lsr j) land 1 = 1 then
          let prev = s lxor (1 lsl j) in
          for k = 0 to n - 1 do
            if j <> k && ((s lsr k) land 1 = 1) && W.is_valid dp.(prev).(k) then
              let candidate = W.add dp.(prev).(k) cost.(k).(j) in
              let better =
                if maximize then W.compare candidate dp.(s).(j) > 0
                else W.compare candidate dp.(s).(j) < 0
              in
              if better then (
                dp.(s).(j) <- candidate;
                parent.(s).(j) <- k
              )
          done
      done
    done;
    let best_cost = ref sentinel in
    let best = ref 0 in
    for i = 0 to n - 1 do
      let v = dp.(size - 1).(i) in
      let better =
        if maximize then W.compare v !best_cost > 0 else W.compare v !best_cost < 0
      in
      if better then (
        best_cost := v;
        best := i
      )
    done;
    let rec build_path s j acc =
      if parent.(s).(j) = -1 then j :: acc
      else build_path (s lxor (1 lsl j)) parent.(s).(j) (j :: acc)
    in
    let path = build_path (size - 1) !best [] in
    (!best_cost, List.rev path)

  let hamiltonian_cycle ~maximize ~cost : W.t * int list =
    let n = Array.length cost in
    let size = 1 lsl n in
    let sentinel = if maximize then W.min_bound else W.max_bound in
    let dp = Array.make_matrix ~dimx:size ~dimy:n sentinel in
    let parent = Array.make_matrix ~dimx:size ~dimy:n (-1) in
    dp.(1).(0) <- W.zero;
    for s = 1 to size - 1 do
      for j = 0 to n - 1 do
        if (s lsr j) land 1 = 1 then
          let prev = s lxor (1 lsl j) in
          for k = 0 to n - 1 do
            if j <> k && ((s lsr k) land 1 = 1) && W.is_valid dp.(prev).(k) then
              let candidate = W.add dp.(prev).(k) cost.(k).(j) in
              let better =
                if maximize then W.compare candidate dp.(s).(j) > 0
                else W.compare candidate dp.(s).(j) < 0
              in
              if better then (
                dp.(s).(j) <- candidate;
                parent.(s).(j) <- k
              )
          done
      done
    done;
    let best_cost = ref sentinel in
    let best = ref 0 in
    for i = 1 to n - 1 do
      if W.is_valid dp.(size - 1).(i) then
        let candidate = W.add dp.(size - 1).(i) cost.(i).(0) in
        let better =
          if maximize then W.compare candidate !best_cost > 0
          else W.compare candidate !best_cost < 0
        in
        if better then (
          best_cost := candidate;
          best := i
        )
    done;
    let rec build_cycle s j acc =
      if parent.(s).(j) = -1 then j :: acc
      else build_cycle (s lxor (1 lsl j)) parent.(s).(j) (j :: acc)
    in
    let cycle = build_cycle (size - 1) !best [] in
    let cycle = 0 :: (List.rev cycle) in
    (!best_cost, cycle)
end
