# frozen_string_literal: true

module KeyValueName
  class SymbolMarshaler < MarshalerBase
    VALUE_RX = /\A(\w+)\.?/

    def read(string)
      raise "bad value in #{string}" unless string =~ VALUE_RX
      result = Regexp.last_match(1).to_sym
      [result, Regexp.last_match(0).size]
    end
  end
end
