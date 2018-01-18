# frozen_string_literal: true

module KeyValueName
  #
  # Spec for a key value name of the form `name/key-value`.
  #
  class FolderSpec < Spec
    def initialize(marshalers, name)
      @name = name
      super(marshalers)
    end

    attr_reader :name

    def glob
      File.join(name.to_s, super)
    end

    def generate(struct)
      File.join(name.to_s, super)
    end
  end
end
