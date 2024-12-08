import gleam/bool
import gleam/int
import gleam/list
import gleam/result
import gleam/string

type Report =
  List(Int)

pub fn parse(input: String) -> List(Report) {
  use line <- list.map(string.split(input, "\n"))
  let assert Ok(report) =
    line
    |> string.split(" ")
    |> list.map(int.parse)
    |> result.all
  report
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

pub fn pt_1(reports: List(Report)) {
  reports |> list.count(is_safe)
}

fn dampen(report: Report) -> Result(Report, Nil) {
  use <- bool.guard(when: is_safe(report), return: Ok(report))
  let len = list.length(report)

  report
  // This produces all variations on the list with one element missing
  |> list.combinations(len - 1)
  |> list.find(is_safe)
}

pub fn pt_2(reports: List(Report)) {
  reports
  |> list.map(dampen)
  |> result.values
  |> list.count(fn(_) { True })
}
