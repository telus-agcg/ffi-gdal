# frozen_string_literal: true

module OGR
  class UnknownGeometry
    include OGR::Geometry

    # @param geometry_ptr [FFI::Pointer]
    def initialize(geometry_ptr)
      OGR::Geometry.new_from_pointer(geometry_ptr)
    end
  end
end
