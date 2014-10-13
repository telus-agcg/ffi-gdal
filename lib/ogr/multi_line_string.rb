require_relative 'geometry_types/curve'
require_relative 'geometry_types/collection'

module OGR
  class MultiLineString < Geometry
    include GeometryTypes::Curve
    include GeometryTypes::Collection
  end
end
