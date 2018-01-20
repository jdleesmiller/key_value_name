# frozen_string_literal: true

module KeyValueName
  #
  # Read and write integer types. Positive binary, octal and hexadecimal numbers
  # without prefixes are also supported. Padding with zeros is OK, but padding
  # with spaces will not work.
  #
  class IntegerMarshaler < MarshalerBase
    def initialize(format: '%d')
      @format_string = format
    end

    attr_reader :format_string

    def matcher
      /[-+]?[0-9a-f]+/i
    end

    def base
      case format_string
      when /b\z/i then 2
      when /o\z/i then 8
      when /x\z/i then 16
      else 10
      end
    end

    def parse(string)
      string.to_i(base)
    end

    def generate(value)
      format(format_string, value)
    end
  end
end
