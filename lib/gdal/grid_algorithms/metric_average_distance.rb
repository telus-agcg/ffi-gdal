# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class MetricAverageDistance < AlgorithmBase
      def options_class
        ::FFI::GDAL::GridDataMetricsOptions
      end

      def c_identifier
        :GGA_MetricAverageDistance
      end
    end
  end
end
