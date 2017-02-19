# frozen_string_literal: true

#
# A terrible idea, but also a useful one.
#
module KeyValueName
  KEY_RX = /\w+/
  KEY_VALUE_SEPARATOR = '-'
  PAIR_SEPARATOR = '.'
  PAIR_SEPARATOR_RX = /[.]/

  def self.check_symbol(name)
    raise ArgumentError, "bad symbol: #{name}" unless name =~ /\A#{KEY_RX}\z/
  end
end

require_relative 'key_value_name/version'
require_relative 'key_value_name/marshalers'
require_relative 'key_value_name/spec'
require_relative 'key_value_name/builder'
