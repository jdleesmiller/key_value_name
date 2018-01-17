# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'

require 'key_value_name'

class TestSchema < MiniTest::Test
  OneFileSchema = KeyValueName.schema do
    file :foo
  end

  OneFileSetSchema = KeyValueName.schema do
    file :foo do
      key :a, type: Numeric
    end
  end

  OneFolderSchema = KeyValueName.schema do
    folder :foo
  end

  OneFolderSetSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Numeric
    end
  end

  OneFolderSetOneFileSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Numeric
      file :bar
    end
  end

  OneFolderSetOneFolderSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Numeric
      folder :bar
    end
  end

  OneFolderSetOneFolderSetSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Numeric
      folder :bar do
        key :b, type: Symbol
      end
    end
  end

  TripleNestedSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Numeric
      folder :bar do
        key :b, type: Numeric
        folder :baz do
          key :c, type: Numeric
        end
      end
    end
  end

  def test_one_file_schema
    Dir.mktmpdir do |tmp|
      schema = OneFileSchema.new(root: tmp)
      assert_equal [], schema.foo.all

      foo = schema.foo.new
      assert_equal File.join(tmp, 'foo'), foo.to_s

      foo.touch!
      assert_equal [foo], schema.foo.all

      foo.destroy!
      assert_equal [], schema.foo.all
    end
  end

  def test_one_file_set_schema
    Dir.mktmpdir do |tmp|
      schema = OneFileSetSchema.new(root: tmp)
      assert_equal [], schema.foo.all

      foo1 = schema.foo.new(a: 1)
      assert_equal File.join(tmp, 'foo-a-1'), foo1.to_s
      assert_equal 1, foo1.a

      foo2 = schema.foo.new(a: 2)
      assert_equal File.join(tmp, 'foo-a-2'), foo2.to_s
      assert_equal 2, foo2.a
    end
  end

  def test_one_folder_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSchema.new(root: tmp)
      assert_equal [], schema.foo.all

      foo = schema.foo.new
      assert_equal File.join(tmp, 'foo'), foo.to_s

      foo.mkdir!
      assert_equal [foo], schema.foo.all

      foo.destroy!
      assert_equal [], schema.foo.all
    end
  end

  def test_one_folder_set_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetSchema.new(root: tmp)
      assert_equal [], schema.foo.all

      foo1 = schema.foo.new(a: 1)
      assert_equal File.join(tmp, 'foo', 'a-1'), foo1.to_s
      assert_equal 1, foo1.a

      foo2 = schema.foo.new(a: 2)
      assert_equal File.join(tmp, 'foo', 'a-2'), foo2.to_s
      assert_equal 2, foo2.a
    end
  end

  def test_one_folder_set_one_file_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetOneFileSchema.new(root: tmp)

      foo = schema.foo.new(a: 1)
      bar = foo.bar.new
      assert_equal File.join(tmp, 'foo', 'a-1', 'bar'), bar.to_s

      bar.touch!
      assert_equal [bar], foo.bar.all

      bar.destroy!
      assert_equal [], foo.bar.all
    end
  end

  def test_one_folder_set_one_folder_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetOneFolderSchema.new(root: tmp)

      foo = schema.foo.new(a: 1)
      bar = foo.bar.new
      assert_equal File.join(tmp, 'foo', 'a-1', 'bar'), bar.to_s

      bar.mkdir!
      assert_equal [bar], foo.bar.all

      bar.destroy!
      assert_equal [], foo.bar.all
    end
  end

  def test_one_folder_set_one_folder_set_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetOneFolderSetSchema.new(root: tmp)

      foo = schema.foo.new(a: 1)
      bar = foo.bar.new(b: :c)
      assert_equal File.join(tmp, 'foo', 'a-1', 'bar', 'b-c'), bar.to_s

      bar.mkdir!
      assert_equal [bar], foo.bar.all

      bar.destroy!
      assert_equal [], foo.bar.all
    end
  end

  def test_triple_nested_schema
    Dir.mktmpdir do |tmp|
      schema = TripleNestedSchema.new(root: tmp)

      foo = schema.foo.new(a: 1)
      bar = foo.bar.new(b: 2)
      baz = bar.baz.new(c: 3)
      assert_equal \
        File.join(tmp, 'foo', 'a-1', 'bar', 'b-2', 'baz', 'c-3'), baz.to_s

      baz.mkdir!
      assert_equal [baz], bar.baz.all

      baz.destroy!
      assert_equal [], bar.baz.all

      foo.destroy!
      assert_equal [], schema.foo.all
    end
  end
end
