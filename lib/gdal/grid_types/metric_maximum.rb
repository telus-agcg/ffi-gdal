require_relative 'data_metrics_base'

module GDAL
  module GridTypes
    class MetricMaximum < DataMetricsBase
      def initialize
        super
      end

      def algorithm
        :GGA_MetricMaximum
      end
    end
  end
end
