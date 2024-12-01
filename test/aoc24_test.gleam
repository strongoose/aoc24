import gleeunit
import gleeunit/should

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
