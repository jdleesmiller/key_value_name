# frozen_string_literal: true

require 'fileutils'

module KeyValueName
  module FileName
    #
    # Instance method mixin for a file.
    #
    module InstanceMethods
      include Name::InstanceMethods

      def exist?
        File.exist?(to_s)
      end

      #
      # Ensure that the parent folder exists.
      #
      # @return [self]
      #
      def mkdir!
        parent.mkdir!
        self
      end

      def touch!
        retried ||= false
        FileUtils.touch(to_s)
        self
      rescue Errno::ENOENT
        FileUtils.mkdir_p(File.dirname(to_s))
        raise if retried
        retried = true
        retry
      end

      def destroy!
        FileUtils.rm(to_s)
      end
    end

    #
    # Class methods of the returned `KeyValueName` class.
    #
    module ClassMethods
      include Name::ClassMethods
    end
  end
end
