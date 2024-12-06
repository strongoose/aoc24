import gleam/int
import gleam/io
import gleam/list.{Continue, Stop}
import gleam/pair
import gleam/result
import gleam/string

type Page =
  Int

type Rule =
  #(Page, Page)

type Update =
  List(Page)

pub fn parse(input: String) -> #(List(Rule), List(Update)) {
  let assert [raw_rules, raw_updates] =
    input
    |> string.trim()
    |> string.split("\n\n")

  #(parse_rules(raw_rules), parse_updates(raw_updates))
}

fn parse_rules(raw: String) -> List(Rule) {
  use rules, line <- list.fold(string.split(raw, "\n"), [])

  let assert [Ok(a), Ok(b)] = string.split(line, "|") |> list.map(int.parse)

  [#(a, b), ..rules]
}

fn parse_updates(raw: String) -> List(Update) {
  use updates, line <- list.fold(string.split(raw, "\n"), [])
  let assert Ok(update) =
    line
    |> string.split(",")
    |> list.map(int.parse)
    |> result.all
  [update, ..updates]
}

pub fn index_find(a_list: List(a), el: a) -> Result(Int, Nil) {
  a_list
  |> list.index_map(pair.new)
  |> list.find(fn(a_pair) { pair.first(a_pair) == el })
  |> result.map(pair.second)
}

fn conforms_to(update: Update, rule: Rule) -> Bool {
  let #(small, big) = rule

  // I would expect each update not to contain repeated pages, so we
  // can just find the first index of each page.
  case index_find(update, small), index_find(update, big) {
    Ok(i), Ok(j) if i > j -> False
    _, _ -> True
  }
}

fn conformant(update: Update, rules: List(Rule)) -> Bool {
  use _, rule <- list.fold_until(rules, True)
  case conforms_to(update, rule) {
    True -> Continue(True)
    False -> Stop(False)
  }
}

pub fn pt_1(input: #(List(Rule), List(Update))) -> Int {
  let #(rules, updates) = input

  updates
  |> list.filter(conformant(_, rules))
  |> list.map(fn(update) {
    let half = list.length(update) / 2
    let assert Ok(middle) =
      update
      |> list.drop(half)
      |> list.first
    middle
  })
  |> int.sum
}

pub fn pt_2(input: #(List(Rule), List(Update))) -> Int {
  todo
}
