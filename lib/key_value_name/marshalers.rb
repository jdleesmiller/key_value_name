# frozen_string_literal: true
require_relative 'marshalers/base'
require_relative 'marshalers/numeric_marshaler'
require_relative 'marshalers/symbol_marshaler'

module KeyValueName
  MARSHALERS = {
    Numeric => NumericMarshaler,
    Symbol => SymbolMarshaler
  }.freeze
end
