require_relative 'base'

module GDAL
  module GridTypes
    class MovingAverage < Base
      attr_option :min_points

      def initialize
        super
      end

      def algorithm
        :GGA_MovingAverage
      end
    end
  end
end
