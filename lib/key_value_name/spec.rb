# frozen_string_literal: true

module KeyValueName
  #
  # Specify the keys and value types for a KeyValueName.
  #
  class Spec
    def initialize(marshalers, extension)
      @marshalers = marshalers
      @extension = extension
      @matcher = build_matcher

      marshalers.freeze
      freeze
    end

    attr_reader :marshalers
    attr_reader :extension
    attr_reader :matcher

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
        value_string = marshalers[key].write(value)
        "#{key}#{KEY_VALUE_SEPARATOR}#{value_string}"
      end.join(PAIR_SEPARATOR)
      string += ".#{extension}" unless extension.nil?
      string
    end

    private

    def build_matcher
      pair_rxs = marshalers.map do |name, marshaler|
        /#{name}#{KEY_VALUE_SEPARATOR}(#{marshaler.matcher})/
      end
      pairs_matcher = pair_rxs.map(&:to_s).join(PAIR_SEPARATOR_RX.to_s)
      extension_matcher = extension.nil? ? '' : /[.]#{extension}/.to_s
      Regexp.new('\A' + pairs_matcher + extension_matcher + '\z')
    end
  end
end
