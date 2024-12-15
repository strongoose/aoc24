////
//// This one took me a long time - I completely refactored part 1 after writing is_x_mas for part 2 and being inordinately pleased with it.
////

import gleam/dict
import gleam/list.{range}
import gleam/result
import gleam/string

import aoc_2024/lib.{type Coord, type Grid, Coord}

pub fn parse(input: String) -> Grid {
  use grid, line, y <- list.index_fold(string.split(input, "\n"), dict.new())
  use grid, char, x <- list.index_fold(string.to_graphemes(line), grid)

  grid |> dict.insert(Coord(y, x), char)
}

fn coord_add(a: Coord, b: Coord) -> Coord {
  let Coord(ay, ax) = a
  let Coord(by, bx) = b
  Coord(ay + by, ax + bx)
}

fn coord_mul(coord: Coord, by n: Int) -> Coord {
  let Coord(y, x) = coord
  Coord(n * y, n * x)
}

/// Fetch the substring corresponding to a list of coordinates from the grid.
/// Returns an error if *any* coordinate is out of bounds
fn grid_substring(grid: Grid, coords: List(Coord)) -> Result(String, Nil) {
  coords
  |> list.map(dict.get(grid, _))
  |> result.all
  |> result.map(string.join(_, ""))
}

fn count_xmases_from(grid: Grid, start: Coord) -> Int {
  let directions = [
    Coord(0, 1),
    Coord(0, -1),
    Coord(1, 0),
    Coord(-1, 0),
    Coord(1, 1),
    Coord(1, -1),
    Coord(-1, 1),
    Coord(-1, -1),
  ]

  use direction <- list.count(directions)
  let substring =
    range(0, 3)
    |> list.map(fn(distance) {
      coord_add(start, coord_mul(direction, distance))
    })
    |> grid_substring(grid, _)
  case substring {
    Ok("XMAS") -> True
    _ -> False
  }
}

pub fn pt_1(input: Grid) -> Int {
  use total, #(coord, char) <- list.fold(dict.to_list(input), 0)
  case char {
    "X" -> total + count_xmases_from(input, coord)
    _ -> total
  }
}

fn is_x_mas(grid: Grid, start: Coord) -> Bool {
  let firstmas =
    [Coord(-1, -1), Coord(0, 0), Coord(1, 1)]
    |> list.map(coord_add(start, _))
    |> grid_substring(grid, _)

  let secondmas =
    [Coord(-1, 1), Coord(0, 0), Coord(1, -1)]
    |> list.map(coord_add(start, _))
    |> grid_substring(grid, _)

  case firstmas, secondmas {
    Ok("MAS"), Ok("MAS") -> True
    Ok("MAS"), Ok("SAM") -> True
    Ok("SAM"), Ok("MAS") -> True
    Ok("SAM"), Ok("SAM") -> True

    _, _ -> False
  }
}

pub fn pt_2(input: Grid) -> Int {
  use #(coord, char) <- list.count(dict.to_list(input))
  case char {
    "A" -> is_x_mas(input, coord)
    _ -> False
  }
}
