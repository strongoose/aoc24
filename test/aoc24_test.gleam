import gleam/dict
import gleam/string

import gleeunit
import gleeunit/should

import aoc_2024/day_11
import aoc_2024/day_3.{Do, Dont, Mul}
import aoc_2024/day_4.{Coord}
import aoc_2024/day_5
import aoc_2024/day_6
import aoc_2024/day_7
import aoc_2024/day_9

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

// -- Day 9 --

pub fn day_9_helpers_test() {
  "00..111.233..4"
  |> day_9.str_to_disk
  |> day_9.disk_to_str
  |> should.equal("00..111.233..4")
}

pub fn day_9_compact_files_test() {
  "00...111...2...333.44.5555.6666.777.888899"
  |> day_9.str_to_disk
  |> day_9.compact_files
  |> day_9.disk_to_str
  |> should.equal("00992111777.44.333....5555.6666.....8888..")
}

// -- Day 11 --

pub fn day_11_blink_1_test() {
  "125 17"
  |> day_11.parse
  |> day_11.blink
  |> should.equal("253000 1 7" |> day_11.parse)
}

pub fn day_11_blink_2_test() {
  "125 17"
  |> day_11.parse
  |> day_11.blink
  |> day_11.blink
  |> dict.filter(fn(_, n) { n != 0 })
  |> should.equal("253 0 2024 14168" |> day_11.parse)
}

pub fn day_11_blink_3_test() {
  "125 17"
  |> day_11.parse
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> dict.filter(fn(_, n) { n != 0 })
  |> should.equal("512072 1 20 24 28676032" |> day_11.parse)
}

pub fn day_11_blink_4_test() {
  "125 17"
  |> day_11.parse
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> dict.filter(fn(_, n) { n != 0 })
  |> should.equal("512 72 2024 2 0 2 4 2867 6032" |> day_11.parse)
}

pub fn day_11_blink_5_test() {
  "125 17"
  |> day_11.parse
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> dict.filter(fn(_, n) { n != 0 })
  |> should.equal(
    "1036288 7 2 20 24 4048 1 4048 8096 28 67 60 32" |> day_11.parse,
  )
}

pub fn day_11_blink_6_test() {
  "125 17"
  |> day_11.parse
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> day_11.blink
  |> dict.filter(fn(_, n) { n != 0 })
  |> should.equal(
    "2097446912 14168 4048 2 0 2 4 40 48 2024 40 48 80 96 2 8 6 7 6 0 3 2"
    |> day_11.parse,
  )
}
