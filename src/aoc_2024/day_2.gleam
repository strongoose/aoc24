import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Report =
  List(Int)

pub fn parse(input: String) -> List(Report) {
  let lines =
    input
    |> string.trim()
    |> string.split(on: "\n")

  let reports =
    list.map(lines, fn(line) {
      let assert Ok(report) =
        line
        |> string.split(on: " ")
        |> list.map(int.parse)
        |> result.all

      report
    })

  reports
}

fn is_safe(report: Report) -> Bool {
  case report {
    [first, second, ..] if first > second -> is_safely_descending(report)
    [first, second, ..] if first < second -> is_safely_ascending(report)
    _ -> False
  }
}

fn is_safely_descending(report: Report) -> Bool {
  report
  |> list.window_by_2
  |> list.all(fn(window) {
    case window {
      #(a, b) if a > b -> a - b <= 3
      _ -> False
    }
  })
}

fn is_safely_ascending(report: Report) -> Bool {
  report
  |> list.window_by_2
  |> list.all(fn(window) {
    case window {
      #(a, b) if a < b -> b - a <= 3
      _ -> False
    }
  })
}

pub fn pt_1(input: List(Report)) {
  list.count(input, where: is_safe)
}

fn is_safe_with_problem_dampening(report: Report) -> Bool {
  report
  |> list.index_map(fn(_, i) {
    // The back half of the split will always have at least 1 element, because i is at most length - 1
    let assert #(front, [_, ..tail]) = list.split(report, i)
    list.append(front, tail)
  })
  |> list.any(is_safe)
}

pub fn pt_2(input: List(Report)) {
  list.count(input, where: is_safe_with_problem_dampening)
}
