# frozen_string_literal: true

module KeyValueName
  #
  # Specify the keys and value types for a KeyValueName.
  #
  class Spec
    NAME_BASE_RX = /\w+/
    NAME_RX = /\A#{NAME_BASE_RX}\z/
    KEY_RX = /\A(#{NAME_BASE_RX})#{KEY_VALUE_SEPARATOR}(.+)\z/

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
      raise ArgumentError, "name cannot contain separator: #{name}" unless
        name.to_s.index(PAIR_SEPARATOR).nil?
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

    def read(string)
      hash = {}
      string = check_and_strip_extension(string) unless extension.nil?
      string.split(PAIR_SEPARATOR).each do |pair|
        read_pair(hash, pair)
      end
      hash
    end

    def write(name)
      string = name.each_pair.map do |key, value|
        raise "unknown key: #{key}" unless marshalers.key?(key)
        value_string = marshalers[key].write(value)
        "#{key}#{KEY_VALUE_SEPARATOR}#{value_string}"
      end.join(PAIR_SEPARATOR)
      string += ".#{extension}" unless extension.nil?
      string
    end

    private

    def check_and_strip_extension(name)
      basename = File.basename(name, ".#{extension}")
      raise "bad extension: #{name}" if basename == File.basename(name)
      basename
    end

    def read_pair(hash, pair)
      raise "bad key: #{pair}" unless pair =~ KEY_RX
      key = Regexp.last_match(1).to_sym
      value = Regexp.last_match(2)
      raise "unknown key: #{key}" unless marshalers.key?(key)
      hash[key] = marshalers[key].read(value)
    end
  end
end
