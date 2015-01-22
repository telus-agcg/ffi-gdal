require_relative 'geometry'
require_relative 'geometry_types/collection'
require_relative 'geometry_types/surface'

module OGR
  class MultiPolygon
    include Geometry
    include GeometryTypes::Collection
    include GeometryTypes::Surface

    def initialize(geometry_ptr=nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiPolygon)
      initialize_from_pointer(geometry_ptr)
    end

    # @return [OGR::Geometry]
    def union_cascaded
      build_geometry { |ptr| FFI::GDAL.OGR_G_UnionCascaded(ptr) }
    end
  end
end
