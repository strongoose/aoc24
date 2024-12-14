import gleam/dict.{type Dict}
import gleam/int
import gleam/list.{fold, range, reverse}
import gleam/string

pub type Coord {
  Coord(y: Int, x: Int)
}

pub type Grid =
  Dict(Coord, String)

pub fn add_coord(coord: Coord, other: Coord) -> Coord {
  let Coord(ay, ax) = coord
  let Coord(by, bx) = other

  Coord(ay + by, ax + bx)
}

pub fn scale_coord(coord: Coord, factor: Int) -> Coord {
  let Coord(y, x) = coord
  Coord(y * factor, x * factor)
}

pub fn grid_from_string(str: String) -> Grid {
  use grid, line, y <- list.index_fold(string.split(str, "\n"), dict.new())
  use grid, char, x <- list.index_fold(string.to_graphemes(line), grid)

  grid |> dict.insert(Coord(y, x), char)
}

pub fn grid_to_string(grid: Grid) -> String {
  let #(max_y, max_x) =
    grid
    |> dict.keys
    |> fold(#(0, 0), fn(max, coord) {
      let #(max_y, max_x) = max
      let Coord(y, x) = coord
      #(int.max(max_y, y), int.max(max_x, x))
    })

  let lines = {
    use lines, y <- fold(range(0, max_y), [])
    let line = {
      use line, x <- fold(range(0, max_x), "")
      case dict.get(grid, Coord(y, x)) {
        Ok(char) -> line <> char
        Error(Nil) -> line <> " "
      }
    }
    [line, ..lines]
  }

  lines |> reverse |> string.join("\n")
}
