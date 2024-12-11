import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/pair
import gleam/result
import gleam/string

pub type Disk {
  Disk(blocks: Dict(Int, Block), head: Int, size: Int, max_file_id: Int)
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

  let max_file_id =
    blocks
    |> list.fold(0, fn(acc, block) {
      case block {
        #(_, File(id)) -> int.max(acc, id)
        _ -> acc
      }
    })

  Disk(
    dict.from_list(blocks),
    head: 0,
    size: list.length(blocks),
    max_file_id: max_file_id,
  )
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
  Disk(..disk, head: int.clamp(n, 0, disk.size))
}

fn write(disk: Disk, block: Block) -> Disk {
  Disk(..disk, blocks: disk.blocks |> dict.insert(disk.head, block))
}

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

pub fn compact_files(disk: Disk) -> Disk {
  use disk, id <- list.fold(list.range(disk.max_file_id, 0), disk)
  disk |> compact_file(id)
}

fn compact_file(disk: Disk, file_id: Int) -> Disk {
  // Helper function
  let head = fn(disk: Disk) { disk.head }

  let file_start = disk |> jump(0) |> seek(File(file_id)) |> head
  let file_size = disk |> jump(file_start) |> span
  let first_gap = disk |> jump(0) |> seek(Empty) |> head

  compact_file_loop(disk |> jump(first_gap), file_start, file_size)
}

fn compact_file_loop(disk: Disk, file_start: Int, file_size: Int) -> Disk {
  use <- bool.guard(when: disk.head >= file_start, return: disk)
  let gap_size = disk |> span

  case gap_size {
    n if n >= file_size ->
      disk
      |> swap_span(file_start, disk.head, file_size)

    _ ->
      disk
      |> skip
      |> seek(Empty)
      |> compact_file_loop(file_start, file_size)
  }
}

fn seek(disk: Disk, target: Block) -> Disk {
  disk |> seek_loop(target)
}

fn seek_loop(disk: Disk, target: Block) -> Disk {
  use <- bool.guard(when: disk.head >= disk.size, return: disk)
  case read(disk) {
    block if block == target -> disk
    _ -> disk |> advance |> seek_loop(target)
  }
}

/// The distance to the end of the current span of identical blocks
fn span(disk: Disk) -> Int {
  let initial_value = disk |> read
  disk |> advance |> span_loop(1, initial_value)
}

fn span_loop(disk: Disk, acc, initial_value) -> Int {
  use <- bool.guard(when: disk.head >= disk.size, return: acc)
  case read(disk) == initial_value {
    True -> disk |> advance |> span_loop(acc + 1, initial_value)
    False -> acc
  }
}

fn skip(disk: Disk) -> Disk {
  let initial_value = disk |> read
  disk |> advance |> skip_loop(initial_value)
}

fn skip_loop(disk: Disk, initial_value) -> Disk {
  use <- bool.guard(when: disk.head >= disk.size, return: disk)
  case read(disk) {
    block if block == initial_value ->
      disk |> advance |> skip_loop(initial_value)
    _ -> disk
  }
}

fn write_span(disk: Disk, block: Block, span: Int) -> Disk {
  use disk, _ <- list.fold(list.range(1, span), disk)
  disk |> write(block) |> advance
}

fn swap_span(disk: Disk, i: Int, j: Int, span: Int) -> Disk {
  let initial_head = disk.head

  let at_i = disk |> jump(i) |> read
  let at_j = disk |> jump(j) |> read

  disk
  |> jump(i)
  |> write_span(at_j, span)
  |> jump(j)
  |> write_span(at_i, span)
  |> jump(initial_head)
}

pub fn pt_2(disk: Disk) {
  disk |> compact_files |> checksum
}

// -- Debugging helpers --

pub fn str_to_disk(str: String) -> Disk {
  let blocks =
    str
    |> string.to_graphemes
    |> list.index_map(fn(c, i) {
      case c {
        "." -> #(i, Empty)
        id -> {
          let assert Ok(id) = int.parse(id)
          #(i, File(id))
        }
      }
    })

  let max_file_id =
    blocks
    |> list.fold(0, fn(acc, block) {
      case block {
        #(_, File(id)) -> int.max(acc, id)
        _ -> acc
      }
    })

  Disk(
    dict.from_list(blocks),
    head: 0,
    size: list.length(blocks),
    max_file_id: max_file_id,
  )
}

pub fn disk_to_str(disk: Disk) -> String {
  disk.blocks
  |> dict.to_list
  |> list.sort(fn(a, b) { int.compare(pair.first(a), pair.first(b)) })
  |> list.map(fn(pair) {
    let #(_, block) = pair
    case block {
      File(id) -> int.to_string(id)
      Empty -> "."
    }
  })
  |> string.join("")
}
