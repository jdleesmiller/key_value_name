# frozen_string_literal: true

module KeyValueName
  class MarshallerBase
    def initialize(**kwargs)
    end

    def read(_string)
      raise NotImplementedError
    end

    def write(value)
      value.to_s
    end
  end
end
