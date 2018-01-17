# frozen_string_literal: true

module KeyValueName
  #
  # Yield-based Domain-Specific Language (DSL) to build a `KeyValueName`.
  #
  class KeyValueBuilder
    def initialize(name, &block)
      @name = name
      @marshalers = {}
      instance_eval(&block) if block_given?
    end

    attr_reader :name

    def include_keys(key_value_name_klass)
      spec = key_value_name_klass.key_value_name_spec
      spec.marshalers.each do |name, marshaler|
        check_no_existing_marshaler(name)
        @marshalers[name] = marshaler
      end
    end

    def key(name, type:, **kwargs)
      KeyValueName.check_symbol(name)
      KeyValueName.check_marshaler(type)
      check_no_existing_marshaler(name)
      @marshalers[name] = MARSHALERS[type].new(**kwargs)
    end

    def build
      struct_args = @marshalers.any? ? @marshalers.keys : [nil]
      Struct.new(*struct_args, keyword_init: true)
    end

    private

    def check_no_existing_marshaler(key)
      raise ArgumentError, "already have key: #{key}" if @marshalers.key?(key)
    end
  end
end
