module GDAL
  module GridAlgorithms
    class MovingAverage
      # @return [FFI::GDAL::GridMovingAverageOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GridMovingAverageOptions.new
      end

      # @return [Symbol]
      def c_identifier
        :GGA_MovingAverage
      end
    end
  end
end
