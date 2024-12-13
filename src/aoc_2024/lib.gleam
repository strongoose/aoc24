import gleam/dict.{type Dict}

pub type Coord {
  Coord(y: Int, x: Int)
}

pub type Grid =
  Dict(Coord, String)
