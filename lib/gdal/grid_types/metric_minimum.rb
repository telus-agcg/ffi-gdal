require_relative 'data_metrics_base'

module GDAL
  module GridTypes
    class MetricMinimum < DataMetricsBase
      def algorithm
        :GGA_MetricMinimum
      end
    end
  end
end
