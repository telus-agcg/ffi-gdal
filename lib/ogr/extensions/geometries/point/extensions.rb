# frozen_string_literal: true

require 'ogr/geometry'

module OGR
  class Point
    module Extensions
      # Wrapper around {#point_value} to provide API parity with other geometries
      # that can have multiple points.
      #
      # @return [Array<Array<Float, Float>>]
      def point_values
        [point]
      end
    end
  end
end

OGR::Point.include(OGR::Point::Extensions)
