require 'ffi'

module FFI
  module GDAL
    class GridDataMetricsOptions < FFI::Struct
      layout :radius1, :double,
        :radius2, :double,
        :angle, :double,
        :min_points, :GUInt32,
        :no_data_value, :double
    end
  end
end