require_relative '../ffi/ogr'

module OGR
  class Envelope
    include FFI::GDAL

    def initialize(ogr_envelope_struct)
      @ogr_envelope_struct = ogr_envelope_struct
    end

    def min_x
      @ogr_envelope_struct[:min_x]
    end

    def max_x
      @ogr_envelope_struct[:max_x]
    end

    def min_y
      @ogr_envelope_struct[:min_y]
    end

    def max_y
      @ogr_envelope_struct[:max_y]
    end

    def min_z
      return nil unless @ogr_envelope_struct.is_a? FFI::GDAL::OGREnvelope3D

      @ogr_envelope_struct[:min_z]
    end

    def max_z
      return nil unless @ogr_envelope_struct.is_a? FFI::GDAL::OGREnvelope3D
      
      @ogr_envelope_struct[:max_z]
    end
  end
end
