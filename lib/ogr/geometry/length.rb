# frozen_string_literal: true

module OGR
  module Geometry
    module Length
      # Computes the length for this geometry.  Computes area for Curve or
      # MultiCurve objects.
      #
      # @return [Float] 0.0 for unsupported geometry types.
      def length
        FFI::OGR::API.OGR_G_Length(@c_pointer)
      end

      # @param distance [Float] Distance along the curve at which to sample position.
      #   The distance should be between 0 and #length.
      # @return [OGR::Point]
      # @raise [FFI::GDAL::InvalidPointer]
      def value(distance)
        OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_Value(@c_pointer, distance)
        end
      end
    end
  end
end
