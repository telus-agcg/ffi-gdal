require_relative 'data_metrics_base'

module GDAL
  module GridTypes
    class MetricMinimum < DataMetricsBase
      # @return [Symbol]
      def algorithm
        :GGA_MetricMinimum
      end
    end
  end
end
