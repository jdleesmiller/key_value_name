# frozen_string_literal: true

module KeyValueName
  #
  # A collection of KeyValueNames.
  #
  class Collection
    def initialize(klass, parent)
      @klass = klass
      @parent = parent
    end

    def new(*args)
      object = @klass.new(*args)
      object.key_value_name_parent = @parent
      object
    end

    def all
      @klass.glob(@parent)
    end

    def where; end

    def find_by; end
  end
end
