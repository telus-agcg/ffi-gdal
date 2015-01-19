require_relative 'data_metrics_base'

module GDAL
  module GridTypes
    class MetricRange < DataMetricsBase
      def initialize
        super
      end

      def algorithm
        :GGA_MetricRange
      end
    end
  end
end
