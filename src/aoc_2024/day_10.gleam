import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

pub type Coord {
  Coord(y: Int, x: Int)
}

pub type Grid =
  Dict(Coord, Int)

pub fn parse(input: String) -> Grid {
  use grid, line, y <- list.index_fold(string.split(input, "\n"), dict.new())
  use grid, char, x <- list.index_fold(string.to_graphemes(line), grid)

  let assert Ok(height) = int.parse(char)
  grid |> dict.insert(Coord(y, x), height)
}

fn score(grid: Grid, trailhead: Coord) -> Int {
  walk(grid, trailhead)
  |> list.unique
  |> list.length
}

fn walk(grid: Grid, trailhead: Coord) -> List(Coord) {
  walk_loop(grid, trailhead, [])
}

fn walk_loop(grid: Grid, prev: Coord, peaks: List(Coord)) -> List(Coord) {
  let assert Ok(height) = dict.get(grid, prev)
  let Coord(y, x) = prev

  let next_coords = [
    Coord(y + 1, x),
    Coord(y - 1, x),
    Coord(y, x + 1),
    Coord(y, x - 1),
  ]

  use peaks, next <- list.fold(next_coords, peaks)
  case dict.get(grid, next) {
    Ok(n) if n == height + 1 && n == 9 -> [next, ..peaks]
    Ok(n) if n == height + 1 -> walk_loop(grid, next, peaks)
    _ -> peaks
  }
}

pub fn pt_1(grid: Grid) {
  let trailheads =
    grid
    |> dict.filter(fn(_, height) { height == 0 })
    |> dict.keys

  use total_score, trailhead <- list.fold(trailheads, 0)
  total_score + score(grid, trailhead)
}

fn rating(grid: Grid, trailhead: Coord) -> Int {
  walk(grid, trailhead) |> list.length
}

pub fn pt_2(grid: Grid) {
  let trailheads =
    grid
    |> dict.filter(fn(_, height) { height == 0 })
    |> dict.keys

  use total_rating, trailhead <- list.fold(trailheads, 0)
  total_rating + rating(grid, trailhead)
}
