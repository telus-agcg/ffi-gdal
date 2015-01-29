require_relative '../../ffi/gdal/gdal_grid_data_metrics_options'

module GDAL
  module GridTypes
    class DataMetricsBase
      # @return [FFI::GDAL::GDALGridDataMetricsOptions]
      attr_reader :options

      def initialize
        @options = FFI::GDAL::GDALGridDataMetricsOptions.new
      end
    end
  end
end
