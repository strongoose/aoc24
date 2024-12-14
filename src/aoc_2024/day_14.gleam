import gleam/bool
import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/string

import aoc_2024/lib.{type Coord, Coord, add_coord, scale_coord}

const max_y = 102

const max_x = 100

pub type Robot {
  Robot(position: Coord, velocity: Coord)
}

fn coord_from_string(s: String) -> Result(Coord, Nil) {
  case string.split(s, ",") |> list.map(int.parse) {
    [Ok(x), Ok(y)] -> Ok(Coord(y, x))
    _ -> Error(Nil)
  }
}

pub fn parse(input: String) -> List(Robot) {
  use robots, line <- list.fold(string.split(input, "\n"), [])
  let assert ["p=" <> raw_pos, "v=" <> raw_vel] = string.split(line, " ")
  let assert Ok(pos) = coord_from_string(raw_pos)
  let assert Ok(vel) = coord_from_string(raw_vel)

  [Robot(pos, vel), ..robots]
}

fn run(robot: Robot, for seconds: Int) -> Coord {
  add_coord(robot.position, scale_coord(robot.velocity, seconds))
  |> wrap
}

fn wrap(coord: Coord) -> Coord {
  let Coord(y, x) = coord
  let assert Ok(y) = int.modulo(y, max_y + 1)
  let assert Ok(x) = int.modulo(x, max_x + 1)
  Coord(y, x)
}

type Quadrant {
  TopLeft
  TopRight
  BottomLeft
  BottomRight
}

fn quadrant_of(coord: Coord) -> Result(Quadrant, Nil) {
  let Coord(y, x) = coord

  let mid_y = max_y / 2
  let mid_x = max_x / 2

  use <- bool.guard(y == mid_y || x == mid_x, return: Error(Nil))

  case y < max_y / 2, x < max_x / 2 {
    True, True -> Ok(TopLeft)
    True, False -> Ok(TopRight)
    False, True -> Ok(BottomLeft)
    False, False -> Ok(BottomRight)
  }
}

pub fn pt_1(robots: List(Robot)) {
  robots
  |> list.map(run(_, 100))
  |> list.group(quadrant_of)
  |> dict.drop([Error(Nil)])
  |> dict.values
  |> list.map(list.length)
  |> int.product
}

pub fn pt_2(robots: List(Robot)) {
  todo as "part 2 not implemented"
}
