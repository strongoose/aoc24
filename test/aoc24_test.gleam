import gleam/dict
import gleam/string

import gleeunit
import gleeunit/should

import aoc_2024/day_3.{Do, Dont, Mul}
import aoc_2024/day_4.{Grid}
import aoc_2024/day_5
import aoc_2024/day_6
import aoc_2024/lib

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn chunk_by_2_ok_with_even_length_test() {
  [1, 2, 3, 4]
  |> lib.chunk_by_2
  |> should.be_ok
  |> should.equal([#(1, 2), #(3, 4)])
}

pub fn chunk_by_2_ok_with_empty_test() {
  []
  |> lib.chunk_by_2
  |> should.be_ok
}

pub fn chunk_by_2_err_with_odd_length_test() {
  [1, 2, 3, 4, 5]
  |> lib.chunk_by_2
  |> should.be_error
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
  |> should.equal(Grid(
    coords: dict.from_list([
      #(#(0, 0), "a"),
      #(#(0, 1), "b"),
      #(#(0, 2), "c"),
      #(#(1, 0), "d"),
      #(#(1, 1), "e"),
      #(#(1, 2), "f"),
    ]),
    width: 3,
    height: 2,
  ))
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
