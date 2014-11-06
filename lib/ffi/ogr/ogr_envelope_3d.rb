require 'ffi'

module FFI
  module GDAL
    class OGREnvelope3D < FFI::Struct
      layout :min_x, :double,
        :max_x, :double,
        :min_y, :double,
        :max_y, :double,
        :min_z, :double,
        :max_z, :double
    end
  end
end
