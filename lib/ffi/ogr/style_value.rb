require 'ffi'

module FFI
  module OGR
    class StyleValue < FFI::Struct
      layout :string_value, :string,
        :double_value, :double,
        :int_value, :int,
        :valid, :GBool,
        :unit, OGRSTUnitId
    end
  end
end
