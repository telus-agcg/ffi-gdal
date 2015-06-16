require_relative '../../ffi/gdal/grid_nearest_neighbor_options'

module GDAL
  module GridTypes
    class NearestNeighbor
      # @return [FFI::GDAL::GridNearestNeighborOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GridNearestNeighborOptions.new
      end

      # @return [Symbol]
      def algorithm
        :GGA_NearestNeighbor
      end
    end
  end
end
