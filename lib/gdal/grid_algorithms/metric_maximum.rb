# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class MetricMaximum < AlgorithmBase
      def options_class
        ::FFI::GDAL::GridDataMetricsOptions
      end

      def c_identifier
        :GGA_MetricMaximum
      end
    end
  end
end
