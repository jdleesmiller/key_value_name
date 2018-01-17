# frozen_string_literal: true

require 'fileutils'

module KeyValueName
  module Name
    #
    # Instance method mixin for a KeyValueName.
    #
    module InstanceMethods
      attr_accessor :key_value_name_parent

      def to_s
        result = self.class.key_value_name_spec.write(self)
        if key_value_name_parent
          File.join(key_value_name_parent.to_s, result)
        else
          result
        end
      end
    end

    #
    # Class methods of the returned `KeyValueName` class.
    #
    module ClassMethods
      attr_accessor :key_value_name_spec

      def read_hash(name)
        key_value_name_spec.read(name)
      end

      def read(name)
        new(read_hash(name))
      end

      def glob(parent)
        Dir.glob(File.join(parent.to_s, key_value_name_spec.glob)).map do |name|
          basename = File.basename(name)
          next unless key_value_name_spec.matches?(basename)
          name = new(read_hash(basename))
          name.key_value_name_parent = parent
          name
        end.compact
      end
    end
  end
end
