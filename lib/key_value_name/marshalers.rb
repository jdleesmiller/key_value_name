# frozen_string_literal: true
require_relative 'marshalers/base'
require_relative 'marshalers/float_marshaler'
require_relative 'marshalers/integer_marshaler'
require_relative 'marshalers/numeric_marshaler'
require_relative 'marshalers/symbol_marshaler'

module KeyValueName
  MARSHALERS = {
    Float => FloatMarshaler,
    Integer => IntegerMarshaler,
    Numeric => NumericMarshaler,
    Symbol => SymbolMarshaler
  }.freeze
end
