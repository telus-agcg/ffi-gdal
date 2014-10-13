require_relative 'geometry_types/curve'
require_relative 'geometry_types/collection'

module OGR
  class MultiLineString < Geometry
    include GeometryTypes::Collection
    include GeometryTypes::Curve
  end
end
