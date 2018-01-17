# frozen_string_literal: true

require 'fileutils'

module KeyValueName
  module FolderName
    #
    # Instance methods of a KeyValueName for a folder.
    #
    module InstanceMethods
      include Name::InstanceMethods

      def mkdir!
        FileUtils.mkdir_p(to_s)
        self
      end

      def destroy!
        FileUtils.rm_rf(to_s)
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
