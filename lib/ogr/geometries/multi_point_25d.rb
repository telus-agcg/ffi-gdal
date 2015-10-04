require_relative 'multi_point'

module OGR
  class MultiPoint25D < MultiPoint
    # @param geometry_ptr [FFI::Pointer]
    # @param spatial_reference [OGR::SpatialReference]
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiPoint25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end
  end
end
