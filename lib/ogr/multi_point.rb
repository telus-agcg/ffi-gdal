# frozen_string_literal: true

module OGR
  class MultiPoint < OGR::GeometryCollection
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbMultiPoint

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end
