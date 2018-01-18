# frozen_string_literal: true

module KeyValueName
  #
  # A Marshaler handles conversion of typed values to and from strings.
  #
  class MarshalerBase
    def initialize(**kwargs) end

    def matcher
      raise NotImplementedError
    end

    def parse(_string)
      raise NotImplementedError
    end

    def generate(_value)
      raise NotImplementedError
    end
  end
end
