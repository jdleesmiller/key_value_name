# frozen_string_literal: true

module KeyValueName
  #
  # TODO
  #
  class SimpleFolderSpec
    def initialize(name)
      @name = name
    end

    attr_reader :name

    def matches?(basename)
      basename == name.to_s
    end

    def glob
      name.to_s
    end

    def read(basename)
      raise ArgumentError, "bad name: #{basename}" unless basename == name.to_s
      {}
    end

    def write(_struct)
      name.to_s
    end
  end
end
