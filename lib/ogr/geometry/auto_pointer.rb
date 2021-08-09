# frozen_string_literal: true

require 'ffi'

module OGR
  module Geometry
    class AutoPointer < ::FFI::AutoPointer
      def self.release(c_pointer)
        return if c_pointer.nil? || c_pointer.null?

        FFI::OGR::API.OGR_G_DestroyGeometry(c_pointer)
      end
    end
  end
end
