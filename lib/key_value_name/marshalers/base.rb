# frozen_string_literal: true

module KeyValueName
  class MarshalerBase
    def initialize(**kwargs)
    end

    def read(_string)
      raise NotImplementedError
    end

    def write(_value)
      raise NotImplementedError
    end
  end
end
