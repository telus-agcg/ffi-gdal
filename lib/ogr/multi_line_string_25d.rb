# frozen_string_literal: true

require_relative 'multi_line_string'
require_relative 'geometry/interfaces/xyz_points'

module OGR
  # NOTE: {{#type}} will return :wkbMultiLineString (read: 2D instead of 2.5D)
  # until a Z value is set.
  class MultiLineString25D < MultiLineString
    include OGR::Geometry::Interfaces::XYZPoints
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbMultiLineString25D

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end
