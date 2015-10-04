require_relative 'multi_polygon'

module OGR
  class MultiPolygon25D < MultiPolygon
    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiPolygon25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end
  end
end
