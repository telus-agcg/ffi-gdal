# frozen_string_literal: true

require_relative 'line_string'
require_relative 'geometry/simple_curve_25d'
require_relative 'geometry/has_three_coordinate_dimensions'

module OGR
  # NOTE: {{#type}} will return :wkbLineString (read: 2D instead of 2.5D) until
  # a Z value is set.
  class LineString25D < LineString
    include GDAL::Logger
    include OGR::Geometry::SimpleCurve25D
    include OGR::Geometry::HasThreeCoordinateDimensions

    GEOMETRY_TYPE = :wkbLineString25D

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE).tap do |ptr|
        # Without this, the internal type won't reflect the 2.5D-ness if the
        # geometry is empty:
        FFI::OGR::API.OGR_G_SetCoordinateDimension(ptr, 3)
      end

      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end

    # Wrapper for {#add_point} to allow passing in an {OGR::Point} instead of
    # individual coordinates.
    #
    # @param point [OGR::Point]
    def add_geometry(point)
      add_point(point.x, point.y, point.z)
    end
  end
end
