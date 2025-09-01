open Base
open Aoc_lib.Helpers

let day = 6
type coord = int * int
type state = On | Off | Toggle
type t = (state * coord * coord) list

let re = Re.Pcre.regexp {|(turn on|turn off|toggle) (\d+),(\d+) through (\d+),(\d+)|}

let parse_input (input: string): t =
  String.split_lines input 
  |> List.map ~f:(fun line ->
      let gs = Re.Pcre.extract ~rex:re line in
      let op =
        match gs.(1) with
        | "turn on" -> On
        | "turn off" -> Off
        | "toggle" -> Toggle
        | _ -> failwith "Unknown operation"
      in 
      let x1 = Int.of_string gs.(2) in
      let y1 = Int.of_string gs.(3) in
      let x2 = Int.of_string gs.(4) in
      let y2 = Int.of_string gs.(5) in
      (op, (x1, y1), (x2, y2))
  )

let part1 (input: t): string =
  let grid = Grid.make 1000 1000 false in
  List.iter input ~f:(fun (op, (x1, y1), (x2, y2)) ->
    for x = x1 to x2 do
      for y = y1 to y2 do
        let current = Grid.get grid (x, y) in
        let new_val = match op with
          | On -> true
          | Off -> false
          | Toggle -> not current
        in
        Grid.set grid (x, y) new_val
      done
    done
  );
  Grid.fold (fun _ value acc -> if value then acc + 1 else acc) grid 0
  |> Int.to_string

let part2 (input: t): string =
  let grid = Grid.make 1000 1000 0 in
  List.iter input ~f:(fun (op, (x1, y1), (x2, y2)) ->
    for x = x1 to x2 do
      for y = y1 to y2 do
        match op with
        | On -> grid.(x).(y) <- grid.(x).(y) + 1
        | Off -> grid.(x).(y) <- max 0 (grid.(x).(y) - 1)
        | Toggle -> grid.(x).(y) <- grid.(x).(y) + 2
      done
    done
  );
  let total = ref 0 in
  for x = 0 to 999 do
    for y = 0 to 999 do
      total := !total + grid.(x).(y)
    done
  done;
  Int.to_string !total
