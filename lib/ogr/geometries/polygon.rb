require_relative '../geometry_types/surface'

module OGR
  class Polygon
    include OGR::Geometry
    include GeometryTypes::Surface

    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbPolygon)
      initialize_from_pointer(geometry_ptr)
    end
  end
end
