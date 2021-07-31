# frozen_string_literal: true

module OGR
  # See [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries).
  #
  class Surface < OGR::Geometry
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbSurface

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
