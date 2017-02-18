# frozen_string_literal: true

module KeyValueName
  class IntegerMarshaller < MarshallerBase
    VALUE_RX = /\A(\d+)\.?/

    def read(string)
      raise "bad value in #{string}" unless string =~ VALUE_RX
      result = Regexp.last_match(1).to_i
      [result, Regexp.last_match(0).size]
    end

    def write(value)
      raise "non-integer value: #{value}" unless value.is_a?(Integer)
      value.to_s
    end
  end
end
