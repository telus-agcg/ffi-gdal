# frozen_string_literal: true

require_relative 'geometry_types/container'

module OGR
  # Per [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries):
  #
  # a circular arc, or a sequence of connected circular arcs, each of them
  # describe by 3 points: the first point of the arc, an intermediate point and
  # the final point.
  #
  class CircularString < OGR::Geometry
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbCircularString

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
