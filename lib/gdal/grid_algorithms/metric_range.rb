# frozen_string_literal: true

module GDAL
  module GridAlgorithms
    class MetricRange < AlgorithmBase
      def options_class
        ::FFI::GDAL::GridDataMetricsOptions
      end

      def c_identifier
        :GGA_MetricRange
      end
    end
  end
end
