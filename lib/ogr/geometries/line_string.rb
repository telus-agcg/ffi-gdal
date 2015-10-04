require_relative '../geometry_types/curve'

module OGR
  class LineString
    include OGR::Geometry
    include GeometryTypes::Curve

    def self.approximate_arc_angles(center_x, center_y,
                                    z,
                                    primary_radius, secondary_radius,
                                    rotation,
                                    start_angle, end_angle,
                                    max_angle_step_size_degrees = 0)
      geometry_ptr = FFI::GDAL.OGR_G_ApproximateArcAngles(
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

    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbLineString)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end
    end
  end
end
