import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/string

// import aoc_2024/lib.{chunk_by_2}

/// The elves have made two lists. These are provided as a single text file with two columns, i.e.
///   1    2
///   2    3
///   4   10
/// ...  ...
///
pub fn parse(input: String) -> #(List(Int), List(Int)) {
  input
  |> string.split("\n")
  |> list.map(fn(line) {
    let assert [Ok(a), Ok(b)] =
      string.split(line, "   ")
      |> list.map(int.parse)
    #(a, b)
  })
  |> list.unzip
}

pub fn pt_1(input: #(List(Int), List(Int))) -> Int {
  let #(left, right) = input

  let left = list.sort(left, by: int.compare)
  let right = list.sort(right, by: int.compare)

  let difference = fn(a, b) { int.absolute_value(a - b) }

  list.map2(left, right, difference)
  |> int.sum
}

fn count_all(items: List(value)) -> Dict(value, Int) {
  list.group(items, function.identity)
  |> dict.map_values(fn(_, vs) { list.length(vs) })
}

pub fn pt_2(input: #(List(Int), List(Int))) -> Int {
  let #(left, right) = input

  let counts = count_all(right)

  let similarity = fn(number) {
    let occurrences =
      counts
      |> dict.get(number)
      |> result.unwrap(0)

    number * occurrences
  }

  left
  |> list.map(similarity)
  |> int.sum
}
