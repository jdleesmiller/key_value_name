# frozen_string_literal: true

require 'scanf'

module KeyValueName
  #
  # Read and write numeric types with a general format string for
  # `Kernel#format` (or `Kernel#sprintf`) and `String#scanf`.
  #
  # This seems like a nice idea, but ruby's `scanf` does not help.
  #
  # Also: not well defined. Does 'x-1.e-2' mean x=1, e=2, or x=1e-2?
  #
  class NumericMarshaler < MarshalerBase
    def initialize(format: '%g', scan_format: nil)
      @format_string = format
      @scan_format_string = scan_format
    end

    attr_reader :format_string

    def scan_format_string
      @scan_format_string || format_string
    end

    def read(string)
      values = string.scanf("#{scan_format_string}.")
      raise "failed to scan: #{string}" if values.empty?
      [values[0], guess_how_many_characters_we_read(string, values[0])]
    end

    def write(value)
      format(format_string, value)
    end

    private

    def guess_how_many_characters_we_read(string, value)
      # Unfortunately, scanf does not implement %n, which would tell us how many
      # characters it read. Instead, we have to guess: count the number of dots
      # in the formatted output, and skip that many. If the string was generated
      # using the appropriate format, this should work; otherwise, it may not.
      formatted_value = format(format_string, value)
      dot_count = formatted_value.scan(/[.]/).size + 1
      index = 0
      while dot_count.positive?
        raise "not enough dots in #{string}" if index.nil?
        index = string.index('.', index + 1)
        dot_count -= 1
      end
      index || string.size
    end
  end
end
