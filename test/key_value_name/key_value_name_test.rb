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

  TestFloatNumeric = KeyValueName.define do |n|
    n.key :c, type: Numeric, format: '%.3f', scan_format: '%f'
  end

  TestPaddedNumeric = KeyValueName.define do |n|
    n.key :d, type: Numeric, format: '%04d'
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

  TestExtension = KeyValueName.define do |n|
    n.key :big_number, type: Numeric, format: '%04d'
    n.extension 'bin'
  end

  TestEKey = KeyValueName.define do |n|
    n.key :x, type: Numeric
    n.key :e, type: Numeric
  end

  def roundtrip(klass, string, args)
    name = klass.read(string)
    assert_equal args.keys, name.to_h.keys
    args.each do |key, value|
      assert_equal value, name[key]
    end
    assert_equal string, name.to_s
    name
  end

  def test_integer_roundtrip
    roundtrip(TestInteger, 'a-123', a: 123)
  end

  def test_hex_numeric_roundtrip
    roundtrip(TestHexNumeric, 'b-ff', b: 255)
  end

  def test_float_numeric_roundtrip
    roundtrip(TestFloatNumeric, 'c-0.100', c: 0.1)
    roundtrip(TestFloatNumeric, 'c--0.200', c: -0.2)
  end

  def test_float_numeric_parse
    assert_equal(-0.0013, TestFloatNumeric.read('c--1.3e-3').c)
  end

  def test_padded_numeric_roundtrip
    roundtrip(TestPaddedNumeric, 'd-0012', d: 12)
  end

  def test_symbol_roundtrip
    roundtrip(TestSymbol, 'a-foo', a: :foo)
  end

  def test_symbol_accepts_strings
    assert_equal 'a-foo', TestSymbol.new(a: 'foo').to_s
  end

  def test_float_roundtrip
    roundtrip(TestFloat, 'a-2.25', a: 2.25)
  end

  def test_two_integers_roundtrip
    roundtrip(TestTwoIntegers, 'a-123__b-ff', a: 123, b: 255)
  end

  def test_mixed_roundtrip
    name = roundtrip(
      TestMixed,
      'id-foo__ordinal-1234__value-2.5e-11',
      id: :foo, ordinal: 1234, value: 2.5e-11
    )
    assert_equal :foo, name.id
    assert_equal 1234, name.ordinal
    assert_equal 2.5e-11, name.value
  end

  def test_extension_roundtrip
    roundtrip(TestExtension, 'big_number-0123.bin', big_number: 123)
  end

  def test_e_key_roundtrip
    # A previous version used dots to separate names, which looked nicer, but
    # it meant that `x-1.e-2` was hard to parse. It's much easier if we can
    # just assume that the pair separator will not occur in the strings.
    roundtrip(TestEKey, 'x-1__e-2', x: 1, e: 2)
  end

  # def test_a_glob
  #   p TestA.glob('.')
  # end
end
