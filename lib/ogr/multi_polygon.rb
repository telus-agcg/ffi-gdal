# frozen_string_literal: true

require_relative 'geometry/surface_methods'

module OGR
  class MultiPolygon < OGR::MultiSurface
    include GDAL::Logger
    include OGR::Geometry::SurfaceMethods

    GEOMETRY_TYPE = :wkbMultiPolygon

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end
