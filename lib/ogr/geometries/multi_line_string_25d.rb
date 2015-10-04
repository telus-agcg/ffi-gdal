require_relative 'multi_line_string'

module OGR
  class MultiLineString25D < MultiLineString
    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil, spatial_reference: nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbMultiLineString25D)
      super(geometry_ptr, spatial_reference: spatial_reference)
    end
  end
end
