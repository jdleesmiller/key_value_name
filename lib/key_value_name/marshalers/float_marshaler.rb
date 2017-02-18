# frozen_string_literal: true

module KeyValueName
  class FloatMarshaler < MarshalerBase
    VALUE_RX = /\A[-+]?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?\.?/

    def read(string)
      raise "bad value in #{string}" unless string =~ VALUE_RX
      string_result = Regexp.last_match(0)
      result = string_result.to_f
      [result, string_result.size]
    end
  end
end
