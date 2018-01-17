# frozen_string_literal: true

require_relative 'marshalers/base'
require_relative 'marshalers/numeric_marshaler'
require_relative 'marshalers/symbol_marshaler'

#
#
#
module KeyValueName
  MARSHALERS = {
    Numeric => NumericMarshaler,
    Symbol => SymbolMarshaler
  }.freeze

  def self.check_marshaler(type)
    raise ArgumentError, "bad type: #{type}" unless MARSHALERS.key?(type)
  end
end
