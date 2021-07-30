# frozen_string_literal: true

require_relative 'geometry_types/container'
require_relative 'geometry/interfaces/area'

module OGR
  class Polygon < OGR::Geometry
    include OGR::GeometryTypes::Container
    include OGR::Geometry::Interfaces::Area
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbPolygon

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
