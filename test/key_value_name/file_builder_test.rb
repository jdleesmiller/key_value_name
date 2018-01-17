# frozen_string_literal: true

require 'minitest/autorun'

require 'key_value_name'

class TestFileBuilder < MiniTest::Test
  OneFolderSetSchema = KeyValueName.schema do
    file :foo do
      key :a, type: Numeric, format: '%d'
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
end
