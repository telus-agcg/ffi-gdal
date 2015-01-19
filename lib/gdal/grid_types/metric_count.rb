require_relative 'data_metrics_base'

module GDAL
  module GridTypes
    class MetricCount < DataMetricsBase
      def initialize
        super
      end

      def algorithm
        :GGA_MetricCount
      end
    end
  end
end
