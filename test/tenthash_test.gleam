import bigi
import gleeunit
import gleeunit/should
import tenthash

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  let assert Ok(hash) =
    bigi.from_string("598198084150263088839483816876961374614137064458")
  tenthash.hash("")
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("348036861963983603257132221717602501840767086736")
  tenthash.hash_bitarray(<<0>>)
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("958110116618873061717449209273085911142022422806")
  tenthash.hash("0123456789")
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("1380110527555217708541196361393927539963735354394")
  tenthash.hash("abcdefghijklmnopqrstuvwxyz")
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("1270070799606223119505675671722210953370198240569")
  tenthash.hash("The quick brown fox jumps over the lazy dog.")
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("1414533869033908736539881941974421246169920032745")
  tenthash.hash("This string is exactly 32 bytes.")
  |> should.be_ok
  |> should.equal(hash)
}
