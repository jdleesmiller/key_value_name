# frozen_string_literal: true
require_relative 'marshallers/base'
require_relative 'marshallers/float_marshaller'
require_relative 'marshallers/integer_marshaller'
require_relative 'marshallers/numeric_marshaller'
require_relative 'marshallers/symbol_marshaller'

module KeyValueName
  MARSHALLERS = {
    Float => FloatMarshaller,
    Integer => IntegerMarshaller,
    Numeric => NumericMarshaller,
    Symbol => SymbolMarshaller
  }.freeze
end
