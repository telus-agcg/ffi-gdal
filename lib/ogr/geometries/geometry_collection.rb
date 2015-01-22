require_relative '../geometry_types/collection'

module OGR
  class GeometryCollection
    include OGR::Geometry
    include GeometryTypes::Collection

    def initialize(geometry_ptr=nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbGeometryCollection)
      initialize_from_pointer(geometry_ptr)
    end
  end
end