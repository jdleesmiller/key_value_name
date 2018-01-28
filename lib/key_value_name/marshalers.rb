# frozen_string_literal: true

require_relative 'marshalers/base'
require_relative 'marshalers/boolean_marshaler'
require_relative 'marshalers/float_marshaler'
require_relative 'marshalers/integer_marshaler'
require_relative 'marshalers/symbol_marshaler'

#
#
#
module KeyValueName
  MARSHALERS = {
    boolean: BooleanMarshaler,
    Float => FloatMarshaler,
    Integer => IntegerMarshaler,
    Symbol => SymbolMarshaler
  }.freeze

  def self.check_marshaler(type)
    raise ArgumentError, "bad type: #{type}" unless MARSHALERS.key?(type)
  end
end
