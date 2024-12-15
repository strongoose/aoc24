import gleam/int
import gleam/list
import gleam/string

pub type Equation {
  Equation(coeff_a: Int, coeff_b: Int, sum: Int)
}

pub type Machine =
  #(Equation, Equation)

pub fn parse(input: String) -> List(#(Equation, Equation)) {
  use machines, raw_machine <- list.fold(string.split(input, "\n\n"), [])
  let assert [button_a, button_b, prize] = string.split(raw_machine, "\n")

  let assert [_, Ok(a_x), _, Ok(a_y)] =
    button_a
    |> string.split("+")
    |> list.map(string.split(_, ","))
    |> list.flatten
    |> list.map(int.parse)

  let assert [_, Ok(b_x), _, Ok(b_y)] =
    button_b
    |> string.split("+")
    |> list.map(string.split(_, ","))
    |> list.flatten
    |> list.map(int.parse)

  let assert [_, Ok(x), _, Ok(y)] =
    prize
    |> string.split("=")
    |> list.map(string.split(_, ","))
    |> list.flatten
    |> list.map(int.parse)

  [#(Equation(a_x, b_x, x), Equation(a_y, b_y, y)), ..machines]
}

/// 
/// To solve a pair of equations:
/// 
///   dA + eB = f
///   gA + hB = i
///
/// Multiply equation 1 by `g`,
/// multiply equation 2 by `d`,
/// then subtract
///
///   dgA + egB = fg
///   dgA + dhB = di
///   =>  (eg - dh)B = fg - di
///
///           (fg - di)
///   =>  B = ---------
///           (eg - dh)
///
/// Similarly,
///
///   dhA + ehB = fh
///   egA + ehB = ei
///   => (dh - eg)A = fh - ei
///
///           (fh - ei)
///   =>  A = ---------
///           (dh - eg)
///
/// If the equations have whole number solutions, then we can win a prize.
pub fn solve(
  x_equation: Equation,
  y_equation: Equation,
) -> Result(#(Int, Int), Nil) {
  let Equation(coeff_a: d, coeff_b: e, sum: f) = x_equation
  let Equation(coeff_a: g, coeff_b: h, sum: i) = y_equation

  let a_numerator = f * h - e * i
  let a_denominator = d * h - e * g

  let b_numerator = f * g - d * i
  let b_denominator = e * g - d * h

  let a_solveable = int.modulo(a_numerator, a_denominator)
  let b_solveable = int.modulo(b_numerator, b_denominator)

  case a_solveable, b_solveable {
    Ok(0), Ok(0) ->
      Ok(#(a_numerator / a_denominator, b_numerator / b_denominator))
    _, _ -> Error(Nil)
  }
}

pub fn pt_1(machines: List(Machine)) {
  use cost, machine <- list.fold(machines, 0)
  let #(eq_x, eq_y) = machine
  case solve(eq_x, eq_y) {
    Ok(#(a, b)) -> cost + 3 * a + b
    _ -> cost
  }
}

pub fn pt_2(machines: List(Machine)) {
  let machines =
    machines
    |> list.map(fn(machine) {
      let #(eq_x, eq_y) = machine
      #(
        Equation(..eq_x, sum: eq_x.sum + 10_000_000_000_000),
        Equation(..eq_y, sum: eq_y.sum + 10_000_000_000_000),
      )
    })
  pt_1(machines)
}
