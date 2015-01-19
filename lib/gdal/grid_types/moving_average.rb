require_relative '../../ffi/gdal/gdal_grid_moving_average_options'

module GDAL
  module GridTypes
    class MovingAverage
      # @return [FFI::GDAL::GDALGridMovingAverageOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GDALGridMovingAverageOptions.new
      end

      def algorithm
        :GGA_MovingAverage
      end
    end
  end
end
