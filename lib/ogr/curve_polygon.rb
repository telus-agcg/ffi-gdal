# frozen_string_literal: true

require_relative 'geometry/container'

module OGR
  # Per [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries):
  #
  # polygon consisting of one outer ring, and zero or more inner ring. Each
  # ring can be one of the curve implementations: line strings, circular
  # strings, compound curves.
  #
  class CurvePolygon < OGR::Geometry
    include GDAL::Logger
    include OGR::Geometry::Container

    GEOMETRY_TYPE = :wkbCurvePolygon

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
