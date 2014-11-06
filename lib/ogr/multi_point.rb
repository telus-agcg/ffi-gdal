require_relative 'geometry_types/collection'

module OGR
  class MultiPoint < Geometry
    include GeometryTypes::Collection
  end
end
