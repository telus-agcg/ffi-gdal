require 'ffi'


module FFI
  module GDAL
    class GDALGridInverseDistanceToAPowerOptions < FFI::Struct
      layout :power, :double,
        :smoothing, :double,
        :anisotropy_ratio, :double,
        :anisotropy_angle, :double,
        :radius1, :double,
        :radius2, :double,
        :angle, :double,
        :max_points, :GUInt32,
        :min_points, :GUInt32,
        :no_data_value, :double
    end
  end
end
