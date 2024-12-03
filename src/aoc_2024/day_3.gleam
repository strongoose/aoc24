import gleam/int
import gleam/list
import gleam/string.{join}

pub type Op {
  Mul(Int, Int)
  Do
  Dont
}

pub fn parse(input: String) -> List(Op) {
  loop_parse(input, []) |> list.reverse
}

// Main parse loop
// parse_mul will return here when complete, or when parsing fails
fn loop_parse(input: String, ops: List(Op)) -> List(Op) {
  case input {
    "" -> ops
    "do()" <> rest -> loop_parse(rest, [Do, ..ops])
    "don't()" <> rest -> loop_parse(rest, [Dont, ..ops])
    "mul(" <> rest -> parse_mul(rest, ops)
    _ -> loop_parse(string.drop_start(input, 1), ops)
  }
}

fn parse_mul(input: String, ops: List(Op)) -> List(Op) {
  use left, input <- parse_number(input, ops)
  use input <- consume(input, ",", ops)
  use right, input <- parse_number(input, ops)
  use input <- consume(input, ")", ops)

  loop_parse(input, [Mul(left, right), ..ops])
}

fn parse_number(input: String, ops: List(Op), then) -> List(Op) {
  let #(number, rest) =
    input
    |> string.to_graphemes
    |> list.split_while(fn(c) {
      ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] |> list.contains(c)
    })

  let number = number |> join("")
  let rest = rest |> join("")

  case string.length(number) {
    1 | 2 | 3 -> {
      let assert Ok(number) = int.parse(number)
      then(number, rest)
    }

    _ -> loop_parse(rest, ops)
  }
}

fn consume(input: String, char: String, ops: List(Op), then) -> List(Op) {
  case string.pop_grapheme(input) {
    Ok(#(grapheme, rest)) if grapheme == char -> then(rest)
    _ -> loop_parse(input, ops)
  }
}

pub fn pt_1(input: List(Op)) -> Int {
  input
  |> list.map(fn(op) {
    case op {
      Mul(a, b) -> a * b
      _ -> 0
    }
  })
  |> int.sum
}

pub fn filter_donts(input: List(Op)) -> List(Op) {
  loop_accumulate_muls([], input)
}

fn loop_accumulate_muls(acc: List(Op), input: List(Op)) -> List(Op) {
  case list.split_while(input, fn(op) { op != Dont }) {
    #(ops, []) -> list.append(acc, ops)
    #(ops, [_dont, ..rest]) -> list.append(acc, ops) |> loop_discard_muls(rest)
  }
}

fn loop_discard_muls(acc: List(Op), input: List(Op)) -> List(Op) {
  case list.split_while(input, fn(op) { op != Do }) {
    #(_, []) -> acc
    #(_, [_do, ..rest]) -> acc |> loop_accumulate_muls(rest)
  }
}

pub fn pt_2(input: List(Op)) -> Int {
  input
  |> filter_donts
  |> list.map(fn(op) {
    case op {
      Mul(a, b) -> a * b
      _ -> 0
    }
  })
  |> int.sum
}
