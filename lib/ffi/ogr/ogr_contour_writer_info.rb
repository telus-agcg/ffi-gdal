require 'ffi'


module FFI
  module GDAL
    class OGRContourWriterInfo < FFI::Struct
      layout :layer, :pointer,
        :geo_transform, [:double, 6],
        :elev_field, :int,
        :id_field, :int,
        :next_id, :int
    end
  end
end
