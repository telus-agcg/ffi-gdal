require_relative '../geometry_types/curve'
require_relative '../geometry_types/container'

module OGR
  class MultiLineString
    include OGR::Geometry
    include GeometryTypes::Curve
    include GeometryTypes::Container

    def initialize(geometry_ptr = nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiLineString)
      initialize_from_pointer(geometry_ptr)
    end
  end
end
