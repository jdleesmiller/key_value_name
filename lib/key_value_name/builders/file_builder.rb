# frozen_string_literal: true

module KeyValueName
  #
  # Build a file KeyValueName.
  #
  class FileBuilder < KeyValueBuilder
    def initialize(name, *extension, class_name: nil, &block)
      KeyValueName.check_symbol(name) if name
      @name = name
      @extension = extension
      @class_name = class_name
      super(&block)
    end

    def extension(extension)
      raise 'extension already set' if @extension.any?
      @extension = Array(extension)
    end

    def name
      name_parts.join('_').to_sym
    end

    def class_name
      @class_name || default_class_name
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

    def name_parts
      [@name] + @extension
    end

    def default_class_name
      name_parts.map { |part| KeyValueName.camelize(part) }.join('')
    end

    def make_spec
      prefix = @name
      prefix = "#{prefix}#{KEY_VALUE_SEPARATOR}" if prefix && @marshalers.any?
      suffix = ".#{@extension.join('.')}" if @extension.any?
      Spec.new(@marshalers, prefix, suffix)
    end
  end
end
