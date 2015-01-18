require_relative 'base'

module GDAL
  module GridTypes
    class InverseDistanceToAPower < Base
      attr_option :power
      attr_option :smoothing
      attr_option :max_points
      attr_option :min_points

      def initialize
        super
      end

      def algorithm
        :GGA_InverseDistanceToAPower
      end
    end
  end
end
