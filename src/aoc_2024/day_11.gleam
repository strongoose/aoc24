import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

pub type Stone =
  String

pub type Stones =
  Dict(Stone, Int)

pub fn parse(input: String) -> Stones {
  input
  |> string.split(" ")
  |> list.group(fn(stone) { stone })
  |> dict.map_values(fn(_stone, group) { list.length(group) })
}

fn strip_zeros(str: String) -> String {
  case str {
    "0" <> tail if tail != "" -> strip_zeros(tail)
    _ -> str
  }
}

fn increment(stones: Stones, stone: Stone, n: Int) -> Stones {
  stones
  |> dict.upsert(stone, fn(opt) {
    case opt {
      Some(count) -> count + n
      None -> n
    }
  })
}

fn blink_stone(stone: Stone) -> List(Stone) {
  case stone, string.length(stone) {
    "0", _ -> ["1"]

    _, len if len % 2 == 0 -> [
      stone |> string.drop_end(len / 2),
      stone |> string.drop_start(len / 2) |> strip_zeros,
    ]

    _, _ -> {
      let assert Ok(n) = int.parse(stone)
      [n * 2024 |> int.to_string]
    }
  }
}

pub fn blink(initial_stones: Stones) -> Stones {
  let new_generation =
    initial_stones
    |> dict.map_values(fn(parent, count) { #(count, blink_stone(parent)) })
    |> dict.values

  use stones, #(parent_count, children) <- list.fold(new_generation, dict.new())
  use stones, child <- list.fold(children, stones)
  stones |> increment(child, parent_count)
}

pub fn pt_1(initial_stones: Stones) {
  list.repeat(1, 25)
  |> list.fold(initial_stones, fn(stones, _) { blink(stones) })
  |> dict.values
  |> int.sum
}

pub fn pt_2(initial_stones: Stones) {
  list.repeat(1, 75)
  |> list.fold(initial_stones, fn(stones, _) { blink(stones) })
  |> dict.values
  |> int.sum
}
