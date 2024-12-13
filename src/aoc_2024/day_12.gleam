import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string

import aoc_2024/lib.{type Coord, type Grid, Coord}

pub type Region {
  Region(kind: String, grid: Grid)
}

pub fn parse(input: String) -> List(Region) {
  input
  |> parse_grid
  |> split_regions
}

fn parse_grid(input: String) -> Grid {
  use grid, line, y <- list.index_fold(string.split(input, "\n"), dict.new())
  use grid, char, x <- list.index_fold(string.to_graphemes(line), grid)
  grid |> dict.insert(Coord(y, x), char)
}

fn split_regions(grid: Grid) -> List(Region) {
  use regions: List(Region), coord, _ <- dict.fold(grid, [])

  let seen = fn(coord) {
    use region <- list.any(regions)
    dict.has_key(region.grid, coord)
  }

  case seen(coord) {
    False -> [region_of(grid, coord), ..regions]
    True -> regions
  }
}

fn region_of(grid: Grid, coord: Coord) -> Region {
  let assert Ok(kind) = dict.get(grid, coord)
  region_of_loop(grid, coord, Region(kind, dict.new()))
}

fn region_of_loop(grid: Grid, coord: Coord, region: Region) -> Region {
  let Coord(y, x) = coord
  let adjacent = [
    // North
    Coord(y - 1, x),
    // East
    Coord(y, x + 1),
    // South
    Coord(y + 1, x),
    // West
    Coord(y, x - 1),
  ]

  case dict.has_key(region.grid, coord), dict.get(grid, coord) {
    False, Ok(plant) if plant == region.kind -> {
      use region, coord <- list.fold(adjacent, region |> extend(coord))
      region_of_loop(grid, coord, region)
    }
    _, _ -> region
  }
}

pub fn extend(region: Region, coord: Coord) -> Region {
  let grid =
    region.grid
    |> dict.insert(coord, region.kind)

  Region(..region, grid: grid)
}

fn area(region: Region) -> Int {
  dict.size(region.grid)
}

fn perimiter(region: Region) -> Int {
  use perimeter, coord, _ <- dict.fold(region.grid, 0)

  let Coord(y, x) = coord
  let adjacent = [
    // North
    Coord(y - 1, x),
    // East
    Coord(y, x + 1),
    // South
    Coord(y + 1, x),
    // West
    Coord(y, x - 1),
  ]

  use perimeter, adj <- list.fold(adjacent, perimeter)
  case region.grid |> dict.get(adj) {
    Error(_) -> perimeter + 1
    _ -> perimeter
  }
}

pub fn pt_1(regions: List(Region)) {
  use price, region <- list.fold(regions, 0)
  price + perimiter(region) * area(region)
}

pub fn corner_count(region: Region) -> Int {
  use count, coord <- list.fold(dict.keys(region.grid), 0)
  count + corner_count_for_coord(region, coord)
}

fn corner_count_for_coord(region: Region, coord: Coord) -> Int {
  // A coordinate in a region may have up to 4 corners
  // 
  // Corners may be _convex_ or _concave_ i.e.
  // 
  // ```
  //     O concave
  //     O/
  //     OOO
  //    /   
  //   convex
  // ```
  // 
  // convex corners occur when 2 contiguous orthogonal coordinates to it
  // are outside the region
  //
  // concave corners occur when 2 contiguous orthogonal coordinates to it
  // are *inside* the region, AND the diagonal coordinate between them is
  // outside

  let Coord(y, x) = coord
  let north = dict.get(region.grid, Coord(y - 1, x))
  let south = dict.get(region.grid, Coord(y + 1, x))
  let east = dict.get(region.grid, Coord(y, x + 1))
  let west = dict.get(region.grid, Coord(y, x - 1))

  let north_east = dict.get(region.grid, Coord(y - 1, x + 1))
  let south_east = dict.get(region.grid, Coord(y + 1, x + 1))
  let north_west = dict.get(region.grid, Coord(y - 1, x - 1))
  let south_west = dict.get(region.grid, Coord(y + 1, x - 1))

  let surroundings = [
    // North to East
    #(north, north_east, east),
    // East to South
    #(east, south_east, south),
    // South to West
    #(south, south_west, west),
    // West to North
    #(west, north_west, north),
  ]

  use count, sides <- list.fold(surroundings, 0)

  case sides {
    // convex
    #(Error(Nil), _, Error(Nil)) -> count + 1
    // concave
    #(Ok(_), Error(Nil), Ok(_)) -> count + 1
    // neither
    _ -> count
  }
}

pub fn pt_2(regions: List(Region)) {
  use price, region <- list.fold(regions, 0)
  // The number of sides of a polygon is equal to its number of corners
  price + corner_count(region) * area(region)
}
