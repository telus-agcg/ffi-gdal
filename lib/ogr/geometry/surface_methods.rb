# frozen_string_literal: true

module OGR
  module Geometry
    # Methods used for getting the area of a geometry.
    #
    module SurfaceMethods
      # Computes area for a LinearRing, Polygon, or MultiPolygon.  The area of
      # the feature is in square units of the spatial reference system in use.
      #
      # @return [Float] 0.0 for unsupported geometry types.
      def area
        FFI::OGR::API.OGR_G_Area(@c_pointer)
      end

      # Returns the units used by the associated OGR::SpatialReference.
      #
      # @return [{ unit_name: String, value: Float }, nil]
      def area_units
        spatial_reference ? spatial_reference.linear_units : nil
      end

      # Returns a point that's guaranteed to lie on the surface.
      #
      # @return [OGR::Point, OGR::Point25D]
      # @raise [OGR::Failure]
      def point_on_surface
        point_ptr = FFI::OGR::API.OGR_G_PointOnSurface(@c_pointer)

        raise OGR::Failure, 'Error fetching point on surface' if point_ptr.null?

        case (geom_type = FFI::OGR::API.OGR_G_GetGeometryType(point_ptr))
        when OGR::Point::GEOMETRY_TYPE then OGR::Point.new(c_pointer: point_ptr)
        when OGR::Point25D::GEOMETRY_TYPE then OGR::Point25D.new(c_pointer: point_ptr)
        else
          raise OGR::InvalidGeometry,
                "Expected #{OGR::Point::GEOMETRY_TYPE} or #{OGR::Point25D::GEOMETRY_TYPE}, got #{geom_type}"
        end
      end
    end
  end
end
