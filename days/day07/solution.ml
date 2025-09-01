open Base
open Aoc_lib.Helpers

let day = 7

module Gate = struct
  module T = struct
    type t =
      | AND of string * string
      | OR of string * string
      | LSHIFT of string * int
      | RSHIFT of string * int
      | NOT of string 
    [@@deriving sexp, compare, hash]
  end
  include T
  include Comparable.Make(T)
end

module GateMap = Map.M(Gate)
type t = (string list) GateMap.t 

let parse_input (input: string): t =
  let add_gate map (gate, output) =
    Map.update map gate ~f:(function
      | None -> [output]
      | Some outputs -> output :: outputs)
  in
  
  String.split_lines input
  |> List.map ~f:(fun line ->
      match String.split line ~on:' ' with
      | ["NOT"; input; "->"; output] -> 
          Gate.NOT input, output
      | [input1; "AND"; input2; "->"; output] -> 
          Gate.AND (input1, input2), output
      | [input1; "OR"; input2; "->"; output] -> 
          Gate.OR (input1, input2), output
      | [input; "LSHIFT"; shift; "->"; output] -> 
          Gate.LSHIFT (input, Int.of_string shift), output
      | [input; "RSHIFT"; shift; "->"; output] -> 
          Gate.RSHIFT (input, Int.of_string shift), output
      | _ -> failwith ("Parse error: " ^ line))
  |> List.fold ~init:(Map.empty (module Gate)) ~f:add_gate

let part1 (input: t): string =
  Map.length input |> Int.to_string

let part2 (input: t): string = Map.length input |> Int.to_string
