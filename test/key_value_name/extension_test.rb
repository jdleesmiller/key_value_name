# frozen_string_literal: true

require 'minitest/autorun'

require 'key_value_name'

class TestExtension < MiniTest::Test
  ExtensionSchema = KeyValueName.schema do
    file :foo

    file :foo, :tar

    file :foo, :tar, :gz

    file :bar, :tar do
      key :a, type: Integer
    end

    file :bar, :tar, :gz do
      key :a, type: Integer
    end
  end

  def test_extensions
    Dir.mktmpdir do |tmp|
      schema = ExtensionSchema.new(root: tmp)

      foo = schema.foo.new
      assert_equal File.join(tmp, 'foo'), foo.to_s
      assert_match(/ExtensionSchema::Foo\z/, foo.class.to_s)

      foo_tar = schema.foo_tar.new
      assert_equal File.join(tmp, 'foo.tar'), foo_tar.to_s
      assert_match(/ExtensionSchema::FooTar\z/, foo_tar.class.to_s)

      foo_tar_gz = schema.foo_tar_gz.new
      assert_equal File.join(tmp, 'foo.tar.gz'), foo_tar_gz.to_s
      assert_match(/ExtensionSchema::FooTarGz\z/, foo_tar_gz.class.to_s)

      bar_tar = schema.bar_tar.new(a: 1)
      assert_equal File.join(tmp, 'bar-a-1.tar'), bar_tar.to_s
      assert_match(/ExtensionSchema::BarTar\z/, bar_tar.class.to_s)

      bar_tar_gz = schema.bar_tar_gz.new(a: 1)
      assert_equal File.join(tmp, 'bar-a-1.tar.gz'), bar_tar_gz.to_s
      assert_match(/ExtensionSchema::BarTarGz\z/, bar_tar_gz.class.to_s)
    end
  end
end
