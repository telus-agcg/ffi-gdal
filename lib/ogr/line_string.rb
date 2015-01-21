require_relative 'geometry'
require_relative 'geometry_types/curve'

module OGR
  # A LineString is a type of Curve Geometry.
  class LineString
    include Geometry
    include GeometryTypes::Curve
    def initialize(geometry_ptr=nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbLineString)
      initialize_from_pointer(geometry_ptr)
    end
  end
end
