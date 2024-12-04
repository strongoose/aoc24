////
//// This one took me a long time - I completely refactored part 1 after writing is_x_mas for part 2 and being inordinately pleased with it.
////

import gleam/dict.{type Dict}
import gleam/int
import gleam/list.{range}
import gleam/result
import gleam/string

pub type Coord =
  #(Int, Int)

pub type Grid(a) {
  Grid(coords: Dict(Coord, a), width: Int, height: Int)
}

pub fn parse(input: String) -> Grid(String) {
  let char_array =
    input
    |> string.split("\n")
    |> list.map(string.to_graphemes)

  let assert Ok(first_line) = list.first(char_array)

  let width = list.length(first_line)
  let height = list.length(char_array)

  let coords =
    char_array
    |> list.flatten
    |> list.index_map(fn(el, i) {
      let coord = #(i / width, i % width)
      #(coord, el)
    })
    |> dict.from_list

  Grid(coords, width, height)
}

fn map_array(arr: List(List(a)), fun: fn(a) -> b) -> List(List(b)) {
  list.map(arr, list.map(_, fun))
}

fn add_coords(a: Coord, b: Coord) -> Coord {
  let #(ay, ax) = a
  let #(by, bx) = b
  #(ay + by, ax + bx)
}

fn grid_substring(
  grid: Grid(String),
  coords: List(Coord),
) -> Result(String, Nil) {
  coords
  |> list.map(dict.get(grid.coords, _))
  |> result.all
  |> result.map(string.join(_, ""))
}

fn count_xmases_from(grid: Grid(String), start: Coord) -> Int {
  let relative_substr_coords: List(List(Coord)) =
    range(0, 3)
    |> list.map(fn(i) {
      [
        #(0, i),
        #(0, -i),
        #(i, 0),
        #(-i, 0),
        #(i, i),
        #(i, -i),
        #(-i, i),
        #(-i, -i),
      ]
    })
    |> list.transpose

  let substr_coords = relative_substr_coords |> map_array(add_coords(start, _))

  substr_coords
  |> list.map(grid_substring(grid, _))
  |> list.filter(fn(substr) {
    case substr {
      Ok("XMAS") -> True
      _ -> False
    }
  })
  |> list.length
}

pub fn pt_1(input: Grid(String)) -> Int {
  input.coords
  |> dict.to_list
  |> list.map(fn(kv) {
    let #(coord, char) = kv
    case char {
      "X" -> count_xmases_from(input, coord)
      _ -> 0
    }
  })
  |> int.sum
}

fn is_x_mas(grid: Grid(String), coord: Coord) -> Bool {
  let firstmas =
    [#(-1, -1), #(0, 0), #(1, 1)]
    |> list.map(add_coords(coord, _))
    |> grid_substring(grid, _)

  let secondmas =
    [#(-1, 1), #(0, 0), #(1, -1)]
    |> list.map(add_coords(coord, _))
    |> grid_substring(grid, _)

  case firstmas, secondmas {
    Ok("MAS"), Ok("MAS") -> True
    Ok("MAS"), Ok("SAM") -> True
    Ok("SAM"), Ok("MAS") -> True
    Ok("SAM"), Ok("SAM") -> True

    _, _ -> False
  }
}

pub fn pt_2(input: Grid(String)) -> Int {
  input.coords
  |> dict.to_list
  |> list.filter(fn(kv) {
    let #(coord, char) = kv
    case char {
      "A" -> is_x_mas(input, coord)
      _ -> False
    }
  })
  |> list.length
}
