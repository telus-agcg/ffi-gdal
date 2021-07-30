# frozen_string_literal: true

require_relative 'geometry_types/container'

module OGR
  class GeometryCollection < OGR::Geometry
    include OGR::GeometryTypes::Container
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbGeometryCollection
  end
end
