# frozen_string_literal: true

require 'ffi'
require_relative '../gdal'

module FFI
  module GDAL
    class GridDataMetricsOptions < FFI::Struct
      layout :radius1, :double,
             :radius2, :double,
             :angle, :double,
             :min_points, FFI::CPL::Port.find_type(:GUInt32),
             :no_data_value, :double
    end
  end
end
