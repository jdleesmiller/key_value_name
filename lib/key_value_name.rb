# frozen_string_literal: true

require_relative 'key_value_name/version'
require_relative 'key_value_name/marshalers'
require_relative 'key_value_name/spec'

#
# A terrible idea, but also a useful one.
#
module KeyValueName
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
