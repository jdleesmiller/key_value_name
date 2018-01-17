# frozen_string_literal: true

module KeyValueName
  #
  # Build a file KeyValueName.
  #
  class FileBuilder < KeyValueBuilder
    def initialize(name, &block)
      @extension = nil
      super
    end

    def extension(extension) # rubocop:disable Style/TrivialAccessors
      @extension = extension
    end

    def build
      klass = super
      klass.class_eval do
        include FileName::InstanceMethods

        class <<self
          include FileName::ClassMethods
        end
      end
      klass.key_value_name_spec = make_spec
      klass
    end

    private

    def make_spec
      prefix = @name
      prefix = "#{prefix}#{KEY_VALUE_SEPARATOR}" if prefix && @marshalers.any?
      suffix = ".#{@extension}" if @extension
      Spec.new(@marshalers, prefix, suffix)
    end
  end
end
