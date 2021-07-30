# frozen_string_literal: true

require_relative 'geometry_types/container'

module OGR
  # Per [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries):
  #
  # a sequence of connected curves, either line strings or circular strings
  #
  class CompoundCurve < OGR::Geometry
    include GDAL::Logger
    include OGR::GeometryTypes::Container

    GEOMETRY_TYPE = :wkbCompoundCurve

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
