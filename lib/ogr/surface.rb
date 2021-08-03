# frozen_string_literal: true

require_relative 'geometry/surface_methods'
require_relative 'geometry/has_two_coordinate_dimensions'

module OGR
  # See [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries)
  # for more info on the introduction of this type to GDAL.
  #
  # See [Proposed change regarding wkbCurve, wkbSurface and their M/Z/ZM variants ](https://gdal-dev.osgeo.narkive.com/pPDeAu1o/proposed-change-regarding-wkbcurve-wkbsurface-and-their-m-z-zm-variants)
  # for more info about how this type is only instantiable using the `GeoPackage`
  # driver.
  #
  class Surface < OGR::Geometry
    include GDAL::Logger
    include OGR::Geometry::SurfaceMethods
    include OGR::Geometry::HasTwoCoordinateDimensions

    GEOMETRY_TYPE = :wkbSurface

    def initialize(c_pointer, spatial_reference: nil)
      super(c_pointer, spatial_reference)
    end
  end
end
