# frozen_string_literal: true

module KeyValueName
  #
  # Specify the keys and value types for a KeyValueName.
  #
  class Spec
    def initialize(marshalers, prefix = nil, suffix = nil)
      @marshalers = marshalers
      @prefix = prefix
      @suffix = suffix
      @matcher = build_matcher

      marshalers.freeze
      freeze
    end

    attr_reader :marshalers
    attr_reader :prefix
    attr_reader :suffix
    attr_reader :matcher

    def matches?(basename)
      basename =~ matcher
    end

    def glob
      if marshalers.any?
        "#{prefix}*#{suffix}"
      else
        "#{prefix}#{suffix}"
      end
    end

    def read(basename)
      raise ArgumentError, "bad name: #{basename}" unless matcher =~ basename
      Hash[marshalers.map.with_index do |(key, marshaler), index|
        [key, marshaler.read(Regexp.last_match(index + 1))]
      end]
    end

    def write(struct)
      body = struct.each_pair.map do |key, value|
        value_string = marshalers[key].write(value)
        "#{key}#{KEY_VALUE_SEPARATOR}#{value_string}"
      end.join(PAIR_SEPARATOR)
      "#{prefix}#{body}#{suffix}"
    end

    protected

    def build_matcher
      pair_rxs = marshalers.map do |name, marshaler|
        /#{name}#{KEY_VALUE_SEPARATOR}(#{marshaler.matcher})/
      end
      body = pair_rxs.map(&:to_s).join(PAIR_SEPARATOR_RX.to_s)
      Regexp.new("\\A#{prefix}#{body}#{suffix}\\z")
    end
  end
end
