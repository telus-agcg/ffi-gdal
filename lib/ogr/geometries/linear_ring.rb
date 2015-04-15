require_relative 'line_string'

module OGR
  class LinearRing < LineString
    # @param [FFI::Pointer] geometry_ptr
    def initialize(geometry_ptr = nil)
      geometry_ptr ||= OGR::Geometry.create(:wkbLinearRing)
      initialize_from_pointer(geometry_ptr)
    end
  end
end
