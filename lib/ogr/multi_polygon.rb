# frozen_string_literal: true

require_relative 'geometry/area'
require_relative 'geometry/container'

module OGR
  class MultiPolygon < OGR::Geometry
    include GDAL::Logger
    include OGR::Geometry::Area
    include OGR::Geometry::Container

    GEOMETRY_TYPE = :wkbMultiPolygon

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end

    # @return [OGR::Geometry]
    def union_cascaded
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_UnionCascaded(@c_pointer) }
    end
  end
end
