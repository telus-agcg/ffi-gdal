# frozen_string_literal: true

require_relative '../geometry_types/container'
require_relative '../geometry/interfaces/xy_points'
require_relative '../geometry/interfaces/length'

module OGR
  class MultiLineString
    include OGR::Geometry
    include GeometryTypes::Container
    include OGR::Geometry::Interfaces::XYPoints
    include OGR::Geometry::Interfaces::Length

    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiLineString)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end
  end
end
