# frozen_string_literal: true

require 'ostruct'

module KeyValueName
  #
  # Base class for user-defined schemas.
  #
  class Schema
    def initialize(root:)
      @root = root
    end

    def to_s
      @root
    end

    def parent
      nil
    end

    def mkdir!
      Dir.mkdir_p(to_s)
    end
  end
end
