import bigi.{type BigInt}
import gleam/bit_array
import gleam/io
import gleam/list
import gleam/result

type HashState {
  HashState(a: BigInt, b: BigInt, c: BigInt, d: BigInt, bm: BigInt)
}

const start_state = [
  <<93, 109, 175, 252, 68, 17, 169, 103>>,
  <<226, 45, 77, 234, 104, 87, 127, 52>>, <<202, 80, 134, 77, 129, 76, 188, 46>>,
  <<137, 78, 41, 185, 97, 30, 177, 115>>,
]

const rotation_constants = [
  #(16, 28), #(14, 57), #(11, 22), #(35, 34), #(57, 16), #(59, 40), #(44, 13),
]

pub fn main() {
  //   io.println("Hello from tenthash!")
  //   // io.debug(6_732_230_515_997_387_111)
  //   // do_hash(
  //   //   bit_array.from_string("abcdefghijklmnopqrstuvwxyz"),
  //   //   HashState(bigi.zero(), bigi.zero(), bigi.zero(), bigi.zero()),
  //   // )
  //   // |> io.debug
  //   let assert Ok(a) = hash("abcdefghijklmnopqrstuvwxyz")
  //   io.debug(a)
  //   io.debug(bigi.to_string(a))
  //   // let a = bigi.subtract(bitmask(64), bitmask(63))

  //   // rot_left(a, 3)
  //   // |> io.debug

  bigi.from_bytes(
    <<93, 109, 175, 252, 68, 17, 169, 103>>,
    bigi.BigEndian,
    bigi.Unsigned,
  )
  |> io.debug
}

/// Takes a String and returns a BigInt result 
/// or Error(Nil) if hash failed for some reason
/// 
/// ## Examples
///
/// ```gleam
/// let assert Ok(h) = hash("abcdefghijklmnopqrstuvwxyz")
/// bigi.to_String(h)
/// // -> "1380110527555217708541196361393927539963735354394"
/// ```
pub fn hash(data: String) -> Result(BigInt, Nil) {
  hash_bitarray(bit_array.from_string(data))
}

/// Takes a BitArray and returns a BigInt result 
/// or Error(Nil) if hash failed for some reason
/// 
pub fn hash_bitarray(data: BitArray) -> Result(BigInt, Nil) {
  use init_state <- result.try(initial_state())

  use final_state <- result.try(do_hash(data, init_state))

  finalise_hash(final_state, bit_array.byte_size(data) * 8)
}

fn initial_state() -> Result(HashState, Nil) {
  let assert [a, b, c, d] = start_state
  use a <- result.try(bigi.from_bytes(a, bigi.BigEndian, bigi.Unsigned))
  use b <- result.try(bigi.from_bytes(b, bigi.BigEndian, bigi.Unsigned))
  use c <- result.try(bigi.from_bytes(c, bigi.BigEndian, bigi.Unsigned))
  use d <- result.try(bigi.from_bytes(d, bigi.BigEndian, bigi.Unsigned))
  Ok(HashState(a, b, c, d, bitmask(64)))
}

fn do_hash(data: BitArray, state: HashState) -> Result(HashState, Nil) {
  case data {
    <<
      a:bytes-size(8),
      b:bytes-size(8),
      c:bytes-size(8),
      d:bytes-size(8),
      rest:bits,
    >> -> {
      use hashed_bits <- result.try(hash_bits(a, b, c, d, state))
      do_hash(rest, hashed_bits)
    }
    <<>> -> Ok(state)
    <<a:bits>> -> {
      let extra_bits = 32 - bit_array.byte_size(a)
      let a = bit_array.concat([a, <<0:size({ extra_bits * 8 })>>])
      case a {
        <<a:bytes-size(8), b:bytes-size(8), c:bytes-size(8), d:bytes>> -> {
          use hashed_bits <- result.try(hash_bits(a, b, c, d, state))
          Ok(hashed_bits)
        }
        _ -> {
          Error(Nil)
        }
      }
    }
    // The following shouldn't happen
    _ -> {
      Error(Nil)
    }
  }
}

fn hash_bits(
  a: BitArray,
  b: BitArray,
  c: BitArray,
  d: BitArray,
  state: HashState,
) -> Result(HashState, Nil) {
  let a = bigi.from_bytes(a, bigi.LittleEndian, bigi.Unsigned)
  let b = bigi.from_bytes(b, bigi.LittleEndian, bigi.Unsigned)
  let c = bigi.from_bytes(c, bigi.LittleEndian, bigi.Unsigned)
  let d = bigi.from_bytes(d, bigi.LittleEndian, bigi.Unsigned)
  case a, b, c, d {
    Ok(a), Ok(b), Ok(c), Ok(d) ->
      Ok(
        mix_hash(HashState(
          bigi.bitwise_exclusive_or(state.a, a),
          bigi.bitwise_exclusive_or(state.b, b),
          bigi.bitwise_exclusive_or(state.c, c),
          bigi.bitwise_exclusive_or(state.d, d),
          state.bm,
        )),
      )
    _, _, _, _ -> Error(Nil)
  }
}

fn finalise_hash(state: HashState, len: Int) -> Result(BigInt, Nil) {
  let state =
    HashState(
      ..state,
      a: bigi.bitwise_exclusive_or(state.a, bigi.from_int(len)),
    )
  let final_state = mix_hash(mix_hash(state))
  let assert Ok(a) =
    bigi.to_bytes(final_state.a, bigi.LittleEndian, bigi.Unsigned, 8)
  let assert Ok(b) =
    bigi.to_bytes(final_state.b, bigi.LittleEndian, bigi.Unsigned, 8)
  let assert Ok(c) =
    bigi.to_bytes(final_state.c, bigi.LittleEndian, bigi.Unsigned, 8)
  let ba = bit_array.concat([a, b, c])
  let assert Ok(slice) = bit_array.slice(ba, 0, 20)
  bigi.from_bytes(slice, bigi.BigEndian, bigi.Unsigned)
}

fn mix_hash(state: HashState) -> HashState {
  list.fold(rotation_constants, state, fn(state, rc) {
    let a = bigi.add(state.a, state.c)
    let a = bigi.bitwise_and(a, state.bm)
    let b = bigi.add(state.b, state.d)
    let b = bigi.bitwise_and(b, state.bm)
    let c = rot_left(state.c, rc.0, state.bm)
    let c = bigi.bitwise_exclusive_or(c, a)
    let d = rot_left(state.d, rc.1, state.bm)
    let d = bigi.bitwise_exclusive_or(d, b)
    HashState(b, a, c, d, state.bm)
  })
}

fn bitmask(size: Int) -> BigInt {
  let assert Ok(bitmask) = bigi.power(bigi.from_int(2), bigi.from_int(size))
  bigi.subtract(bitmask, bigi.from_int(1))
}

fn rot_left(i: BigInt, count: Int, bitmask: BigInt) -> BigInt {
  let p1 = bigi.bitwise_and(bigi.bitwise_shift_left(i, count), bitmask)
  let p2 = bigi.bitwise_shift_right(i, 64 - count)
  bigi.bitwise_or(p1, p2)
}
