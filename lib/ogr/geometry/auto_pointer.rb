# frozen_string_literal: true

module OGR
  module Geometry
    class AutoPointer < ::FFI::AutoPointer
      def self.release(c_pointer)
        FFI::OGR::API.OGR_G_DestroyGeometry(c_pointer)
      end
    end
  end
end
