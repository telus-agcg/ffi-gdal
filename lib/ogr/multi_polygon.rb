require_relative 'geometry_types/collection'
require_relative 'geometry_types/surface'

module OGR
  class MultiPolygon < Geometry
    include GeometryTypes::Collection
    include GeometryTypes::Surface

    # @return [OGR::Geometry]
    def union_cascaded
      build_geometry { |ptr| FFI::GDAL.OGR_G_UnionCascaded(ptr) }
    end
  end
end
