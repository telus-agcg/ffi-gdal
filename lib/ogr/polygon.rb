# frozen_string_literal: true

require_relative 'geometry/container'
require_relative 'geometry/area'

module OGR
  class Polygon < OGR::Geometry
    include GDAL::Logger
    include OGR::Geometry::Container
    include OGR::Geometry::Area

    GEOMETRY_TYPE = :wkbPolygon

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
