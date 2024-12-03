import gleam/int
import gleam/io
import gleam/list
import gleam/string.{join}

pub type Op {
  Mul(Int, Int)
}

pub fn parse(input: String) -> List(Op) {
  do_parse(input, [])
}

fn do_parse(input: String, ops: List(Op)) -> List(Op) {
  case input, parse_mul(input) {
    "", _ -> ops
    _, #(Ok(op), remaining_input) -> do_parse(remaining_input, [op, ..ops])
    _, #(_, remaining_input) -> do_parse(remaining_input, ops)
  }
}

fn parse_mul(input: String) -> #(Result(Op, Nil), String) {
  let graphemes = input |> string.to_graphemes

  case graphemes {
    ["m", "u", "l", "(", ..rest] -> parse_operands(rest |> join(""))
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
    }
  })
  |> int.sum
}

pub fn pt_2(input: List(Op)) -> Int {
  todo as "part 2 not implemented"
}
