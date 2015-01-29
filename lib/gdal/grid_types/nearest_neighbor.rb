require_relative '../../ffi/gdal/gdal_grid_nearest_neighbor_options'

module GDAL
  module GridTypes
    class NearestNeighbor
      # @return [FFI::GDAL::GDALGridNearestNeighborOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GDALGridNearestNeighborOptions.new
      end

      def algorithm
        :GGA_NearestNeighbor
      end
    end
  end
end
