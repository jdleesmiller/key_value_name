# frozen_string_literal: true

require 'fileutils'

module KeyValueName
  module Name
    #
    # Instance method mixin for a KeyValueName.
    #
    module InstanceMethods
      attr_accessor :parent

      def to_s
        result = self.class.key_value_name_spec.generate(self)
        if parent
          File.join(parent.to_s, result)
        else
          result
        end
      end

      def <=>(other)
        to_a <=> other.to_a
      end
    end

    #
    # Class methods of the returned `KeyValueName` class.
    #
    module ClassMethods
      attr_accessor :key_value_name_spec

      def parse_to_hash(name)
        key_value_name_spec.parse(name)
      end

      def parse(name)
        new(parse_to_hash(name))
      end

      def glob(parent)
        Dir.glob(File.join(parent.to_s, key_value_name_spec.glob)).map do |name|
          basename = File.basename(name)
          next unless key_value_name_spec.matches?(basename)
          name = parse(basename)
          name.parent = parent
          name
        end.compact
      end
    end
  end
end
