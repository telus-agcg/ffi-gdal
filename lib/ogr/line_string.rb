require_relative 'geometry_types/curve'

module OGR
  class LineString < Geometry
    include GeometryTypes::Curve
  end
end
