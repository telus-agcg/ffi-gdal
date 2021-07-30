# frozen_string_literal: true

require_relative 'geometry_types/container'
require_relative 'geometry/interfaces/xy_points'
require_relative 'geometry/interfaces/length'

module OGR
  class MultiLineString < OGR::Geometry
    include OGR::GeometryTypes::Container
    include OGR::Geometry::Interfaces::XYPoints
    include OGR::Geometry::Interfaces::Length
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbMultiLineString

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
