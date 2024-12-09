import gleam/int
import gleam/list
import gleam/pair
import gleam/string

pub type Block {
  FileBlock(id: Int)
  EmptyBlock
}

// Note that the list of blocks is in reverse order - this will make the compacting easier
pub fn parse(input: String) -> List(Block) {
  use blocks, size, index <- list.index_fold(string.to_graphemes(input), [])
  let assert Ok(size) = int.parse(size)

  case index % 2 == 0 {
    True -> list.repeat(FileBlock(id: index / 2), size) |> list.append(blocks)
    False -> list.repeat(EmptyBlock, size) |> list.append(blocks)
  }
}

fn compact_blocks(blocks: List(Block)) -> List(Block) {
  // Example:
  //   disk = 5...4..3210
  //   compacted = 3210
  //   uncompacted = 5...4..
  //
  // So to reassemble the blocks we just 
  // list.append(uncompacted, compacted)

  let #(compacted, uncompacted) =
    blocks
    |> list.reverse
    |> list.split_while(fn(block) { block != EmptyBlock })
    |> pair.map_first(list.reverse)
    |> pair.map_second(list.reverse)

  compact_blocks_loop(compacted, uncompacted)
}

fn compact_blocks_loop(
  compacted: List(Block),
  uncompacted: List(Block),
) -> List(Block) {
  case uncompacted {
    [EmptyBlock, ..rest] -> compact_blocks_loop(compacted, rest)
    [FileBlock(_) as block, ..rest] -> {
      let uncompacted =
        rest
        |> list.reverse
        |> list.drop(1)
        |> list.prepend(block)
        |> list.reverse

      list.append(uncompacted, compacted) |> compact_blocks
    }
    [] -> compacted
  }
}

pub fn pt_1(blocks: List(Block)) {
  let blocks = compact_blocks(blocks)
  use checksum, block, index <- list.index_fold(list.reverse(blocks), 0)
  case block {
    FileBlock(id) -> checksum + id * index
    _ -> checksum
  }
}

pub fn pt_2(blocks: List(Block)) {
  todo as "part 2 not implemented"
}
