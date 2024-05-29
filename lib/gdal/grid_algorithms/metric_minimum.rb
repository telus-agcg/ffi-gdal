# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class MetricMinimum < AlgorithmBase
      def options_class
        ::FFI::GDAL::GridDataMetricsOptions
      end

      def c_identifier
        :GGA_MetricMinimum
      end
    end
  end
end
