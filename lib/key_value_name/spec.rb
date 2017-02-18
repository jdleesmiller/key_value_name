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

    def parse(string)
      hash = {}
      while string =~ KEY_RX
        string = read_pair(hash, Regexp.last_match(1).to_sym, string)
      end
      raise "failed to parse: #{string}" unless check_remainder(string)
      hash
    end

    def write(name)
      string = name.each_pair.map do |key, value|
        raise "unknown key: #{key}" unless marshalers.key?(key)
        value_string = marshalers[key].write(value)
        "#{key}-#{value_string}"
      end.join('.')
      string += ".#{extension}" unless extension.nil?
      string
    end

    private

    def read_pair(hash, key, string)
      raise "unknown key: #{key}" unless marshalers.key?(key)
      string = string[(key.size + 1)..-1]

      value, value_length = marshalers[key].read(string)
      hash[key] = value
      string[value_length..-1]
    end

    def check_remainder(name)
      return name.empty? if extension.nil?
      name == ".#{extension}"
    end
  end
end
