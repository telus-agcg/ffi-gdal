require_relative '../ffi/ogr'

module OGR
  class Envelope
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

    # Adapted from "Advanced Geospatial Python Modeling".  Calculates the
    # pixel locations of these geospatial coordinates.
    #
    # @param geo_transform [GDAL::GeoTransform]
    # @param value_type [Symbol] Data type to return: :float or :integer.
    # @return [Hash<x_origin, y_origin, x_max, y_max>]
    def world_to_pixel(geo_transform, value_type=:integer)
      min_values = geo_transform.world_to_pixel(min_x, max_y)
      max_values = geo_transform.world_to_pixel(max_x, min_y)
      pixel_count = max_values[:x] - min_values[:x]
      line_count = max_values[:y] - min_values[:y]
      pixel_width = (max_x - min_x) / pixel_count
      pixel_height = (max_y - min_y) / pixel_count

      case value_type
      when :float
        {
          x_origin: min_values[:x].to_f,
          y_origin: min_values[:y].to_f,
          x_max: max_values[:x].to_f,
          y_max: max_values[:y].to_f,
          pixel_count: pixel_count.to_i.abs,
          line_count: line_count.to_i.abs,
          pixel_width: pixel_width.to_f,
          pixel_height: pixel_height.to_f
        }
      when :integer
        {
          x_origin: min_values[:x].to_i,
          y_origin: min_values[:y].to_i,
          x_max: max_values[:x].to_i,
          y_max: max_values[:y].to_i,
          pixel_count: pixel_count.to_i.abs,
          line_count: line_count.to_i.abs,
          pixel_width: pixel_width.to_f,
          pixel_height: pixel_height.to_f
        }
      else
        {
          x_origin: min_values[:x],
          y_origin: min_values[:y],
          x_max: max_values[:x],
          y_max: max_values[:y],
          pixel_count: pixel_count.to_i.abs,
          line_count: line_count.to_i.abs,
          pixel_width: pixel_width.to_f,
          pixel_height: pixel_height.to_f
        }
      end
    end

    # @return [Hash]
    def as_json
      json = {
        min_x: min_x,
        max_x: max_x,
        min_y: min_y,
        max_y: max_y
      }

      if @ogr_envelope_struct.is_a? FFI::GDAL::OGREnvelope3D
        json.merge!({ min_z: min_z, max_z: max_z })
      end

      json
    end

    # @return [String]
    def to_json
      as_json.to_json
    end
  end
end
