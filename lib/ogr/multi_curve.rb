# frozen_string_literal: true

require_relative 'geometry/length'
require_relative 'geometry/not_a_geometry_collection'

module OGR
  # Per [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries):
  #
  # a collection of curves (line strings, circular strings, compound curves)
  #
  class MultiCurve < OGR::GeometryCollection
    include GDAL::Logger
    include OGR::Geometry::Length
    include OGR::Geometry::NotAGeometryCollection

    GEOMETRY_TYPE = :wkbMultiCurve

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end
