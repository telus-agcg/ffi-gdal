require_relative '../ffi/ogr'
require_relative 'envelope_extensions'

module OGR
  class Envelope
    include EnvelopeExtensions
    
    def initialize(ogr_envelope_struct)
      @ogr_envelope_struct = ogr_envelope_struct
    end

    # @return [Float]
    def min_x
      @ogr_envelope_struct[:min_x]
    end

    # @param new_x_min [Float]
    def min_x=(new_x_min)
      @ogr_envelope_struct[:min_x] = new_x_min
    end

    # @return [Float]
    def max_x
      @ogr_envelope_struct[:max_x]
    end

    # @param new_x_max [Float]
    def max_x=(new_x_max)
      @ogr_envelope_struct[:max_x] = new_x_max
    end

    # @return [Float]
    def min_y
      @ogr_envelope_struct[:min_y]
    end

    # @param new_y_min [Float]
    def min_y=(new_y_min)
      @ogr_envelope_struct[:min_y] = new_y_min
    end

    # @return [Float]
    def max_y
      @ogr_envelope_struct[:max_y]
    end

    # @param new_y_max [Float]
    def max_y=(new_y_max)
      @ogr_envelope_struct[:max_y] = new_y_max
    end

    # @return [Float, nil]
    def min_z
      return nil unless @ogr_envelope_struct.is_a? FFI::GDAL::OGREnvelope3D

      @ogr_envelope_struct[:min_z]
    end

    # @param new_z_min [Float]
    def min_z=(new_z_min)
      return nil unless @ogr_envelope_struct.is_a? FFI::GDAL::OGREnvelope3D

      @ogr_envelope_struct[:min_z] = new_z_min
    end

    # @return [Float, nil]
    def max_z
      return nil unless @ogr_envelope_struct.is_a? FFI::GDAL::OGREnvelope3D

      @ogr_envelope_struct[:max_z]
    end

    # @param new_z_max [Float]
    def max_z=(new_z_max)
      return nil unless @ogr_envelope_struct.is_a? FFI::GDAL::OGREnvelope3D

      @ogr_envelope_struct[:max_z] = new_z_max
    end
  end
end
