# frozen_string_literal: true

require_relative 'line_string'
require_relative 'geometry/xyz_points'

module OGR
  # NOTE: {{#type}} will return :wkbLineString (read: 2D instead of 2.5D) until
  # a Z value is set.
  class LineString25D < LineString
    include GDAL::Logger
    include OGR::Geometry::XYZPoints

    GEOMETRY_TYPE = :wkbLineString25D

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
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
