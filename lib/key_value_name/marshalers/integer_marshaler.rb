# frozen_string_literal: true

module KeyValueName
  class IntegerMarshaler < MarshalerBase
    VALUE_RX = /\A\d+/

    def read(string)
      raise "bad value in #{string}" unless string =~ VALUE_RX
      Regexp.last_match(0).to_i
    end

    def write(value)
      raise "non-integer value: #{value}" unless value.is_a?(Integer)
      value.to_s
    end
  end
end
