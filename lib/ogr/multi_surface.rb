# frozen_string_literal: true

require_relative 'geometry/surface_methods'

module OGR
  # Per [RFC 49: Curve geometries](https://trac.osgeo.org/gdal/wiki/rfc49_curve_geometries):
  #
  # a collection of surfaces (polygons, curve polygons)
  #
  class MultiSurface < OGR::GeometryCollection
    include GDAL::Logger
    include OGR::Geometry::SurfaceMethods

    GEOMETRY_TYPE = :wkbMultiSurface

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end

    # @return [OGR::Geometry]
    def union_cascaded
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_UnionCascaded(@c_pointer) }
    end
  end
end
