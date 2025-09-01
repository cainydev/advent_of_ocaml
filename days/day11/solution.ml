open Base
open Aoc_lib.Helpers

let day = 11
type t = string list

let parse_input (input: string): t = String.split_lines input

let part1 (input: t): string = List.length input |> Int.to_string

let part2 (input: t): string = List.length input |> Int.to_string
