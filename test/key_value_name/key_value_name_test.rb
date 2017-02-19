# frozen_string_literal: true

require 'minitest/autorun'
require 'fileutils'
require 'tmpdir'

require 'key_value_name'

class TestKeyValueName < MiniTest::Test
  TestInteger = KeyValueName.define do |n|
    n.key :a, type: Numeric, format: '%d'
  end

  TestHexNumeric = KeyValueName.define do |n|
    n.key :b, type: Numeric, format: '%x'
  end

  TestFormattedNumeric = KeyValueName.define do |n|
    n.key :c, type: Numeric, format: '%.3f', scan_format: '%f'
  end

  TestPaddedNumeric = KeyValueName.define do |n|
    n.key :d, type: Numeric, format: '%04d'
  end

  TestSymbol = KeyValueName.define do |n|
    n.key :a, type: Symbol
  end

  TestFloat = KeyValueName.define do |n|
    n.key :a, type: Numeric
  end

  TestTwoIntegers = KeyValueName.define do |n|
    n.include_keys TestInteger
    n.include_keys TestHexNumeric
  end

  TestMixed = KeyValueName.define do |n|
    n.key :id, type: Symbol
    n.key :ordinal, type: Numeric, format: '%d'
    n.key :value, type: Numeric
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

  def test_formatted_numeric_roundtrip
    roundtrip(TestFormattedNumeric, 'c-0.100', c: 0.1)
    roundtrip(TestFormattedNumeric, 'c--0.200', c: -0.2)
  end

  def test_formatted_numeric_parse
    assert_equal(-0.0013, TestFormattedNumeric.read('c--1.3e-3').c)
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
      TestInteger.read('b-3')
    end
  end

  def test_in_folder
    assert_equal File.join('foo', 'a-1'), TestInteger.new(a: 1).in('foo')
  end

  def test_glob_with_integers
    Dir.mktmpdir do |tmp|
      FileUtils.touch TestInteger.new(a: 1).in(tmp)
      FileUtils.touch TestInteger.new(a: 2).in(tmp)
      names = TestInteger.glob(tmp).sort_by(&:a)
      assert_equal 2, names.size
      assert_equal 1, names[0].a
      assert_equal 2, names[1].a
    end
  end
end
