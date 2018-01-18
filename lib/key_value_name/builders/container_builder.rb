# frozen_string_literal: true

module KeyValueName
  #
  # TODO
  #
  module ContainerBuilder
    def file(child_name, *extension, &block)
      @builders << FileBuilder.new(child_name, *extension, &block)
    end

    def folder(child_name, &block)
      @builders << FolderBuilder.new(child_name, &block)
    end

    def extend_with_builders(klass)
      @builders.each do |builder|
        child_class = builder.build
        klass.const_set(builder.class_name, child_class)
        klass.class_eval do
          define_method(builder.name) do
            Collection.new(child_class, self)
          end
        end
      end
      klass
    end
  end
end
