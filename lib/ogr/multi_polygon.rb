# frozen_string_literal: true

require_relative 'geometry_types/container'

module OGR
  class MultiPolygon < OGR::Geometry
    include OGR::GeometryTypes::Container
    include OGR::Geometry::Interfaces::Area
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbMultiPolygon

    # @return [OGR::Geometry]
    def union_cascaded
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_UnionCascaded(@c_pointer) }
    end
  end
end
