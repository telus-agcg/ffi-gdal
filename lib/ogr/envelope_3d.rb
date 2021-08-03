# frozen_string_literal: true

require_relative 'envelope'

module OGR
  class Envelope3D < Envelope
    # @return [FFI::OGR::Envelope3D] The C struct that this object wraps.
    attr_reader :c_struct

    # @param envelope_struct [FFI::OGR::Envelope3D]
    def initialize(envelope_struct = nil)
      super(envelope_struct || FFI::OGR::Envelope3D.new)
    end

    # @return [Float, nil]
    def z_min
      return nil unless @c_struct.is_a? FFI::OGR::Envelope3D

      @c_struct[:min_z]
    end

    # @param new_z_min [Float]
    def z_min=(new_z_min)
      return unless @c_struct.is_a? FFI::OGR::Envelope3D

      @c_struct[:min_z] = new_z_min
    end

    # @return [Float, nil]
    def z_max
      return nil unless @c_struct.is_a? FFI::OGR::Envelope3D

      @c_struct[:max_z]
    end

    # @param new_z_max [Float]
    def z_max=(new_z_max)
      return unless @c_struct.is_a? FFI::OGR::Envelope3D

      @c_struct[:max_z] = new_z_max
    end
  end
end
