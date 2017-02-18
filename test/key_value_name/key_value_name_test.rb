# frozen_string_literal: true

require 'key_value_name'
require 'minitest/autorun'

class TestKeyValueName < MiniTest::Test
  TestInteger = KeyValueName.define do |n|
    n.key :a, type: Integer
  end

  TestHexNumeric = KeyValueName.define do |n|
    n.key :b, type: Numeric, format: '%x'
  end

  TestSymbol = KeyValueName.define do |n|
    n.key :a, type: Symbol
  end

  TestFloat = KeyValueName.define do |n|
    n.key :a, type: Float
  end

  TestTwoIntegers = KeyValueName.define do |n|
    n.include_keys TestInteger
    n.include_keys TestHexNumeric
  end

  TestMixed = KeyValueName.define do |n|
    n.key :id, type: Symbol
    n.key :ordinal, type: Integer
    n.key :value, type: Float
  end

  def test_integer_parse
    name = TestInteger.parse('a-123')
    assert_equal 123, name.a
  end

  def test_integer_to_s
    assert_equal 'a-123', TestInteger.new(a: 123).to_s
  end

  def test_hex_integer_parse
    name = TestHexNumeric.parse('b-ff')
    assert_equal 255, name.b
  end

  def test_hex_integer_to_s
    assert_equal 'b-ff', TestHexNumeric.new(b: 255).to_s
  end

  def test_symbol_parse
    name = TestSymbol.parse('a-foo')
    assert_equal :foo, name.a
  end

  def test_symbol_to_s
    assert_equal 'a-foo', TestSymbol.new(a: :foo).to_s
    assert_equal 'a-foo', TestSymbol.new(a: 'foo').to_s
  end

  def test_float_parse
    name = TestFloat.parse('a-2.25')
    assert_equal 2.25, name.a
  end

  def test_float_to_s
    assert_equal 'a-2.25', TestSymbol.new(a: 2.25).to_s
  end

  def test_two_integers_parse
    name = TestTwoIntegers.parse('a-123.b-ff')
    assert_equal 123, name.a
    assert_equal 255, name.b
  end

  def test_two_integers_to_s
    assert_equal 'a-123.b-ff', TestTwoIntegers.new(a: 123, b: 255).to_s
  end

  def test_mixed_parse
    name = TestMixed.parse('id-foo.ordinal-1234.value-2.5e-11')
    assert_equal :foo, name.id
    assert_equal 1234, name.ordinal
    assert_equal 2.5e-11, name.value
  end

  # def test_a_glob
  #   p TestA.glob('.')
  # end
end
