# frozen_string_literal: true

require_relative 'multi_point'
require_relative 'geometry/has_three_coordinate_dimensions'

module OGR
  class MultiPoint25D < MultiPoint
    include GDAL::Logger
    include OGR::Geometry::HasThreeCoordinateDimensions

    GEOMETRY_TYPE = :wkbMultiPoint25D

    def initialize(c_pointer: nil, spatial_reference: nil)
      c_pointer ||= OGR::Geometry.create(GEOMETRY_TYPE).tap do |ptr|
        # Without this, the internal type won't reflect the 2.5D-ness if the
        # geometry is empty:
        FFI::OGR::API.OGR_G_SetCoordinateDimension(ptr, 3)
      end

      super(c_pointer: c_pointer, spatial_reference: spatial_reference)
    end
  end
end
