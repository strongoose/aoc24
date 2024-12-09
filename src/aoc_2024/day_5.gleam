import gleam/bool
import gleam/int
import gleam/list
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

fn conforms_to(update: Update, rule: Rule) -> Bool {
  let #(small, big) = rule
  // The rule is only applicable if the list contains both `small` and `big`
  let applicable = list.contains(update, small) && list.contains(update, big)
  // If the rule isn't applicable, we conform by default
  use <- bool.guard(when: !applicable, return: True)
  let assert Ok(first_match) =
    update |> list.find(fn(page) { page == small || page == big })
  first_match == small
}

fn middle_page(a_list: List(a)) -> Result(a, Nil) {
  let half = list.length(a_list) / 2
  a_list
  |> list.drop(half)
  |> list.first
}

// This function can be used to short-circuit violation checking when only a True/False
// result is required. However, it's not significantly faster than just running 
//   violations(upd, rules) == []
// for the problem input.
//
// fn has_violations(update: Update, rules: List(Rule)) -> Bool {
//   use _, rule <- list.fold_until(rules, True)
//   case conforms_to(update, rule) {
//     True -> Continue(True)
//     False -> Stop(False)
//   }
// }

fn violations(update: Update, rules: List(Rule)) -> List(Rule) {
  use violations, rule <- list.fold(rules, [])
  case conforms_to(update, rule) {
    False -> [rule, ..violations]
    True -> violations
  }
}

pub fn pt_1(input: #(List(Rule), List(Update))) -> Int {
  let #(rules, updates) = input
  use total, update <- list.fold(updates, 0)
  // use <- bool.guard(when: !is_conformant(update, rules), return: total)
  use <- bool.guard(when: violations(update, rules) != [], return: total)
  let assert Ok(page) = middle_page(update)
  total + page
}

fn swap(update: Update, rule: Rule) -> Update {
  let #(small, big) = rule
  let #(front, rest) =
    update
    |> list.split_while(fn(page) { page != small && page != big })

  let assert [a, ..rest] = rest

  let #(middle, rest) =
    rest
    |> list.split_while(fn(page) { page != small && page != big })

  let assert [b, ..back] = rest

  list.flatten([front, [b], middle, [a], back])
}

pub fn badsort(update: Update, rules: List(Rule)) -> Update {
  let relevant_rules =
    rules
    |> list.filter(fn(rule) {
      let #(small, big) = rule
      list.contains(update, small) && list.contains(update, big)
    })

  badsort_loop(update, relevant_rules)
}

fn badsort_loop(update: Update, rules: List(Rule)) -> Update {
  case violations(update, rules) {
    [] -> update
    [violation, ..] -> update |> swap(violation) |> badsort_loop(rules)
  }
}

pub fn pt_2(input: #(List(Rule), List(Update))) -> Int {
  let #(rules, updates) = input
  use total, update <- list.fold(updates, 0)
  use <- bool.guard(when: violations(update, rules) == [], return: total)
  let assert Ok(page) =
    update
    |> badsort(rules)
    |> middle_page
  total + page
}
