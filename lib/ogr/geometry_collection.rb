# frozen_string_literal: true

require_relative 'geometry/container'
require_relative 'geometry/polygon_from_edges'
require_relative 'geometry/has_two_coordinate_dimensions'

module OGR
  class GeometryCollection < OGR::Geometry
    include GDAL::Logger
    include OGR::Geometry::Container
    include OGR::Geometry::PolygonFromEdges
    include OGR::Geometry::HasTwoCoordinateDimensions

    GEOMETRY_TYPE = :wkbGeometryCollection

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
