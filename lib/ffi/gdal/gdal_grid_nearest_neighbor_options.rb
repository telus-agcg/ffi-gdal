require 'ffi'


module FFI
  module GDAL
    class GDALGridNearestNeighborOptions < FFI::Struct
      layout :radius1, :double,
        :radius2, :double,
        :angle, :double,
        :no_data_value, :double
    end
  end
end
