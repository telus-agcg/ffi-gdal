require_relative 'geometry_types/surface'
require_relative 'geometry_types/collection'

module OGR
  class Polygon < Geometry
    include GeometryTypes::Surface
    include GeometryTypes::Collection
  end
end
