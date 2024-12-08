import gleam/int
import gleam/list.{Continue, Stop}
import gleam/result
import gleam/string

pub type UnsolvedEquation {
  UnsolvedEquation(lhs: Int, rhs: List(Int))
}

pub fn parse(input: String) -> List(UnsolvedEquation) {
  let lines =
    input
    |> string.trim()
    |> string.split("\n")

  use equations, line <- list.fold(lines, [])
  let assert [raw_lhs, raw_rhs] = string.split(line, ": ")
  let assert Ok(lhs) = int.parse(raw_lhs)
  let assert Ok(rhs) =
    raw_rhs
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.all

  [UnsolvedEquation(lhs, rhs), ..equations]
}

pub type Operation {
  Add(Int)
  Mul(Int)
  Cat(Int)
}

pub type Equation {
  Equation(lhs: Int, rhs: List(Operation))
}

fn candidate_equations(unsolved: UnsolvedEquation) -> List(Equation) {
  let assert [first_term, ..rest] = unsolved.rhs
  let initial_equation = Equation(lhs: unsolved.lhs, rhs: [Add(first_term)])
  candidate_equations_loop([initial_equation], rest)
  // The equations rhs's are accumulated in reverse order (for performance reasons)
  |> list.map(fn(eq) { Equation(..eq, rhs: eq.rhs |> list.reverse) })
}

fn candidate_equations_loop(equations: List(Equation), terms: List(Int)) {
  case terms {
    [] -> equations
    [term, ..rest] -> {
      equations
      |> list.map(fn(eq) {
        [
          Equation(..eq, rhs: [Add(term), ..eq.rhs]),
          Equation(..eq, rhs: [Mul(term), ..eq.rhs]),
        ]
      })
      |> list.flatten
      |> candidate_equations_loop(rest)
    }
  }
}

fn check(eq: Equation) -> Bool {
  let total =
    eq.rhs
    |> list.fold(0, fn(acc, item) {
      case item {
        Add(n) -> acc + n
        Mul(n) -> acc * n
        Cat(n) -> concat(acc, n)
      }
    })
  total == eq.lhs
}

fn solve(eq: UnsolvedEquation) -> Result(Equation, Nil) {
  let candidates = candidate_equations(eq)
  use _, candidate <- list.fold_until(candidates, Error(Nil))
  case check(candidate) {
    True -> Stop(Ok(candidate))
    False -> Continue(Error(Nil))
  }
}

pub fn pt_1(input: List(UnsolvedEquation)) -> Int {
  use total, equation <- list.fold(input, 0)

  case result.map(solve(equation), check) {
    Ok(_) -> total + equation.lhs
    _ -> total
  }
}

pub fn concat(first: Int, second: Int) -> Int {
  let catted = int.to_string(first) <> int.to_string(second)
  let assert Ok(answer) = int.parse(catted)
  answer
}

fn solve_pt2(eq: UnsolvedEquation) -> Result(Equation, Nil) {
  let candidates = candidate_equations_pt2(eq)
  use _, candidate <- list.fold_until(candidates, Error(Nil))
  case check(candidate) {
    True -> Stop(Ok(candidate))
    False -> Continue(Error(Nil))
  }
}

fn candidate_equations_pt2(unsolved: UnsolvedEquation) -> List(Equation) {
  let assert [first_term, ..rest] = unsolved.rhs
  let initial_equation = Equation(lhs: unsolved.lhs, rhs: [Add(first_term)])
  candidate_equations_loop_pt2([initial_equation], rest)
  // The equations rhs's are accumulated in reverse order (for performance reasons)
  |> list.map(fn(eq) { Equation(..eq, rhs: eq.rhs |> list.reverse) })
}

fn candidate_equations_loop_pt2(equations: List(Equation), terms: List(Int)) {
  case terms {
    [] -> equations
    [term, ..rest] -> {
      equations
      |> list.map(fn(eq) {
        [
          Equation(..eq, rhs: [Add(term), ..eq.rhs]),
          Equation(..eq, rhs: [Mul(term), ..eq.rhs]),
          Equation(..eq, rhs: [Cat(term), ..eq.rhs]),
        ]
      })
      |> list.flatten
      |> candidate_equations_loop_pt2(rest)
    }
  }
}

pub fn pt_2(input: List(UnsolvedEquation)) -> Int {
  use total, equation <- list.fold(input, 0)

  case result.map(solve_pt2(equation), check) {
    Ok(_) -> total + equation.lhs
    _ -> total
  }
}
