# frozen_string_literal: true

require 'key_value_name/version'
require 'scanf'

#
# A terrible idea, but also a useful one.
#
module KeyValueName
  class MarshallerBase
    def initialize(**kwargs)
    end

    def write(value)
      value.to_s
    end
  end

  class FloatMarshaller < MarshallerBase
    VALUE_RX = /\A[-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?\.?/

    def read(string)
      raise "bad value in #{string}" unless string =~ VALUE_RX
      string_result = Regexp.last_match(0)
      result = string_result.to_f
      [result, string_result]
    end
  end

  class IntegerMarshaller < MarshallerBase
    SUPPORTED_BASES = [10, 16].freeze

    def initialize(base: 10)
      raise ArgumentError, "unsupported base: #{base}" unless
        SUPPORTED_BASES.member?(base)

      @base = base
    end

    attr_reader :base

    def matcher
      case base
      when 10 then /\A(\d+)\.?/
      when 16 then /\A([0-9a-f]+)\.?/i
      end
    end

    def read(string)
      raise "bad value in #{string}" unless string =~ matcher
      string_result = Regexp.last_match(0)
      result = Regexp.last_match(1).to_i(base)
      [result, string_result]
    end

    def write(value)
      # The error message is pretty confusing if you call to_s on a non-Integer,
      # so trap that case.
      raise "non-integer value: #{value}" unless value.is_a?(Integer)
      value.to_s(base)
    end
  end

  class SymbolMarshaller < MarshallerBase
    VALUE_RX = /\A(\w+)\.?/

    def read(string)
      raise "bad value in #{string}" unless string =~ VALUE_RX
      string_result = Regexp.last_match(0)
      result = Regexp.last_match(1).to_sym
      [result, string_result]
    end
  end

  MARSHALLERS = {
    Float => FloatMarshaller,
    Integer => IntegerMarshaller,
    Symbol => SymbolMarshaller
  }.freeze

  #
  # Specify the keys and value types for a KeyValueName.
  #
  class Spec
    NAME_BASE_RX = /\w+/
    NAME_RX = /\A#{NAME_BASE_RX}\z/
    KEY_RX = /\A(#{NAME_BASE_RX})-/

    def initialize
      @marshallers = {}
      @extension = nil
    end

    attr_reader :marshallers
    attr_accessor :extension

    def keys
      marshallers.keys
    end

    def add_key(name, type:, **kwargs)
      raise ArgumentError, "bad name: #{name}" unless name =~ NAME_RX
      raise ArgumentError, "bad type: #{type}" unless MARSHALLERS.key?(type)
      raise ArgumentError, "already have: #{name}" if marshallers.key?(name)
      marshallers[name] = MARSHALLERS[type].new(**kwargs)
    end

    def add_keys(key_value_name)
      spec = key_value_name.key_value_name_spec
      spec.marshallers.each do |name, marshaller|
        raise ArgumentError, "already have: #{name}" if marshallers.key?(name)
        marshallers[name] = marshaller
      end
      p marshallers
    end

    def parse(name)
      hash = {}
      while name =~ KEY_RX
        key = Regexp.last_match(1).to_sym
        raise "unknown key: #{key}" unless marshallers.key?(key)
        name = name[(key.size + 1)..-1]

        value, string_value = marshallers[key].read(name)
        hash[key] = value
        name = name[(string_value.size)..-1]
      end
      raise "failed to parse: #{name}" unless name.empty?
      hash
    end

    def write(key, value)
      raise "unknown key: #{key}" unless @marshallers.key?(key)
      @marshallers[key].write(value)
    end
  end

  module ClassMethods
    def parse_hash(name)
      key_value_name_spec.parse(name)
    end

    def parse(name)
      new(parse_hash(name))
    end

    def glob(path)
      Dir.glob(File.join(path, '*')).map do |name|
        p name
      end
    end
  end

  module InstanceMethods
    def to_s
      each_pair.map do |key, value|
        value_string = self.class.key_value_name_spec.write(key, value)
        "#{key}-#{value_string}"
      end.join('.')
    end
  end

  #
  # Yield-based Domain-Specific Language (DSL) to build a `KeyValueName`.
  #
  class Builder
    def initialize
      @spec = Spec.new
    end

    def include_keys(key_value_name)
      @spec.add_keys(key_value_name)
    end

    def key(name, **kwargs)
      @spec.add_key(name, **kwargs)
    end

    def extension(ext)
      @spec.extension = ext
    end

    def build
      raise 'no keys defined' if @spec.keys.none?

      klass = Struct.new(*@spec.keys) do
        def initialize(**kwargs)
          super(*kwargs.keys)
          kwargs.each { |k, v| self[k] = v }
        end

        include InstanceMethods

        class <<self
          include ClassMethods
          attr_accessor :key_value_name_spec
        end
      end
      klass.key_value_name_spec = @spec
      klass
    end
  end

  def self.define
    builder = Builder.new
    yield builder
    builder.build
  end
end
