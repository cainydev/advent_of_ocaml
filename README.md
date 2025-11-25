# 🎄 Advent of OCaml

A clean OCaml (+ JaneStreet Base) template for Advent of Code, featuring automatic input fetching, execution timing, and a consistent type-safe pattern for solutions.

### [Use this Template](https://github.com/new?template_name=advent_of_ocaml&template_owner=cainydev)
And then read the instructions. Or the other way around, it doesn't matter.

### Prerequisites
Ensure you have `make` installed:

```bash
# Arch Linux
sudo pacman -S make

# Ubuntu/Debian
sudo apt install make

# macOS
brew install make
```

Install the dependencies on your opam switch:
```bash
opam install dune base re lwt lwt_ppx cohttp-lwt-unix
```

### Get your session cookie

1. Go to [Advent of Code](https://adventofcode.com) and log in
2. Open dev tools (F12) → Application → Cookies → adventofcode.com
3. Copy the session cookie value
4. Run a command (e.g., `make run`); you will be prompted to paste the cookie once.

### Available Commands

```bash
make run        # Run all days
make run 7      # Run day 7
make run 7 1    # Run day 7 part 1
make day 8      # Create day 8 scaffolding
make clean      # Clean build artifacts
```

### Development Workflow

The template enforces a pattern using a custom type t to separate parsing from logic.
- Parse: Define type t in solution.ml to match the day's data structure. Implement parse_input to convert the raw string into t.
- Solve: Implement part1 and part2. Both functions accept t and must return a string.

For example:

1. Create day: `make day 5`
2. Define type t for your input format
3. Implement parse_input to transform raw string → t
4. Solve part1 and part2
5. Run: `make run 5`

### Directory Structure

```
├── bin/                 # This repo's scripts (don't touch)
├── lib/helpers.ml       # Shared utilities & algorithms
└── days/
    └── dayXX/
        ├── input.txt    # The fetched input 
        └── solution.ml  # Daily implementation
```

### Day Template

Your solution file will look like this:

```ocaml
open Base
open Aoc_lib.Helpers

let day = 11
type t = string list                    (* Define your parsed input type *)

let parse_input (input: string): t =    (* Parse raw input *)
  String.split_lines input

let part1 (input: t): string =          (* Solve part 1 *)
  List.length input |> Int.to_string

let part2 (input: t): string =          (* Solve part 2 *)
  List.length input |> Int.to_string
```

Happy coding! 🎄✨
