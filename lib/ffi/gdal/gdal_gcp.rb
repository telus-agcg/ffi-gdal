require 'ffi'


module FFI
  module GDAL

    # Ground Control Point
    class GDALGCP < FFI::Struct
      layout :id, :string,
        :info, :string,
        :pixel, :double,
        :line, :double,
        :x, :double,
        :y, :double,
        :z, :double
    end
  end
end
