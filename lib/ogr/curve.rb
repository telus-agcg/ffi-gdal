# frozen_string_literal: true

require_relative 'geometry/geometry_methods'
require_relative 'geometry/has_two_coordinate_dimensions'
require_relative 'geometry/length'

module OGR
  # See [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries)
  # for more info on the introduction of this type to GDAL.
  #
  # See [Proposed change regarding wkbCurve, wkbSurface and their M/Z/ZM variants ](https://gdal-dev.osgeo.narkive.com/pPDeAu1o/proposed-change-regarding-wkbcurve-wkbsurface-and-their-m-z-zm-variants)
  # for more info about how this type is only instantiable using the `GeoPackage`
  # driver.
  #
  class Curve
    include GDAL::Logger
    include OGR::Geometry::GeometryMethods
    include OGR::Geometry::Length
    include OGR::Geometry::HasTwoCoordinateDimensions

    GEOMETRY_TYPE = :wkbCurve

    attr_reader :c_pointer

    def initialize(c_pointer, spatial_reference: nil)
      @c_pointer = c_pointer
      self.spatial_reference = spatial_reference if spatial_reference
    end
  end
end
