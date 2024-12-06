import gleam/dict.{type Dict}
import gleam/int
import gleam/list
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
  Visited(Direction)
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
    "^" -> Visited(North)
    _ -> panic as "Bad input"
  }

  let cells = map.cells |> dict.insert(#(y, x), cell)
  let width = int.max(map.width, x + 1)
  let height = int.max(map.height, y + 1)

  let new_map = Map(..map, cells: cells, width: width, height: height)

  case cell {
    // This is the initial guard position
    Visited(_) -> Map(..new_map, guard: Guard(..map.guard, at: #(y, x)))
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

pub type ContinueStopOrLoop(a) {
  Continue(a)
  Stop(a)
  Loop(a)
}

pub fn tick(map: Map) -> ContinueStopOrLoop(Map) {
  let next = case map.guard {
    Guard(at, North) -> add_coord(at, #(-1, 0))
    Guard(at, South) -> add_coord(at, #(1, 0))
    Guard(at, East) -> add_coord(at, #(0, 1))
    Guard(at, West) -> add_coord(at, #(0, -1))
  }

  case dict.get(map.cells, next) {
    // -- End conditions
    // Out of bounds - the guard has left
    Error(_) -> map |> Stop
    // A visited location where the guard was facing the same // direction - they're in a loop!
    Ok(Visited(direction)) if direction == map.guard.facing -> map |> Loop

    // -- Otherwise...
    Ok(Obstacle) -> map |> pivot_guard |> Continue
    Ok(_) ->
      Map(
        ..map,
        cells: dict.insert(map.cells, next, Visited(map.guard.facing)),
        guard: Guard(..map.guard, at: next),
      )
      |> Continue
  }
}

pub type Status(a) {
  Stopped(a)
  Looped(a)
}

pub fn execute(map: Map) -> Status(Map) {
  case tick(map) {
    Continue(map) -> execute(map)
    Stop(map) -> Stopped(map)
    Loop(map) -> Looped(map)
  }
}

pub fn pt_1(map: Map) -> Int {
  let is_visited = fn(cell) {
    case cell {
      Visited(_) -> True
      _ -> False
    }
  }
  let assert Stopped(map) = execute(map)

  map.cells
  |> dict.values()
  |> list.filter(is_visited)
  |> list.length
}

pub fn pt_2(map: Map) -> Int {
  // If we do a basic passthrough first we can use it to skip cells that
  // the guard never visits
  let assert Stopped(completed) = execute(map)

  use count, coord, cell <- dict.fold(completed.cells, 0)
  case cell {
    Visited(_) -> {
      let candidate = Map(..map, cells: dict.insert(map.cells, coord, Obstacle))
      case execute(candidate) {
        Looped(_) -> count + 1
        _ -> count
      }
    }
    _ -> count
  }
}
