# frozen_string_literal: true

module KeyValueName
  class SymbolMarshaler < MarshalerBase
    VALUE_RX = /\A#{KEY_RX}\z/

    def read(string)
      raise "bad value in #{string}" unless string =~ VALUE_RX
      Regexp.last_match(0).to_sym
    end

    def write(value)
      KeyValueName.check_key(value)
      value.to_s
    end
  end
end
