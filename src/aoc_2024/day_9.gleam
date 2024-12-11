import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

pub type Disk {
  Disk(blocks: Dict(Int, Block), head: Int, size: Int)
}

pub type Block {
  File(id: Int)
  Empty
}

pub fn parse(input: String) -> Disk {
  let blocks =
    input
    |> parse_blocks
    |> list.reverse
    |> list.index_map(fn(block, i) { #(i, block) })

  Disk(dict.from_list(blocks), head: 0, size: list.length(blocks))
}

// Note that the list of blocks is in reverse order
pub fn parse_blocks(input: String) -> List(Block) {
  use blocks, size, index <- list.index_fold(string.to_graphemes(input), [])
  let assert Ok(size) = int.parse(size)

  case index % 2 == 0 {
    True -> list.repeat(File(id: index / 2), size) |> list.append(blocks)
    False -> list.repeat(Empty, size) |> list.append(blocks)
  }
}

fn advance(disk: Disk) -> Disk {
  Disk(..disk, head: disk.head + 1)
}

fn read(disk: Disk) -> Block {
  disk.blocks
  |> dict.get(disk.head)
  |> result.unwrap(or: Empty)
}

fn jump(disk: Disk, n: Int) -> Disk {
  Disk(..disk, head: int.clamp(n, 0, disk.size - 1))
}

// fn write(disk: Disk, block: Block) -> Disk {
//   Disk(..disk, blocks: disk.blocks |> dict.insert(disk.head, block))
// }

fn swap(disk: Disk, i, j) -> Disk {
  let a = Disk(..disk, head: i) |> read
  let b = Disk(..disk, head: j) |> read

  Disk(..disk, blocks: disk.blocks |> dict.insert(i, b) |> dict.insert(j, a))
}

fn compact_blocks(disk: Disk) -> Disk {
  disk |> compact_blocks_loop(disk.size - 1)
}

fn compact_blocks_loop(disk: Disk, i: Int) -> Disk {
  use <- bool.guard(when: disk.head >= i, return: disk)

  let from = disk |> jump(i) |> read

  case read(disk), from {
    Empty, File(_) ->
      disk
      |> swap(disk.head, i)
      |> advance
      |> compact_blocks_loop(i)
    File(_), _ -> disk |> advance |> compact_blocks_loop(i)
    _, Empty -> disk |> compact_blocks_loop(i - 1)
  }
}

fn checksum(disk: Disk) -> Int {
  use checksum, #(index, block) <- list.fold(dict.to_list(disk.blocks), 0)
  case block {
    File(id) -> checksum + id * index
    Empty -> checksum
  }
}

pub fn pt_1(disk: Disk) {
  disk |> compact_blocks |> checksum
}

pub fn pt_2(disk: Disk) {
  todo as "part 2 not implemented"
}
