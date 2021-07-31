# frozen_string_literal: true

require_relative 'multi_point'
require_relative 'geometry/xyz_points'

module OGR
  # NOTE: {{#type}} will return :wkbMultiPoint (read: 2D instead of 2.5D) until
  # a Z value is set.
  class MultiPoint25D < MultiPoint
    include GDAL::Logger
    include OGR::Geometry::XYZPoints

    GEOMETRY_TYPE = :wkbMultiPoint25D

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end