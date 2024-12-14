import gleam/dict.{type Dict}

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
