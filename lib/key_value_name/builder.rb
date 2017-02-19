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
      @marshalers = {}
      @extension = nil
    end

    def include_keys(key_value_name_klass)
      spec = key_value_name_klass.key_value_name_spec
      spec.marshalers.each do |name, marshaler|
        check_no_existing_marshaler(name)
        @marshalers[name] = marshaler
      end
    end

    def key(name, type:, **kwargs)
      KeyValueName.check_symbol(name)
      raise ArgumentError, "bad type: #{type}" unless MARSHALERS.key?(type)
      check_no_existing_marshaler(name)
      @marshalers[name] = MARSHALERS[type].new(**kwargs)
    end

    def extension(ext) # rubocop:disable Style/TrivialAccessors
      @extension = ext
    end

    def build # rubocop:disable Metrics/MethodLength
      raise 'no keys defined' if @marshalers.none?

      klass = Struct.new(*@marshalers.keys) do
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
      klass.key_value_name_spec = Spec.new(@marshalers, @extension)
      klass
    end

    private

    def check_no_existing_marshaler(key)
      raise ArgumentError, "already have key: #{key}" if @marshalers.key?(key)
    end
  end

  def self.define
    builder = Builder.new
    yield builder
    builder.build
  end
end
