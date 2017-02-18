# frozen_string_literal: true

module KeyValueName
  class SymbolMarshaler < MarshalerBase
    VALUE_RX = /\A\w+/

    def read(string)
      raise "bad value in #{string}" unless string =~ VALUE_RX
      Regexp.last_match(0).to_sym
    end

    def write(value)
      raise "value cannot contain separator: #{value}" unless
        value.to_s.index(PAIR_SEPARATOR).nil?
      value.to_s
    end
  end
end
