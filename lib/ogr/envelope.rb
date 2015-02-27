require_relative '../ffi/ogr'
require_relative 'envelope_extensions'

module OGR
  class Envelope
    include EnvelopeExtensions

    # @param envelope_struct [FFI::OGR::Envelope]
    def initialize(envelope_struct = nil, three_d: false)
      @ogr_envelope_struct = envelope_struct
      @ogr_envelope_struct ||= three_d ? FFI::OGR::Envelope3D.new : FFI::OGR::Envelope.new
    end

    def c_struct
      @ogr_envelope_struct
    end

    def c_pointer
      @ogr_envelope_struct.to_ptr
    end

    # @return [Float]
    def x_min
      @ogr_envelope_struct[:min_x]
    end

    # @param new_x_min [Float]
    def x_min=(new_x_min)
      @ogr_envelope_struct[:min_x] = new_x_min
    end

    # @return [Float]
    def x_max
      @ogr_envelope_struct[:max_x]
    end

    # @param new_x_max [Float]
    def x_max=(new_x_max)
      @ogr_envelope_struct[:max_x] = new_x_max
    end

    # @return [Float]
    def y_min
      @ogr_envelope_struct[:min_y]
    end

    # @param new_y_min [Float]
    def y_min=(new_y_min)
      @ogr_envelope_struct[:min_y] = new_y_min
    end

    # @return [Float]
    def y_max
      @ogr_envelope_struct[:max_y]
    end

    # @param new_y_max [Float]
    def y_max=(new_y_max)
      @ogr_envelope_struct[:max_y] = new_y_max
    end

    # @return [Float, nil]
    def z_min
      return nil unless @ogr_envelope_struct.is_a? FFI::OGR::Envelope3D

      @ogr_envelope_struct[:min_z]
    end

    # @param new_z_min [Float]
    def z_min=(new_z_min)
      return nil unless @ogr_envelope_struct.is_a? FFI::OGR::Envelope3D

      @ogr_envelope_struct[:min_z] = new_z_min
    end

    # @return [Float, nil]
    def z_max
      return nil unless @ogr_envelope_struct.is_a? FFI::OGR::Envelope3D

      @ogr_envelope_struct[:max_z]
    end

    # @param new_z_max [Float]
    def z_max=(new_z_max)
      return nil unless @ogr_envelope_struct.is_a? FFI::OGR::Envelope3D

      @ogr_envelope_struct[:max_z] = new_z_max
    end
  end
end
