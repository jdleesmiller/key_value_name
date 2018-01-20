# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'

require 'key_value_name'

class TestKeyValueName < MiniTest::Test
  TestInteger = KeyValueName.new do
    key :a, type: Integer, format: '%d'
  end

  TestHexNumeric = KeyValueName.new do
    key :b, type: Integer, format: '%x'
  end

  TestFormattedNumeric = KeyValueName.new do
    key :c, type: Float, format: '%.3f'
  end

  TestPaddedNumeric = KeyValueName.new do
    key :d, type: Integer, format: '%04d'
  end

  TestSymbol = KeyValueName.new do
    key :a, type: Symbol
  end

  TestFloat = KeyValueName.new do
    key :a, type: Float
  end

  TestTwoIntegers = KeyValueName.new do
    include_keys TestInteger
    include_keys TestHexNumeric
  end

  TestMixed = KeyValueName.new do
    key :id, type: Symbol
    key :ordinal, type: Integer
    key :value, type: Float
  end

  TestExtension = KeyValueName.new do
    key :big_number, type: Integer, format: '%04d'
    extension 'bin'
  end

  TestEKey = KeyValueName.new do
    key :x, type: Float
    key :e, type: Float
  end

  def roundtrip(klass, string, args)
    name = klass.parse(string)
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

  def test_formatted_numeric_roundtrip
    roundtrip(TestFormattedNumeric, 'c-0.100', c: 0.1)
    roundtrip(TestFormattedNumeric, 'c--0.200', c: -0.2)
  end

  def test_formatted_numeric_parse
    assert_equal(-0.0013, TestFormattedNumeric.parse('c--1.3e-3').c)
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

  def test_exponent_float_roundtrip
    roundtrip(TestFloat, 'a-1e+06', a: 1e6)
    roundtrip(TestFloat, 'a--1e+06', a: -1e6)
    roundtrip(TestFloat, 'a-1e-06', a: 1e-6)
    roundtrip(TestFloat, 'a--1e-06', a: -1e-6)
  end

  def test_two_integers_roundtrip
    roundtrip(TestTwoIntegers, 'a-123.b-ff', a: 123, b: 255)
  end

  def test_mixed_roundtrip
    name = roundtrip(
      TestMixed,
      'id-foo.ordinal-1234.value-2.5e-11',
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
    # A file name called `x-1.e-2` could mean `x=1e-2` or `x=1`, `e=2`. It's
    # still possible to distinguish between them if we know that we're looking
    # for two keys.
    roundtrip(TestEKey, 'x-1.e-2', x: 1, e: 2)
  end

  def test_missing_key
    assert_raises do
      TestInteger.new(b: 3)
    end
    assert_raises(ArgumentError) do
      TestInteger.parse('b-3')
    end
  end

  def test_glob_with_integers
    Dir.mktmpdir do |tmp|
      FileUtils.touch File.join(tmp, TestInteger.new(a: 1).to_s)
      FileUtils.touch File.join(tmp, TestInteger.new(a: 2).to_s)
      names = TestInteger.glob(tmp).sort_by(&:a)
      assert_equal 2, names.size
      assert_equal 1, names[0].a
      assert_equal 2, names[1].a
    end
  end

  def test_sortable
    names = [TestInteger.new(a: 2), TestInteger.new(a: 1)]
    assert_equal [1, 2], names.sort.map(&:a)
  end
end
