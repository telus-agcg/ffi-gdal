require 'ffi'

module FFI
  module GDAL
    class OGRStyleValue < FFI::Struct
      layout :string_value, :string,
        :double_value, :double,
        :int_value, :int,
        :valid, :GBool,
        :unit, OGRSTUnitId
    end
  end
end
