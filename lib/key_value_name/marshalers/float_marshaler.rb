# frozen_string_literal: true

module KeyValueName
  class FloatMarshaler < MarshalerBase
    VALUE_RX = /\A[-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?/

    def read(string)
      raise "bad value in #{string}" unless string =~ VALUE_RX
      Regexp.last_match(0).to_f
    end
  end
end
