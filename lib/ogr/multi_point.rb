# frozen_string_literal: true

require_relative 'geometry_types/container'
require_relative 'geometry/interfaces/xy_points'

module OGR
  class MultiPoint < OGR::Geometry
    include OGR::GeometryTypes::Container
    include OGR::Geometry::Interfaces::XYPoints
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbMultiPoint

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
