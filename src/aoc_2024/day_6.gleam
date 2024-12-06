import gleam/dict.{type Dict}
import gleam/int
import gleam/list.{type ContinueOrStop, Continue, Stop}
import gleam/string

type Coordinate =
  #(Int, Int)

pub fn add_coord(a: Coordinate, b: Coordinate) -> Coordinate {
  let #(ay, ax) = a
  let #(by, bx) = b

  #(ay + by, ax + bx)
}

pub type Direction {
  North
  South
  East
  West
}

pub type Cell {
  Obstacle
  Visited
  Unvisited
}

pub type Guard {
  Guard(at: Coordinate, facing: Direction)
}

pub type Map {
  Map(cells: Dict(Coordinate, Cell), guard: Guard, width: Int, height: Int)
}

pub fn parse(input: String) -> Map {
  let map = Map(dict.new(), Guard(#(0, 0), North), 0, 0)

  use map, row, y <- list.index_fold(string.split(input, "\n"), map)
  use map, mark, x <- list.index_fold(string.to_graphemes(row), map)

  let cell = case mark {
    "#" -> Obstacle
    "." -> Unvisited
    "^" -> Visited
    _ -> panic as "Bad input"
  }

  let cells = map.cells |> dict.insert(#(y, x), cell)
  let width = int.max(map.width, x + 1)
  let height = int.max(map.height, y + 1)

  let new_map = Map(..map, cells: cells, width: width, height: height)

  case cell {
    // This is the initial guard position
    Visited -> Map(..new_map, guard: Guard(..map.guard, at: #(y, x)))
    _ -> new_map
  }
}

fn pivot_guard(map: Map) -> Map {
  Map(
    ..map,
    guard: case map.guard {
      Guard(_, North) -> Guard(..map.guard, facing: East)
      Guard(_, East) -> Guard(..map.guard, facing: South)
      Guard(_, South) -> Guard(..map.guard, facing: West)
      Guard(_, West) -> Guard(..map.guard, facing: North)
    },
  )
}

pub fn tick(map: Map) -> ContinueOrStop(Map) {
  let next = case map.guard {
    Guard(at, North) -> add_coord(at, #(-1, 0))
    Guard(at, South) -> add_coord(at, #(1, 0))
    Guard(at, East) -> add_coord(at, #(0, 1))
    Guard(at, West) -> add_coord(at, #(0, -1))
  }

  case dict.get(map.cells, next) {
    Error(_) -> map |> Stop
    Ok(Obstacle) -> map |> pivot_guard |> Continue
    Ok(_) ->
      Map(
        ..map,
        cells: dict.insert(map.cells, next, Visited),
        guard: Guard(..map.guard, at: next),
      )
      |> Continue
  }
}

pub fn execute(map: Map) -> Map {
  case tick(map) {
    Continue(map) -> execute(map)
    Stop(map) -> map
  }
}

pub fn pt_1(map: Map) -> Int {
  let is_visited = fn(cell) { cell == Visited }

  execute(map).cells
  |> dict.values()
  |> list.filter(is_visited)
  |> list.length
}

pub fn pt_2(map: Map) -> Int {
  todo as "part 2 not implemented"
}
