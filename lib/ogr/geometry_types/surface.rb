require_relative '../../ffi/ogr/api'

module OGR
  module GeometryTypes
    module Surface
      # Computes area for a LinearRing, Polygon, or MultiPolygon.  The area of
      # the feature is in square units of the spatial reference system in use.
      #
      # @return [Float] 0.0 for unsupported geometry types.
      def area
        FFI::OGR::API.OGR_G_Area(@geometry_pointer)
      end

      # Returns the units used by the associated OGR::SpatialReference.
      #
      # @return [Hash]
      def area_units
        spatial_reference ? spatial_reference.linear_units : nil
      end

      # Returns a point that's guaranteed to lie on the surface.
      #
      # @return [OGR::Point]
      def point_on_surface
        build_geometry { |ptr| FFI::OGR::API.OGR_G_PointOnSurface(ptr) }
      end
    end
  end
end
