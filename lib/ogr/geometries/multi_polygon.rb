require_relative '../geometry_types/container'
require_relative '../geometry_types/surface'

module OGR
  class MultiPolygon
    include OGR::Geometry
    include GeometryTypes::Container
    include GeometryTypes::Surface

    def initialize(geometry_ptr = nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiPolygon)
      initialize_from_pointer(geometry_ptr)
    end

    # @return [OGR::Geometry]
    def union_cascaded
      build_geometry { |ptr| FFI::OGR::API.OGR_G_UnionCascaded(ptr) }
    end
  end
end
