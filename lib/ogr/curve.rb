# frozen_string_literal: true

require_relative 'geometry/length'
require_relative 'geometry/xy_points'

module OGR
  # See [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries).
  #
  class Curve < OGR::Geometry
    include GDAL::Logger
    include OGR::Geometry::Length
    include OGR::Geometry::XYPoints

    GEOMETRY_TYPE = :wkbCurve

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
