# frozen_string_literal: true

require_relative 'geometry_types/container'

module OGR
  class GeometryCollection < OGR::Geometry
    include OGR::GeometryTypes::Container
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbGeometryCollection

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
