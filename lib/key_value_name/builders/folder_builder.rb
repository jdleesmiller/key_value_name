# frozen_string_literal: true

module KeyValueName
  #
  # Build a folder KeyValueName.
  #
  class FolderBuilder < KeyValueBuilder
    include ContainerBuilder

    def initialize(name, class_name: nil, &block)
      KeyValueName.check_symbol(name)
      @name = name
      @class_name = class_name
      @builders = []
      super(&block)
    end

    attr_reader :name

    def class_name
      @class_name || KeyValueName.camelize(name)
    end

    def build
      klass = super
      klass.class_eval do
        include FolderName::InstanceMethods

        class <<self
          include FolderName::ClassMethods
        end
      end
      klass.key_value_name_spec = make_spec
      extend_with_builders(klass)
    end

    private

    def make_spec
      prefix = @name
      prefix = "#{prefix}#{KEY_VALUE_SEPARATOR}" if prefix && @marshalers.any?
      Spec.new(@marshalers, prefix)
    end
  end
end
