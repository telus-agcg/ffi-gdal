# frozen_string_literal: true

require_relative 'geometry/container'
require_relative 'geometry/xy_points'
require_relative 'geometry/length'
require_relative 'geometry/polygon_from_edges'

module OGR
  class MultiLineString < OGR::MultiCurve
    include GDAL::Logger
    include OGR::Geometry::Container
    include OGR::Geometry::XYPoints
    include OGR::Geometry::Length
    include OGR::Geometry::PolygonFromEdges

    GEOMETRY_TYPE = :wkbMultiLineString

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end
