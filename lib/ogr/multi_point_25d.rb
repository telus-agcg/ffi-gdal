# frozen_string_literal: true

require_relative 'multi_point'
require_relative 'geometry/interfaces/xyz_points'

module OGR
  # NOTE: {{#type}} will return :wkbMultiPoint (read: 2D instead of 2.5D) until
  # a Z value is set.
  class MultiPoint25D < MultiPoint
    include OGR::Geometry::Interfaces::XYZPoints
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbMultiPoint25D
  end
end
