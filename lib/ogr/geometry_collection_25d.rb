# frozen_string_literal: true

require_relative 'geometry_collection'

module OGR
  # NOTE: {{#type}} will return :wkbGeometryCollection (read: 2D instead of
  # 2.5D) until a Z value is set.
  class GeometryCollection25D < GeometryCollection
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbGeometryCollection25D

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end
