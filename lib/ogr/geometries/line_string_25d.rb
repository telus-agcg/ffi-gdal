# frozen_string_literal: true

require_relative 'line_string'
require_relative '../geometry/interfaces/xyz_points'

module OGR
  # NOTE: {{#type}} will return :wkbLineString (read: 2D instead of 2.5D) until
  # a Z value is set.
  class LineString25D < LineString
    include OGR::Geometry::Interfaces::XYZPoints

    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbLineString25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end
  end
end
