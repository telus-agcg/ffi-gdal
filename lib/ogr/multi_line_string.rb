# frozen_string_literal: true

require_relative 'geometry/polygon_from_edges'

module OGR
  class MultiLineString < OGR::MultiCurve
    include GDAL::Logger
    include OGR::Geometry::PolygonFromEdges

    GEOMETRY_TYPE = :wkbMultiLineString

    class << self
      private

      # @param c_pointer [FFI::Pointer]
      # @return [[FFI::Pointer, FFI::OGR::Core::WKBGeometryType]]
      def polygonize(c_pointer)
        polygon_ptr = FFI::OGR::API.OGR_G_Polygonize(c_pointer)

        raise OGR::Failure, 'Error polygonizing MultiLineString' if polygon_ptr.null?

        [polygon_ptr, FFI::OGR::API.OGR_G_GetGeometryType(polygon_ptr)]
      end
    end

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end

    # Creates a polygon from a set of sparse edges. The newly created geometry
    # will contain a collection of reassembled Polygons.
    #
    # @return [OGR::Polygon, OGR::Polygon25D, OGR::MultiPolygon, OGR::MultiPolygon25D,
    #   OGR::GeometryCollection, OGR::GeometryCollection25D]
    # @raise [OGR::InvalidGeometry] if it's impossible to reassemble due to
    #   topological inconsistencies.
    def polygonize
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_Polygonize(@c_pointer) }
    end
  end
end
