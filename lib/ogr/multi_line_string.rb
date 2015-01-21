require_relative 'geometry'
require_relative 'geometry_types/curve'
require_relative 'geometry_types/collection'

module OGR
  class MultiLineString
    include Geometry
    include GeometryTypes::Curve
    include GeometryTypes::Collection

    def initialize(geometry_ptr=nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiLineString)
      initialize_from_pointer(geometry_ptr)
    end
  end
end
