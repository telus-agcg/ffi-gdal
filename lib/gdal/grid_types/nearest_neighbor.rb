require_relative 'base'

module GDAL
  module GridTypes
    class NearestNeighbor < Base

      def initialize
        super
      end

      def algorithm
        :GGA_NearestNeighbor
      end
    end
  end
end
