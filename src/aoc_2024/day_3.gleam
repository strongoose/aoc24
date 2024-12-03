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

fn loop_parse(input: String, ops: List(Op)) -> List(Op) {
  case input, parse_op(input) {
    "", _ -> ops
    _, #(Ok(op), remaining_input) -> loop_parse(remaining_input, [op, ..ops])
    _, #(_, remaining_input) -> loop_parse(remaining_input, ops)
  }
}

fn parse_op(input: String) -> #(Result(Op, Nil), String) {
  case input {
    "mul(" <> rest -> parse_operands(rest)
    "do()" <> rest -> #(Ok(Do), rest)
    "don't()" <> rest -> #(Ok(Dont), rest)
    _ -> #(Error(Nil), input |> string.drop_start(1))
  }
}

fn parse_operands(input: String) -> #(Result(Op, Nil), String) {
  use left, input <- parse_number(input)
  use input <- consume(input, ",")
  use right, input <- parse_number(input)
  use input <- consume(input, ")")
  #(Ok(Mul(left, right)), input)
}

fn parse_number(
  input: String,
  then: fn(Int, String) -> #(Result(Op, Nil), String),
) -> #(Result(Op, Nil), String) {
  let #(number, rest) =
    input
    |> string.to_graphemes
    |> list.split_while(fn(c) {
      ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] |> list.contains(c)
    })

  case list.length(number) {
    1 | 2 | 3 -> {
      let assert Ok(number) =
        number
        |> join("")
        |> int.parse
      then(number, rest |> join(""))
    }

    _ -> #(Error(Nil), rest |> join(""))
  }
}

fn consume(
  input: String,
  char: String,
  then: fn(String) -> #(Result(Op, Nil), String),
) -> #(Result(Op, Nil), String) {
  case string.pop_grapheme(input) {
    Ok(#(grapheme, rest)) if grapheme == char -> then(rest)
    _ -> #(Error(Nil), input)
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
