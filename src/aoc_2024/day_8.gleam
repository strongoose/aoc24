import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/set
import gleam/string

pub type Map =
  Dict(Coord, Cell)

pub type Coord {
  Coord(y: Int, x: Int)
}

pub type Vector {
  Vector(y: Int, x: Int)
}

pub type Cell {
  Tower(freq: String)
  Antinode
  Nothing
}

pub fn parse(input: String) -> Map {
  use map, line, y <- list.index_fold(string.split(input, "\n"), dict.new())
  use map, char, x <- list.index_fold(string.to_graphemes(line), map)
  case char {
    "." -> map |> dict.insert(Coord(y, x), Nothing)
    c -> map |> dict.insert(Coord(y, x), Tower(c))
  }
}

fn towers_by_freq(map: Map) -> Dict(String, List(Coord)) {
  use lookup, coord, cell <- dict.fold(map, dict.new())
  case cell {
    Tower(freq) -> {
      lookup
      |> dict.upsert(freq, fn(value) {
        case value {
          Some(towers) -> [coord, ..towers]
          None -> [coord]
        }
      })
    }
    _ -> lookup
  }
}

fn populate_antinodes(map: Map) -> Map {
  let towers = towers_by_freq(map)
  use map, _freq, locations <- dict.fold(towers, map)
  let tower_pairs = list.combination_pairs(locations)
  use map, #(first_tower, second_tower) <- list.fold(tower_pairs, map)

  let delta = second_tower |> coord_sub(first_tower)

  let anode_a = second_tower |> coord_add(delta)
  let anode_b = first_tower |> coord_sub(delta)

  map
  |> update(anode_a, Antinode)
  |> update(anode_b, Antinode)
}

fn coord_add(a: Coord, b: Coord) -> Coord {
  let Coord(ay, ax) = a
  let Coord(by, bx) = b
  Coord(ay + by, ax + bx)
}

fn coord_sub(a: Coord, b: Coord) -> Coord {
  let Coord(ay, ax) = a
  let Coord(by, bx) = b
  Coord(ay - by, ax - bx)
}

// Update a cell in the map, or do nothing if coord is out of bounds
fn update(map: Map, coord: Coord, cell: Cell) -> Map {
  case dict.get(map, coord) {
    Ok(_) -> map |> dict.insert(coord, cell)
    Error(_) -> map
  }
}

pub fn pt_1(map: Map) -> Int {
  map
  |> populate_antinodes
  |> dict.values
  |> list.count(fn(cell) { cell == Antinode })
}

pub fn pt_2(map: Map) -> Int {
  todo as "part 2 not implemented"
}
