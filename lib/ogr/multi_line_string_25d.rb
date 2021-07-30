# frozen_string_literal: true

require_relative 'multi_line_string'
require_relative 'geometry/interfaces/xyz_points'

module OGR
  # NOTE: {{#type}} will return :wkbMultiLineString (read: 2D instead of 2.5D)
  # until a Z value is set.
  class MultiLineString25D < MultiLineString
    include OGR::Geometry::Interfaces::XYZPoints
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbLineString25D
  end
end
