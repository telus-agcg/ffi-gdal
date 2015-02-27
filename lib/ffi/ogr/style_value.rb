require 'ffi'
require_relative '../cpl/port'

module FFI
  module OGR
    class StyleValue < FFI::Struct
      layout :string_value, :string,
        :double_value, :double,
        :int_value, :int,
        :valid, FFI::CPL::Port.find_type(:GBool),
        :unit, OGRSTUnitId
    end
  end
end
