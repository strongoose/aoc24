import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/string

pub type Disk {
  Disk(blocks: Dict(Int, Block), front_head: Int, back_head: Int)
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

  Disk(dict.from_list(blocks), 0, list.length(blocks) - 1)
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

fn advance_front(disk: Disk) -> Disk {
  Disk(..disk, front_head: disk.front_head + 1)
}

fn advance_back(disk: Disk) -> Disk {
  Disk(..disk, back_head: disk.back_head - 1)
}

fn read_front(disk: Disk) -> Block {
  let assert Ok(block) = disk.blocks |> dict.get(disk.front_head)
  block
}

fn read_back(disk: Disk) -> Block {
  let assert Ok(block) = disk.blocks |> dict.get(disk.back_head)
  block
}

fn write_front(disk: Disk, block: Block) -> Disk {
  Disk(..disk, blocks: disk.blocks |> dict.insert(disk.front_head, block))
}

fn write_back(disk: Disk, block: Block) -> Disk {
  Disk(..disk, blocks: disk.blocks |> dict.insert(disk.back_head, block))
}

fn swap(disk: Disk) -> Disk {
  let #(front, back) = #(read_front(disk), read_back(disk))
  disk
  |> write_front(back)
  |> write_back(front)
}

fn compact(disk: Disk) -> Disk {
  use <- bool.guard(when: disk.front_head >= disk.back_head, return: disk)
  case read_front(disk), read_back(disk) {
    Empty, File(_) -> disk |> swap |> advance_front |> compact
    File(_), _ -> disk |> advance_front |> compact
    _, Empty -> disk |> advance_back |> compact
  }
}

pub fn pt_1(disk: Disk) {
  use checksum, #(index, block) <- list.fold(
    dict.to_list(compact(disk).blocks),
    0,
  )
  case block {
    File(id) -> checksum + id * index
    Empty -> checksum
  }
}

pub fn pt_2(disk: Disk) {
  todo as "part 2 not implemented"
}
