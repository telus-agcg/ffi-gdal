# frozen_string_literal: true

require "ffi"

module FFI
  module GDAL
    # FFI structure for GDALGridInverseDistanceToAPowerOptions.
    # @see https://gdal.org/api/gdal_alg.html#_CPPv438GDALGridInverseDistanceToAPowerOptions
    class GridInverseDistanceToAPowerOptions < FFI::Struct
      DEFAULT_LAYOUT = [
        :power, :double,
        :smoothing, :double,
        :anisotropy_ratio, :double,
        :anisotropy_angle, :double,
        :radius1, :double,
        :radius2, :double,
        :angle, :double,
        :max_points, CPL::Port.find_type(:GUInt32),
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
            *DEFAULT_LAYOUT
          ]
        )
      ].freeze

      layout(*InternalHelpers::LayoutVersionResolver.resolve(versions: LAYOUT_VERSIONS))
    end
  end
end
