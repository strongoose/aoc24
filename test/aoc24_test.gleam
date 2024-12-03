import gleeunit
import gleeunit/should

import aoc_2024/day_3.{Do, Dont, Mul}
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

pub fn parse_test() {
  "mul(382,128)select(){*who(710,947)mul(117,325)?$#fr"
  |> day_3.parse()
  |> should.equal([Mul(382, 128), Mul(117, 325)])
}

pub fn parse_donts_test() {
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
