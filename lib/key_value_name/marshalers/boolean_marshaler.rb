# frozen_string_literal: true

module KeyValueName
  #
  # Read and write a boolean flag.
  #
  class BooleanMarshaler < MarshalerBase
    def matcher
      /true|false/i
    end

    def parse(string)
      string == 'true'
    end

    def generate(value)
      value ? 'true' : 'false'
    end

    def to_comparable(value)
      value ? 1 : 0
    end
  end
end
