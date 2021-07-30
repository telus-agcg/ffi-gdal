# frozen_string_literal: true

require_relative 'geometry/container'
require_relative 'geometry/xy_points'

module OGR
  class MultiPoint < OGR::Geometry
    include GDAL::Logger
    include OGR::Geometry::Container
    include OGR::Geometry::XYPoints

    GEOMETRY_TYPE = :wkbMultiPoint

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE)
      super(c_pointer, spatial_reference)
    end
  end
end
