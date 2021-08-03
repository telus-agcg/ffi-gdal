# frozen_string_literal: true

require_relative 'geometry/container'

module OGR
  # Per [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries):
  #
  # a sequence of connected curves, either line strings or circular strings
  #
  class CompoundCurve < OGR::Curve
    include GDAL::Logger
    include OGR::Geometry::Container

    GEOMETRY_TYPE = :wkbCompoundCurve

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference: spatial_reference)
    end
  end
end
