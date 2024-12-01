import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Convert a list into a list of size 2 tuples. 
/// Panics on uneven-lengthed lists! This should probably return a Result instead.
fn chunk_by_2(items: List(value)) -> List(#(value, value)) {
  let tuplify = fn(l) {
    let assert [a, b] = l
    #(a, b)
  }

  items
  |> list.sized_chunk(2)
  |> list.map(tuplify)
}

/// The elves have made two lists. These are provided as a single text file with two columns, i.e.
///   1    2
///   2    3
///   4   10
/// ...  ...
///
fn parse_input(input: String) -> #(List(Int), List(Int)) {
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

  numbers
  |> chunk_by_2
  |> list.unzip
}

pub fn pt_1(input: String) -> Int {
  let #(left, right) = parse_input(input)

  let left = list.sort(left, by: int.compare)
  let right = list.sort(right, by: int.compare)

  let difference = fn(tuple) {
    let #(a, b) = tuple
    int.absolute_value(a - b)
  }

  list.zip(left, right)
  |> list.map(difference)
  |> list.fold(from: 0, with: int.add)
}

fn similarity(number: Int, right_list: List(Int)) -> Int {
  let occurences =
    right_list
    |> list.filter(keeping: fn(x) { x == number })
    |> list.length

  number * occurences
}

pub fn pt_2(input: String) -> Int {
  let #(left, right) = parse_input(input)

  let similarity = similarity(_, right)

  left
  |> list.map(similarity)
  |> list.fold(from: 0, with: int.add)
}
