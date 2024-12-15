import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

import aoc_2024/lib.{type Coord, type Grid, Coord, add_coord, grid_to_string}

pub type Map {
  Map(grid: Dict(Coord, Cell), robot_at: Coord)
}

pub type Cell {
  Box
  BoxL
  BoxR
  Robot
  Wall
  Empty
}

fn insert(map: Map, coord: Coord, cell: Cell) {
  let grid =
    map.grid
    |> dict.insert(coord, cell)
  Map(..map, grid: grid)
}

fn get(map: Map, coord: Coord) -> Result(Cell, Nil) {
  map.grid |> dict.get(coord)
}

pub type Direction =
  Coord

pub fn parse(input: String) -> #(Map, List(Direction)) {
  let assert Ok(#(raw_map, raw_moves)) = string.split_once(input, "\n\n")
  #(parse_map(raw_map), parse_moves(raw_moves))
}

pub fn parse_map(input: String) -> Map {
  let map = Map(dict.new(), Coord(0, 0))
  use map, line, y <- list.index_fold(string.split(input, "\n"), map)
  use map, char, x <- list.index_fold(string.to_graphemes(line), map)

  let here = Coord(y, x)
  let cell = case char {
    "#" -> Wall
    "O" -> Box
    "@" -> Robot
    "." -> Empty
    _ -> panic as "invalid map input"
  }

  case cell {
    Robot -> Map(..map, robot_at: here) |> insert(here, cell)
    _ -> map |> insert(here, cell)
  }
}

pub fn parse_moves(input: String) -> List(Direction) {
  input
  |> string.split("\n")
  |> string.join("")
  |> string.to_graphemes()
  |> list.map(fn(char) {
    case char {
      "^" -> Coord(-1, 0)
      "v" -> Coord(1, 0)
      "<" -> Coord(0, -1)
      ">" -> Coord(0, 1)
      _ -> panic as "invalid move input"
    }
  })
}

fn move(map: Map, from: Coord, dir: Direction) -> Map {
  let to = add_coord(from, dir)

  let assert Ok(cell) = get(map, from)

  case cell {
    Robot ->
      Map(..map, robot_at: to)
      |> insert(from, Empty)
      |> insert(to, Robot)
    _ ->
      map
      |> insert(from, Empty)
      |> insert(to, cell)
  }
}

pub fn push(map: Map, from: Coord, dir: Direction) -> Result(Map, Nil) {
  let to = add_coord(from, dir)

  let is_horizontal = dir.x == 0

  case get(map, from), is_horizontal {
    Ok(Empty), _ -> Ok(map)

    // Move a wide box up or down
    Ok(BoxL), True -> push_two(map, from, dir)
    Ok(BoxR), True -> push_two(map, add_coord(from, Coord(0, -1)), dir)

    Ok(Box), _ | Ok(Robot), _ | Ok(BoxL), _ | Ok(BoxR), _ -> {
      // Try to move destination cell
      use map <- result.try(push(map, to, dir))
      // If it succeds, move this tile too
      Ok(move(map, from, dir))
    }

    Ok(Wall), _ | Error(_), _ -> Error(Nil)
  }
}

pub fn push_two(map: Map, from_left: Coord, dir: Direction) -> Result(Map, Nil) {
  let from_right = add_coord(from_left, Coord(0, 1))
  let to_left = add_coord(from_left, dir)
  let to_right = add_coord(from_right, dir)

  use map <- result.try(push(map, to_left, dir))
  use map <- result.map(push(map, to_right, dir))
  map |> move(from_left, dir) |> move(from_right, dir)
}

pub fn move_robot(map: Map, dir: Direction) -> Map {
  case push(map, map.robot_at, dir) {
    Ok(updated_map) -> updated_map
    Error(_) -> map
  }
}

fn gps(coord: Coord) -> Int {
  let Coord(y, x) = coord
  100 * y + x
}

pub fn pt_1(input: #(Map, List(Direction))) -> Int {
  let #(map, moves) = input
  let map =
    moves
    |> list.fold(map, move_robot)

  map.grid
  |> dict.filter(fn(_, cell) { cell == Box })
  |> dict.keys
  |> list.map(gps)
  |> int.sum
}

pub fn expand_map(map: Map) -> Map {
  let expanded = Map(dict.new(), robot_at: Coord(0, 0))
  use expanded, coord, cell <- dict.fold(map.grid, expanded)

  let Coord(y, x) = coord
  let left = Coord(y, x * 2)
  let right = Coord(y, x * 2 + 1)
  let map = case cell {
    Box -> expanded |> insert(left, BoxL) |> insert(right, BoxR)
    Wall -> expanded |> insert(left, Wall) |> insert(right, Wall)
    Robot -> expanded |> insert(left, Robot) |> insert(right, Empty)
    Empty -> expanded |> insert(left, Empty) |> insert(right, Empty)
    BoxL | BoxR -> panic as "can't expand already expanded map"
  }

  case cell {
    Robot -> Map(..map, robot_at: left)
    _ -> map
  }
}

pub fn pt_2(input: #(Map, List(Direction))) {
  let #(map, moves) = input

  let map =
    moves
    |> list.fold(expand_map(map), move_robot)

  map.grid
  |> dict.filter(fn(_, cell) { cell == BoxL })
  |> dict.keys
  |> list.map(gps)
  |> int.sum
}

// -- Debugging --

pub fn map_to_grid(map: Map) -> Grid {
  use _, cell <- dict.map_values(map.grid)
  case cell {
    Empty -> "."
    Wall -> "#"
    Robot -> "@"
    Box -> "O"
    BoxL -> "["
    BoxR -> "]"
  }
}

pub fn map_to_string(map: Map) -> String {
  map |> map_to_grid |> grid_to_string
}
