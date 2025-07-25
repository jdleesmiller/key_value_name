# frozen_string_literal: true

module KeyValueName
  #
  # TODO
  #
  module ContainerBuilder
    def file(...)
      @builders << FileBuilder.new(...)
    end

    def folder(...)
      @builders << FolderBuilder.new(...)
    end

    def extend_with_builders(klass)
      @builders.each do |builder|
        child_class = builder.build
        klass.const_set(builder.class_name, child_class)
        if builder.singular?
          build_singular(builder, klass, child_class)
        else
          build_collection(builder, klass, child_class)
        end
      end
      klass
    end

    private

    def build_singular(builder, klass, child_class)
      klass.class_eval do
        define_method(builder.name) do
          child = child_class.new
          child.parent = self
          child
        end
      end
    end

    def build_collection(builder, klass, child_class)
      klass.class_eval do
        define_method(builder.name) do
          Collection.new(child_class, self)
        end
      end
    end
  end
end
