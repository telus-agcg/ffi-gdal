# frozen_string_literal: true

require_relative 'geometry/polygon_from_edges'

module OGR
  class MultiLineString < OGR::MultiCurve
    include GDAL::Logger
    include OGR::Geometry::PolygonFromEdges

    GEOMETRY_TYPE = :wkbMultiLineString

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end

    # Creates a polygon from a set of sparse edges.  The newly created geometry
    # will contain a collection of reassembled Polygons.
    #
    # @return [OGR::Geometry] nil if the current geometry isn't a
    #   MultiLineString or if it's impossible to reassemble due to topological
    #   inconsistencies.
    def polygonize
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_Polygonize(@c_pointer) }
    end
  end
end
