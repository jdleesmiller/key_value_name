# frozen_string_literal: true

#
# A terrible idea, but also a useful one.
#
module KeyValueName
  KEY_VALUE_SEPARATOR = '-'
  PAIR_SEPARATOR = '__'
end

require_relative 'key_value_name/version'
require_relative 'key_value_name/marshalers'
require_relative 'key_value_name/spec'
require_relative 'key_value_name/builder'
