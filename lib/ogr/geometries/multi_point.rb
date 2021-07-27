# frozen_string_literal: true

require_relative '../geometry_types/container'
require_relative '../geometry/interfaces/xy_points'

module OGR
  class MultiPoint
    include OGR::Geometry
    include GeometryTypes::Container
    include OGR::Geometry::Interfaces::XYPoints

    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiPoint)
      initialize_from_pointer(geometry_ptr)
      self.spatial_reference = spatial_reference if spatial_reference
    end
  end
end
