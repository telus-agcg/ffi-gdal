# frozen_string_literal: true

require_relative 'geometry/geometry_methods'
require_relative 'geometry/container'
require_relative 'geometry/polygon_from_edges'
require_relative 'geometry/has_two_coordinate_dimensions'

module OGR
  class GeometryCollection
    include GDAL::Logger
    include OGR::Geometry::GeometryMethods
    include OGR::Geometry::Container
    include OGR::Geometry::PolygonFromEdges
    include OGR::Geometry::HasTwoCoordinateDimensions

    GEOMETRY_TYPE = :wkbGeometryCollection

    attr_reader :c_pointer

    def initialize(c_pointer: nil, spatial_reference: nil)
      @c_pointer = c_pointer || OGR::Geometry.create(GEOMETRY_TYPE)
      self.spatial_reference = spatial_reference if spatial_reference
    end
  end
end
