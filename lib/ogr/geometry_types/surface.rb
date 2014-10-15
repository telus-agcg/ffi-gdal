module OGR
  module GeometryTypes
    module Surface

      # Computes area for a LinearRing, Polygon, or MultiPolygon.
      #
      # @return [Float] 0.0 for unsupported geometry types.
      def area
        FFI::GDAL.OGR_G_Area(@geometry_pointer)
      end

      # Returns a point that's guaranteed to lie on the surface.
      #
      # @return [OGR::Point]
      def point_on_surface
        build_geometry { |ptr| FFI::GDAL.OGR_G_PointOnSurface(ptr) }
      end
    end
  end
end
