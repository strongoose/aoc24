import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
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
  |> set_antinode_at(anode_a)
  |> set_antinode_at(anode_b)
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

// Set a cell in the map as an Antinode, or do nothing if coord is out of bounds
fn set_antinode_at(map: Map, coord: Coord) -> Map {
  case dict.get(map, coord) {
    Ok(_) -> map |> dict.insert(coord, Antinode)
    Error(_) -> map
  }
}

pub fn pt_1(map: Map) -> Int {
  map
  |> populate_antinodes
  |> dict.values
  |> list.count(fn(cell) { cell == Antinode })
}

fn populate_resonant_antinodes(map: Map) -> Map {
  let towers = towers_by_freq(map)
  use map, _freq, locations <- dict.fold(towers, map)
  let tower_pairs = list.combination_pairs(locations)
  use map, #(first_tower, second_tower) <- list.fold(tower_pairs, map)

  let delta = second_tower |> coord_sub(first_tower)

  populate_resonant_antinodes_loop(
    // This obliterates tower locations on the map - but that's fine, we're iterating
    // over the precomputed `towers` index, not the actual map.
    map
      |> set_antinode_at(first_tower)
      |> set_antinode_at(second_tower),
    delta,
    second_tower,
    first_tower,
  )
}

// Positive antinodes are positioned at tower + delta, tower + 2*delta, ...
// Negative antinodes are positioned at tower - delta, tower - 2*delta, ...
fn populate_resonant_antinodes_loop(
  map: Map,
  delta: Coord,
  positive_antinode: Coord,
  negative_antinode: Coord,
) -> Map {
  let next_pos = positive_antinode |> coord_add(delta)
  let next_neg = negative_antinode |> coord_sub(delta)

  case dict.has_key(map, next_pos), dict.has_key(map, next_neg) {
    False, False -> map
    _, _ -> {
      populate_resonant_antinodes_loop(
        map
          |> set_antinode_at(next_pos)
          |> set_antinode_at(next_neg),
        delta,
        next_pos,
        next_neg,
      )
    }
  }
}

pub fn pt_2(map: Map) -> Int {
  map
  |> populate_resonant_antinodes
  |> dict.values
  |> list.count(fn(cell) { cell == Antinode })
}
