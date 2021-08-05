# frozen_string_literal: true

require_relative 'geometry/not_a_geometry_collection'

module OGR
  class MultiPoint < OGR::GeometryCollection
    include GDAL::Logger
    include OGR::Geometry::NotAGeometryCollection

    GEOMETRY_TYPE = :wkbMultiPoint

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end
