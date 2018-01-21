# frozen_string_literal: true

#
# A terrible idea, but also a useful one.
#
module KeyValueName
  KEY_RX = /\w+/
  KEY_VALUE_SEPARATOR = '-'
  PAIR_SEPARATOR = '.'
  PAIR_SEPARATOR_RX = /[.]/

  def self.camelize(name)
    name.to_s.gsub(/(?:\A|_)(.)/) { Regexp.last_match(1).upcase }
  end

  def self.check_symbol(name)
    raise ArgumentError, "bad symbol: #{name}" unless
      name.match?(/\A#{KEY_RX}\z/)
    raise ArgumentError, "reserved symbol: #{name}" if
      %i[parent].member?(name)
  end

  def self.new(name = nil, &block)
    raise unless block_given?
    FileBuilder.new(name, &block).build
  end

  def self.schema(&block)
    raise unless block_given?
    SchemaBuilder.new(&block).build
  end
end

require_relative 'key_value_name/version'
require_relative 'key_value_name/marshalers'
require_relative 'key_value_name/schema'
require_relative 'key_value_name/collection'
require_relative 'key_value_name/mixins/name'
require_relative 'key_value_name/mixins/file_name'
require_relative 'key_value_name/mixins/folder_name'
require_relative 'key_value_name/spec'
require_relative 'key_value_name/builders/key_value_builder'
require_relative 'key_value_name/builders/container_builder'
require_relative 'key_value_name/builders/schema_builder'
require_relative 'key_value_name/builders/file_builder'
require_relative 'key_value_name/builders/folder_builder'
