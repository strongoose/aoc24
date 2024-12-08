import gleam/dict
import gleam/string

import gleeunit
import gleeunit/should

import aoc_2024/day_3.{Do, Dont, Mul}
import aoc_2024/day_4.{Coord}
import aoc_2024/day_5
import aoc_2024/day_6
import aoc_2024/day_7

pub fn main() {
  gleeunit.main()
}

pub fn filter_donts_test() {
  [Mul(1, 1), Dont, Do, Dont, Mul(1, 2), Dont, Do, Mul(1, 3)]
  |> day_3.filter_donts
  |> should.equal([Mul(1, 1), Mul(1, 3)])
}

pub fn day_3_parse_test() {
  "mul(382,128)select(){*who(710,947)mul(117,325)?$#fr"
  |> day_3.parse()
  |> should.equal([Mul(382, 128), Mul(117, 325)])
}

pub fn day_3_parse_donts_test() {
  "mul(382,128)don't(){*mul(710,947)mul(117,325)?do()mul(1,3)$#fr"
  |> day_3.parse()
  |> should.equal([
    Mul(382, 128),
    Dont,
    Mul(710, 947),
    Mul(117, 325),
    Do,
    Mul(1, 3),
  ])
}

pub fn day_4_parse_test() {
  "abc\ndef"
  |> day_4.parse
  |> should.equal(
    dict.from_list([
      #(Coord(0, 0), "a"),
      #(Coord(0, 1), "b"),
      #(Coord(0, 2), "c"),
      #(Coord(1, 0), "d"),
      #(Coord(1, 1), "e"),
      #(Coord(1, 2), "f"),
    ]),
  )
}

pub fn day5_badsort_test() {
  let rules = [#(1, 2), #(1, 4), #(2, 3), #(3, 4)]
  let update = [2, 4, 1]

  update
  |> day_5.badsort(rules)
  |> should.equal([1, 2, 4])
}

pub fn day6_loop_detection_test() {
  // .#.....
  // ......#
  // #......
  // .^...#.
  [".#.....", "......#", "#......", ".^...#."]
  |> string.join("\n")
  |> day_6.parse()
  |> day_6.execute()
  |> fn(map) {
    case map {
      day_6.Looped(_) -> Nil
      _ -> should.fail()
    }
  }
}

pub fn day_7_concat_test() {
  day_7.concat(12, 109)
  |> should.equal(12_109)
}

pub fn day_7_concat_big_test() {
  day_7.concat(12_191, 1_029_919)
  |> should.equal(121_911_029_919)
}
