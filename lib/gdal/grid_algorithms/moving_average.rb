# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class MovingAverage < AlgorithmBase
      def options_class
        ::FFI::GDAL::GridMovingAverageOptions
      end

      def c_identifier
        :GGA_MovingAverage
      end
    end
  end
end
