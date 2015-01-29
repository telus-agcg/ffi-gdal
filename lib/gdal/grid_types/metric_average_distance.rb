require_relative 'data_metrics_base'

module GDAL
  module GridTypes
    class MetricAverageDistance < DataMetricsBase
      def algorithm
        :GGA_MetricAverageDistance
      end
    end
  end
end
