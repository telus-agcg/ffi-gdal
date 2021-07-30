# frozen_string_literal: true

require_relative 'geometry_types/container'
require_relative 'geometry/interfaces/xy_points'

module OGR
  class MultiPoint < OGR::Geometry
    include OGR::GeometryTypes::Container
    include OGR::Geometry::Interfaces::XYPoints
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbMultiPoint
  end
end
