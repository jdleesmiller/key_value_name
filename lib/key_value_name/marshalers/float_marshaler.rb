# frozen_string_literal: true

module KeyValueName
  #
  # Read and write float types.
  #
  class FloatMarshaler < MarshalerBase
    def initialize(format: '%g')
      @format_string = format
    end

    attr_reader :format_string

    def matcher
      /[-+]?[0-9]*\.?[0-9]+(?:e[-+]?[0-9]+)?/i
    end

    def parse(string)
      string.to_f
    end

    def generate(value)
      format(format_string, value.to_s)
    end
  end
end
