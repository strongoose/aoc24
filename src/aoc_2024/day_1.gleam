import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/result
import gleam/string

import aoc_2024/lib.{chunk_by_2}

/// The elves have made two lists. These are provided as a single text file with two columns, i.e.
///   1    2
///   2    3
///   4   10
/// ...  ...
///
pub fn parse(input: String) -> #(List(Int), List(Int)) {
  let lines =
    input
    |> string.trim
    |> string.split(on: "\n")

  let assert Ok(numbers) =
    lines
    // The columns are separated by 3 spaces
    |> list.map(string.split(_, on: "   "))
    |> list.flatten
    |> list.map(int.parse)
    // Flatten the list of Results into a Result containing a list
    //   List(Result(a, b)) -> Result(List(a), b)
    |> result.all()

  let assert Ok(pairs) = chunk_by_2(numbers)
  list.unzip(pairs)
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
    let occurences =
      counts
      |> dict.get(number)
      |> result.unwrap(0)

    number * occurences
  }

  left
  |> list.map(similarity)
  |> int.sum
}
