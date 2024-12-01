import gleam/list
import gleam/result

/// Returns a list of size 2 tuple chunks.
/// 
/// If the list is of odd length (so that the last chunk would contain 1 element), an `Error` is returned.
///
/// ## Examples
/// 
/// ```gleam
/// chunk_by_2([1, 2, 3, 4])
/// // -> Ok([#(1, 2), #(3, 4)])
/// ```
///
/// ```gleam
/// chunk_by_2([1, 2, 3])
/// // -> Error(Nil)
/// ```
/// 
/// ```gleam
/// chunk_by_2([])
/// // -> Ok([])
/// ```
///
pub fn chunk_by_2(items: List(value)) -> Result(List(#(value, value)), Nil) {
  let tuplify = fn(pair) {
    case pair {
      [a, b] -> Ok(#(a, b))
      _ -> Error(Nil)
    }
  }

  items
  |> list.sized_chunk(2)
  |> list.map(tuplify)
  |> result.all
}
