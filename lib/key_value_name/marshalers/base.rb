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

    def read(_string)
      raise NotImplementedError
    end

    def write(_value)
      raise NotImplementedError
    end
  end
end
