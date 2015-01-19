require_relative 'base'

module GDAL
  module GridTypes
    class DataMetricsBase < Base
      attr_option :min_points
      
      def initialize
        super
      end
    end
  end
end
