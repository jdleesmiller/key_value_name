# frozen_string_literal: true

module KeyValueName
  #
  # Specify the keys and value types for a KeyValueName.
  #
  class Spec
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
      KeyValueName.check_key(name)
      raise ArgumentError, "bad type: #{type}" unless MARSHALERS.key?(type)
      check_no_existing_marshaler(name)
      marshalers[name] = MARSHALERS[type].new(**kwargs)
    end

    def add_keys(klass)
      spec = klass.key_value_name_spec
      spec.marshalers.each do |name, marshaler|
        check_no_existing_marshaler(name)
        marshalers[name] = marshaler
      end
    end

    def matcher
      @matcher ||= build_matcher
    end

    def matches?(string)
      string =~ matcher
    end

    def read(string)
      raise ArgumentError, "bad filename: #{string}" unless string =~ matcher
      Hash[marshalers.map.with_index do |(key, marshaler), index|
        [key, marshaler.read(Regexp.last_match(index + 1))]
      end]
    end

    def write(name)
      string = name.each_pair.map do |key, value|
        check_existing_marshaler(key)
        value_string = marshalers[key].write(value)
        "#{key}#{KEY_VALUE_SEPARATOR}#{value_string}"
      end.join(PAIR_SEPARATOR)
      string += ".#{extension}" unless extension.nil?
      string
    end

    private

    def check_no_existing_marshaler(name)
      raise ArgumentError, "already have key: #{name}" if marshalers.key?(name)
    end

    def check_existing_marshaler(name)
      raise ArgumentError, "unknown key: #{name}" unless marshalers.key?(name)
    end

    def build_matcher
      pair_rxs = marshalers.map do |name, marshaler|
        /#{name}#{KEY_VALUE_SEPARATOR}(#{marshaler.matcher})/
      end
      pairs_matcher = pair_rxs.map(&:to_s).join(PAIR_SEPARATOR)
      extension_matcher = extension.nil? ? '' : /[.]#{extension}/.to_s
      Regexp.new('\A' + pairs_matcher + extension_matcher + '\z')
    end
  end
end
