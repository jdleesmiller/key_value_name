# frozen_string_literal: true

require 'minitest/autorun'

require 'key_value_name'

class TestFileBuilder < MiniTest::Test
  OneFolderSetSchema = KeyValueName.schema do
    file :foo do
      key :a, type: Integer
    end
  end

  OneFolderSetOneFileSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Integer
      file :bar
    end
  end

  def test_one_folder_set_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetSchema.new(root: tmp)
      assert_equal [], schema.foo.all

      foos = Array.new(3) do |i|
        schema.foo.new(a: i).touch!
      end

      assert_equal [foos[1]], schema.foo.where(a: 1)
      assert_equal foos[1], schema.foo.find_by(a: 1)
    end
  end

  def test_file_destroy!
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetOneFileSchema.new(root: tmp)

      # Should suceed even if parent directory does not exist.
      foo = schema.foo.new(a: 1)
      assert !foo.exist?
      foo.bar.destroy!
      assert !foo.bar.exist?

      foo.bar.touch!
      assert foo.bar.exist?
      foo.bar.destroy!
      assert !foo.bar.exist?
    end
  end

  def test_file_mkdir!
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetOneFileSchema.new(root: tmp)

      foo = schema.foo.new(a: 1)
      bar = foo.bar.mkdir!
      assert_equal File.join(foo.to_s, 'bar'), bar.to_s
      assert_equal [foo], schema.foo.all
      assert foo.exist?
      assert !bar.exist?
    end
  end
end
