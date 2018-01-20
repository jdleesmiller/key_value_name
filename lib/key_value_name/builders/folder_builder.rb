# frozen_string_literal: true

module KeyValueName
  #
  # Build a folder KeyValueName.
  #
  class FolderBuilder < KeyValueBuilder
    include ContainerBuilder

    def initialize(name, &block)
      KeyValueName.check_symbol(name)
      @name = name
      @builders = []
      super(&block)
    end

    attr_reader :name

    def class_name
      KeyValueName.camelize(name)
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
      if @marshalers.any?
        FolderSpec.new(@marshalers, name)
      else
        Spec.new(@marshalers, name.to_s)
      end
    end
  end
end
