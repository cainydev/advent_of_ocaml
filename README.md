# 🎄 Advent of OCaml 🎄

A clean, efficient OCaml template for solving Advent of Code puzzles with automatic input fetching and smooth development workflow.

## ✨ Features

- 🚀 Auto setup with year/session prompts
- 📥 Automatic input downloading & caching
- 🏃 Fast execution with timing
- 🎯 Clean error handling
- 📁 Consistent day structure with `type t` pattern

## 🚀 Quick Start

### 🔧 Ensure Make is installed

```bash
# Arch Linux
sudo pacman -S make

# Ubuntu/Debian
sudo apt install make

# macOS
brew install make
```

### 📦 Install Dependencies

```bash
opam install dune base re lwt lwt_ppx cohttp-lwt-unix
```

### 🍪 Getting Your Session Cookie

1. Go to Advent of Code and log in
2. Open dev tools (F12) → Application → Cookies → adventofcode.com
3. Copy the session cookie value
4. Paste when prompted (saved automatically)

## 🔧 Commands

```bash
make run        # Run all days
make run 7      # Run day 7
make run 7 1    # Run day 7 part 1
make day 8      # Create day 8 scaffolding
make clean      # Clean build artifacts
```

## 🛠️ Workflow

1. Create day: make day 5
2. Define type t for your input format
3. Implement parse_input to transform raw string → t
4. Solve part1 and part2
5. Run: make run 5

## 📁 Structure

```
├── bin/                    # Scripts (don't touch)
├── lib/helpers.ml          # Shared utilities & algorithms  
├── days/dayXX/solution.ml  # Your solutions
```

## 📝 Day Template

Each day follows this pattern:

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
