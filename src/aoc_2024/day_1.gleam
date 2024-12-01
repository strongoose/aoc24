import gleam/int
import gleam/list
import gleam/result
import gleam/string

/// Convert a list into a list of size 2 tuples. 
/// Panics on uneven-lengthed lists! This should probably return a Result instead.
fn chunk_by_2(list: List(value)) -> List(#(value, value)) {
  let tuplify = fn(l) {
    let assert [a, b] = l
    #(a, b)
  }

  list
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
  let #(list_a, list_b) = parse_input(input)

  let list_a = list.sort(list_a, by: int.compare)
  let list_b = list.sort(list_b, by: int.compare)

  list.zip(list_a, list_b)
  |> list.fold(from: 0, with: fn(acc, tuple) {
    let #(a, b) = tuple
    acc + int.absolute_value(a - b)
  })
}

pub fn pt_2(input: String) -> Int {
  todo
}
