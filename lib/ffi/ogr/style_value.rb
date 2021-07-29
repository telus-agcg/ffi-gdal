# frozen_string_literal: true

require 'ffi'

module FFI
  module OGR
    class StyleValue < FFI::Struct
      layout :string_value, :string,
             :double_value, :double,
             :int_value, :int,
             :valid, FFI::CPL::Port.find_type(:GBool),
             :unit, FFI::Core.enum_type(:STUnitId)
    end
  end
end
