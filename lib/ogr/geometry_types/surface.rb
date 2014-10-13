module OGR
  module GeometryTypes
    module Surface

      # Computes area for a LinearRing, Polygon, or MultiPolygon.
      #
      # @param geometry [OGR::Geometry, FFI::Pointer]
      # @return [Float] 0.0 for unsupported geometry types.
      def area
        FFI::GDAL.OGR_G_Area(@geometry_pointer)
      end

      # Not supported.
      #
      # @return nil
      # def points
      #   nil
      # end
    end
  end
end
