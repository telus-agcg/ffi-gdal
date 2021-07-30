# frozen_string_literal: true

module OGR
  class Geometry
    module Interfaces
      module Length
        # Computes the length for this geometry.  Computes area for Curve or
        # MultiCurve objects.
        #
        # @return [Float] 0.0 for unsupported geometry types.
        def length
          FFI::OGR::API.OGR_G_Length(@c_pointer)
        end
      end
    end
  end
end
