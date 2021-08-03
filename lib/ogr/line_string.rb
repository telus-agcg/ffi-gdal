# frozen_string_literal: true

require_relative 'geometry/simple_curve'

module OGR
  class LineString < OGR::Curve
    include GDAL::Logger
    include OGR::Geometry::SimpleCurve

    GEOMETRY_TYPE = :wkbLineString

    def self.approximate_arc_angles(center_x, center_y, z, primary_radius, secondary_radius,
      rotation, start_angle, end_angle, max_angle_step_size_degrees = 0)
      geometry_ptr = FFI::GDAL::GDAL.OGR_G_ApproximateArcAngles(
        center_x,
        center_y,
        z,
        primary_radius,
        secondary_radius,
        rotation,
        start_angle,
        end_angle,
        max_angle_step_size_degrees
      )
      return nil if geometry_ptr.null?

      new(geometry_ptr)
    end

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference: spatial_reference)
    end

    # Wrapper for {#add_point} to allow passing in an {OGR::Point} instead of
    # individual coordinates.
    #
    # @param point [OGR::Point]
    def add_geometry(point)
      add_point(point.x, point.y)
    end
  end
end
