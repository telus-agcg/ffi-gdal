require_relative '../geometry_types/container'

module OGR
  class MultiPoint
    include OGR::Geometry
    include GeometryTypes::Container

    def initialize(geometry_ptr=nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiPoint)
      initialize_from_pointer(geometry_ptr)
    end
  end
end
