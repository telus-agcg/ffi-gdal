require 'ffi'

module FFI
  module GDAL
    class OGREnvelope < FFI::Struct
      layout :min_x, :double,
        :max_x, :double,
        :min_y, :double,
        :max_y, :double
    end
  end
end
