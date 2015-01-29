module OGR
  class UnknownGeometry
    include OGR::Geometry

    def initialize(geometry_ptr = nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbUnknown)
      initialize_from_pointer(geometry_ptr)
    end
  end
end
