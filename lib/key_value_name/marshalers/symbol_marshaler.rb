# frozen_string_literal: true

module KeyValueName
  #
  # Read and write symbol values.
  #
  class SymbolMarshaler < MarshalerBase
    def matcher
      KEY_RX
    end

    def parse(string)
      string.to_sym
    end

    def generate(value)
      KeyValueName.check_symbol(value)
      value.to_s
    end
  end
end
