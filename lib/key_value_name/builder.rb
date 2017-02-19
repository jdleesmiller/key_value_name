# frozen_string_literal: true

module KeyValueName
  #
  # Yield-based Domain-Specific Language (DSL) to build a `KeyValueName`.
  #
  class Builder
    module ClassMethods
      def read_hash(name)
        key_value_name_spec.read(name)
      end

      def read(name)
        new(read_hash(name))
      end

      def glob(path)
        Dir.glob(File.join(path, '*')).map do |name|
          basename = File.basename(name)
          new(read_hash(basename)) if key_value_name_spec.matches?(basename)
        end.compact
      end
    end

    module InstanceMethods
      def in(folder)
        File.join(folder, to_s)
      end

      def to_s
        self.class.key_value_name_spec.write(self)
      end
    end

    def initialize
      @spec = Spec.new
    end

    def include_keys(key_value_name_klass)
      @spec.add_keys(key_value_name_klass)
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
