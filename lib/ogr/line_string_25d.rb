# frozen_string_literal: true

require_relative 'line_string'
require_relative 'geometry/interfaces/xyz_points'

module OGR
  # NOTE: {{#type}} will return :wkbLineString (read: 2D instead of 2.5D) until
  # a Z value is set.
  class LineString25D < LineString
    include OGR::Geometry::Interfaces::XYZPoints
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbLineString25D

    # Wrapper for {#add_point} to allow passing in an {OGR::Point} instead of
    # individual coordinates.
    #
    # @param point [OGR::Point]
    def add_geometry(point)
      add_point(point.x, point.y, point.z)
    end
  end
end
