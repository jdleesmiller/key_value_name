# frozen_string_literal: true

module KeyValueName
  #
  # Specify the keys and value types for a KeyValueName.
  #
  class Spec
    NAME_BASE_RX = /\w+/
    NAME_RX = /\A#{NAME_BASE_RX}\z/
    KEY_RX = /\A(#{NAME_BASE_RX})-/

    def initialize
      @marshalers = {}
      @extension = nil
    end

    attr_reader :marshalers
    attr_accessor :extension

    def keys
      marshalers.keys
    end

    def add_key(name, type:, **kwargs)
      raise ArgumentError, "bad name: #{name}" unless name =~ NAME_RX
      raise ArgumentError, "bad type: #{type}" unless MARSHALERS.key?(type)
      raise ArgumentError, "already have: #{name}" if marshalers.key?(name)
      marshalers[name] = MARSHALERS[type].new(**kwargs)
    end

    def add_keys(key_value_name)
      spec = key_value_name.key_value_name_spec
      spec.marshalers.each do |name, marshaler|
        raise ArgumentError, "already have: #{name}" if marshalers.key?(name)
        marshalers[name] = marshaler
      end
    end

    def parse(name)
      hash = {}
      while name =~ KEY_RX
        key = Regexp.last_match(1).to_sym
        raise "unknown key: #{key}" unless marshalers.key?(key)
        name = name[(key.size + 1)..-1]

        value, value_length = marshalers[key].read(name)
        hash[key] = value
        name = name[value_length..-1]
      end
      raise "failed to parse: #{name}" unless name.empty?
      hash
    end

    def write(key, value)
      raise "unknown key: #{key}" unless @marshalers.key?(key)
      @marshalers[key].write(value)
    end
  end
end
