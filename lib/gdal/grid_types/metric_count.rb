require_relative 'data_metrics_base'

module GDAL
  module GridTypes
    class MetricCount < DataMetricsBase
      # @return [Symbol]
      def algorithm
        :GGA_MetricCount
      end
    end
  end
end
