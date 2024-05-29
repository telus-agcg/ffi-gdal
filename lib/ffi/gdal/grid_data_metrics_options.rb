# frozen_string_literal: true

require "ffi"

module FFI
  module GDAL
    # FFI structure for GDALGridDataMetricsOptions.
    # @see https://gdal.org/api/gdal_alg.html#_CPPv426GDALGridDataMetricsOptions
    class GridDataMetricsOptions < FFI::Struct
      DEFAULT_LAYOUT = [
        :radius1, :double,
        :radius2, :double,
        :angle, :double,
        :min_points, CPL::Port.find_type(:GUInt32),
        :no_data_value, :double
      ].freeze

      LAYOUT_VERSIONS = [
        InternalHelpers::LayoutVersion.new(
          version: "0000000", # Any old GDAL
          layout: DEFAULT_LAYOUT
        ),
        InternalHelpers::LayoutVersion.new(
          version: "3060000", # GDAL 3.6.0
          layout: [
            :n_size_of_structure, :size_t,
            *DEFAULT_LAYOUT,
            :max_points_per_quadrant, CPL::Port.find_type(:GUInt32),
            :min_points_per_quadrant, CPL::Port.find_type(:GUInt32)
          ]
        )
      ].freeze

      layout(*InternalHelpers::LayoutVersionResolver.resolve(versions: LAYOUT_VERSIONS))
    end
  end
end
