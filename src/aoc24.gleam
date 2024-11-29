import argv
import gleam/io

import problems/p1
import problems/p10
import problems/p11
import problems/p12
import problems/p13
import problems/p14
import problems/p15
import problems/p16
import problems/p17
import problems/p18
import problems/p19
import problems/p2
import problems/p20
import problems/p21
import problems/p22
import problems/p23
import problems/p24
import problems/p25
import problems/p3
import problems/p4
import problems/p5
import problems/p6
import problems/p7
import problems/p8
import problems/p9

fn help() -> String {
  "usage: gleam run N

  run the advent of code problem for day N

  e.g.
    gleam run 1
    gleam run 24
  "
}

pub fn main() {
  io.println(case argv.load().arguments {
    ["1"] -> p1.run()
    ["2"] -> p2.run()
    ["3"] -> p3.run()
    ["4"] -> p4.run()
    ["5"] -> p5.run()
    ["6"] -> p6.run()
    ["7"] -> p7.run()
    ["8"] -> p8.run()
    ["9"] -> p9.run()
    ["10"] -> p10.run()
    ["11"] -> p11.run()
    ["12"] -> p12.run()
    ["13"] -> p13.run()
    ["14"] -> p14.run()
    ["15"] -> p15.run()
    ["16"] -> p16.run()
    ["17"] -> p17.run()
    ["18"] -> p18.run()
    ["19"] -> p19.run()
    ["20"] -> p20.run()
    ["21"] -> p21.run()
    ["22"] -> p22.run()
    ["23"] -> p23.run()
    ["24"] -> p24.run()
    ["25"] -> p25.run()
    _ -> help()
  })
}
