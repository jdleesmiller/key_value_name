# frozen_string_literal: true

module KeyValueName
  #
  # The root builder. Can contain files and folders only.
  #
  class SchemaBuilder
    include ContainerBuilder

    def initialize(&block)
      @builders = []
      instance_eval(&block)
    end

    def build
      extend_with_builders(Class.new(Schema))
    end
  end
end
