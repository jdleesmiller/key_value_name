# frozen_string_literal: true

require 'minitest/autorun'
require 'tmpdir'

require 'key_value_name'

class TestSchema < Minitest::Test
  OneFileSchema = KeyValueName.schema do
    file :foo
  end

  OneFileSetSchema = KeyValueName.schema do
    file :foo do
      key :a, type: Integer
    end
  end

  OneFolderSchema = KeyValueName.schema do
    folder :foo
  end

  OneFolderSetSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Integer
    end
  end

  OneFolderSetOneFileSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Integer
      file :bar
    end
  end

  OneFolderSetOneFolderSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Integer
      folder :bar
    end
  end

  OneFolderSetOneFolderSetSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Integer
      folder :bar do
        key :b, type: Symbol
      end
    end
  end

  TripleNestedSchema = KeyValueName.schema do
    folder :foo do
      key :a, type: Integer
      folder :bar do
        key :b, type: Integer
        folder :baz do
          key :c, type: Integer
        end
      end
    end
  end

  CustomClassNameSchema = KeyValueName.schema do
    folder :foo, class_name: :CustomFoo do
      file :bar, class_name: :CustomBar
    end
  end

  def test_one_file_schema
    Dir.mktmpdir do |tmp|
      schema = OneFileSchema.new(root: tmp)
      foo = schema.foo
      assert !foo.exist?

      assert_equal File.join(tmp, 'foo'), foo.to_s

      foo.touch!
      assert foo.exist?

      foo.destroy!
      assert !foo.exist?
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
      foo = schema.foo
      assert !foo.exist?

      assert_equal File.join(tmp, 'foo'), foo.to_s

      foo.mkdir!
      assert foo.exist?

      foo.destroy!
      assert !foo.exist?
    end
  end

  def test_one_folder_set_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetSchema.new(root: tmp)
      assert_equal [], schema.foo.all

      foo1 = schema.foo.new(a: 1)
      assert_equal File.join(tmp, 'foo-a-1'), foo1.to_s
      assert_equal 1, foo1.a

      foo2 = schema.foo.new(a: 2)
      assert_equal File.join(tmp, 'foo-a-2'), foo2.to_s
      assert_equal 2, foo2.a
    end
  end

  def test_one_folder_set_one_file_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetOneFileSchema.new(root: tmp)

      foo = schema.foo.new(a: 1)
      bar = foo.bar
      assert_equal File.join(tmp, 'foo-a-1', 'bar'), bar.to_s

      bar.touch!
      assert bar.exist?

      bar.destroy!
      assert !bar.exist?
    end
  end

  def test_one_folder_set_one_folder_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetOneFolderSchema.new(root: tmp)

      foo = schema.foo.new(a: 1)
      bar = foo.bar
      assert_equal File.join(tmp, 'foo-a-1', 'bar'), bar.to_s

      bar.mkdir!
      assert bar.exist?

      bar.destroy!
      assert !bar.exist?
    end
  end

  def test_one_folder_set_one_folder_set_schema
    Dir.mktmpdir do |tmp|
      schema = OneFolderSetOneFolderSetSchema.new(root: tmp)

      foo = schema.foo.new(a: 1)
      bar = foo.bar.new(b: :c)
      assert_equal File.join(tmp, 'foo-a-1', 'bar-b-c'), bar.to_s

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
        File.join(tmp, 'foo-a-1', 'bar-b-2', 'baz-c-3'), baz.to_s

      baz.mkdir!
      assert_equal [baz], bar.baz.all

      baz.destroy!
      assert_equal [], bar.baz.all

      foo.destroy!
      assert_equal [], schema.foo.all
    end
  end

  def test_parent
    Dir.mktmpdir do |tmp|
      schema = TripleNestedSchema.new(root: tmp)

      foo = schema.foo.new(a: 1)
      bar = foo.bar.new(b: 2)
      baz = bar.baz.new(c: 3)

      assert_nil schema.parent
      assert_equal schema, foo.parent
      assert_equal foo, bar.parent
      assert_equal bar, baz.parent
      assert_equal foo, baz.parent.parent
    end
  end

  def test_reserved_keys
    error = assert_raises(ArgumentError) do
      KeyValueName.schema do
        file :parent
      end
    end
    assert_match(/reserved symbol/, error.message)

    error = assert_raises(ArgumentError) do
      KeyValueName.schema do
        folder :parent
      end
    end
    assert_match(/reserved symbol/, error.message)

    error = assert_raises(ArgumentError) do
      KeyValueName.schema do
        folder :foo do
          key :parent, type: Integer
        end
      end
    end
    assert_match(/reserved symbol/, error.message)
  end

  def test_custom_class_name
    Dir.mktmpdir do |tmp|
      schema = CustomClassNameSchema.new(root: tmp)

      foo = schema.foo
      assert_match(/CustomClassNameSchema::CustomFoo\z/, foo.class.to_s)

      bar = foo.bar
      assert_match(
        /CustomClassNameSchema::CustomFoo::CustomBar\z/,
        bar.class.to_s
      )
    end
  end
end
