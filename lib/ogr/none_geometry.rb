require_relative 'geometry'

module OGR
  class NoneGeometry
    include OGR::Geometry

    def initialize(geometry_ptr=nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbNone)
      initialize_from_pointer(geometry_ptr)
    end
  end
end