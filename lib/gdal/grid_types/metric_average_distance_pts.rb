require_relative 'data_metrics_base'

module GDAL
  module GridTypes
    class MetricAverageDistancePts < DataMetricsBase
      def algorithm
        :GGA_MetricAverageDistancePts
      end
    end
  end
end
