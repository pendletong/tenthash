import bigi
import gleeunit
import gleeunit/should
import tenthash

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn basic_test() {
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

  let assert Ok(hash) =
    bigi.from_string("478710429239748671568551853611487748748188621629")
  tenthash.hash(
    "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
  )
  |> should.be_ok
  |> should.equal(hash)
}

pub fn stream_test() {
  let assert Ok(hash) =
    bigi.from_string("598198084150263088839483816876961374614137064458")
  tenthash.new()
  |> should.be_ok
  |> tenthash.finalise
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("348036861963983603257132221717602501840767086736")
  tenthash.new()
  |> should.be_ok
  |> tenthash.update_bitarray(<<0>>)
  |> should.be_ok
  |> tenthash.finalise
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("958110116618873061717449209273085911142022422806")
  tenthash.new()
  |> should.be_ok
  |> tenthash.update("0123456789")
  |> should.be_ok
  |> tenthash.finalise
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("958110116618873061717449209273085911142022422806")
  tenthash.new()
  |> should.be_ok
  |> tenthash.update("0")
  |> should.be_ok
  |> tenthash.update("1")
  |> should.be_ok
  |> tenthash.update("2")
  |> should.be_ok
  |> tenthash.update("3")
  |> should.be_ok
  |> tenthash.update("4")
  |> should.be_ok
  |> tenthash.update("5")
  |> should.be_ok
  |> tenthash.update("6")
  |> should.be_ok
  |> tenthash.update("7")
  |> should.be_ok
  |> tenthash.update("8")
  |> should.be_ok
  |> tenthash.update("9")
  |> should.be_ok
  |> tenthash.finalise
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("1270070799606223119505675671722210953370198240569")
  tenthash.new()
  |> should.be_ok
  |> tenthash.update("The quick ")
  |> should.be_ok
  |> tenthash.update("brown fox jumps")
  |> should.be_ok
  |> tenthash.update(" over the lazy dog.")
  |> should.be_ok
  |> tenthash.finalise
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("958110116618873061717449209273085911142022422806")
  tenthash.new()
  |> should.be_ok
  |> tenthash.update_bitarray(<<"0123456789">>)
  |> should.be_ok
  |> tenthash.finalise
  |> should.be_ok
  |> should.equal(hash)

  let assert Ok(hash) =
    bigi.from_string("958110116618873061717449209273085911142022422806")
  tenthash.new()
  |> should.be_ok
  |> tenthash.update_bitarray(<<"0">>)
  |> should.be_ok
  |> tenthash.update_bitarray(<<"1">>)
  |> should.be_ok
  |> tenthash.update_bitarray(<<"2">>)
  |> should.be_ok
  |> tenthash.update_bitarray(<<"3">>)
  |> should.be_ok
  |> tenthash.update_bitarray(<<"4">>)
  |> should.be_ok
  |> tenthash.update_bitarray(<<"5">>)
  |> should.be_ok
  |> tenthash.update_bitarray(<<"6">>)
  |> should.be_ok
  |> tenthash.update_bitarray(<<"7">>)
  |> should.be_ok
  |> tenthash.update_bitarray(<<"8">>)
  |> should.be_ok
  |> tenthash.update_bitarray(<<"9">>)
  |> should.be_ok
  |> tenthash.finalise
  |> should.be_ok
  |> should.equal(hash)
}
