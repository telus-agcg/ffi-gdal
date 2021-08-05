# frozen_string_literal: true

require_relative 'geometry/container'
require_relative 'geometry/surface_methods'

module OGR
  class Polygon < OGR::CurvePolygon
    include GDAL::Logger
    include OGR::Geometry::SurfaceMethods

    GEOMETRY_TYPE = :wkbPolygon

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end
