# frozen_string_literal: true

module KeyValueName
  #
  # A collection of KeyValueNames.
  #
  class Collection
    include Enumerable

    def initialize(klass, parent)
      @klass = klass
      @parent = parent
    end

    def new(*args)
      object = @klass.new(*args)
      object.parent = @parent
      object
    end

    def each(&block)
      all.each(&block)
    end

    def all
      @klass.glob(@parent).sort
    end

    def where(**kwargs)
      all.select do |name|
        kwargs.all? do |key, value|
          name[key] == value
        end
      end
    end

    def find_by(**kwargs)
      where(**kwargs).first
    end
  end
end
