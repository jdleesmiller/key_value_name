# frozen_string_literal: true

require 'scanf'

module KeyValueName
  #
  # Read and write numeric types with a general format string for
  # `Kernel#format` (or `Kernel#sprintf`) and `String#scanf`.
  #
  # This seems like a nice idea, but ruby's `scanf` doesn't seem to handle
  # all possible format strings. For example, you can format with `%.1f`, but
  # scanning with that string does not work. To work around this problem,
  # you can specify a separate `scan_format` that `scanf` can handle; for this
  # example, it would be just `%f`.
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
      values = string.scanf(scan_format_string)
      raise "failed to scan: #{string}" if values.empty?
      values.first
    end

    def write(value)
      format(format_string, value)
    end
  end
end
