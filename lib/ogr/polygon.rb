require_relative 'geometry_types/surface'

module OGR
  class Polygon
    include Geometry
    include GeometryTypes::Surface

    def initialize(geometry_ptr=nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbPolygon)
      initialize_from_pointer(geometry_ptr)
    end
  end
end
