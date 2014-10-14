module OGR
  module EnvelopeExtensions

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
          x_origin: min_values[:x].to_f.abs,
          y_origin: min_values[:y].to_f.abs,
          x_max: max_values[:x].to_f.abs,
          y_max: max_values[:y].to_f.abs,
          pixel_count: pixel_count.to_i.abs,
          line_count: line_count.to_i.abs,
          pixel_width: pixel_width.to_f,
          pixel_height: pixel_height.to_f
        }
      when :integer
        {
          x_origin: min_values[:x].to_i.abs,
          y_origin: min_values[:y].to_i.abs,
          x_max: max_values[:x].to_i.abs,
          y_max: max_values[:y].to_i.abs,
          pixel_count: pixel_count.to_i.abs,
          line_count: line_count.to_i.abs,
          pixel_width: pixel_width.to_f,
          pixel_height: pixel_height.to_f
        }
      else
        {
          x_origin: min_values[:x].abs,
          y_origin: min_values[:y].abs,
          x_max: max_values[:x].abs,
          y_max: max_values[:y].abs,
          pixel_count: pixel_count.to_i.abs,
          line_count: line_count.to_i.abs,
          pixel_width: pixel_width.to_f,
          pixel_height: pixel_height.to_f
        }
      end
    end

    # Compares min/max X and min/max Y to the other envelope.  The envelopes are
    # considered equal if those values are the same.
    #
    # @param other_envelope [OGR::Envelope]
    # @return [Boolean]
    def ==(other_envelope)
      min_x == other_envelope.min_x && min_y == other_envelope.min_y &&
        max_x == other_envelope.max_x && max_y == other_envelope.max_y
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

    def to_a
      [min_x, min_y, max_x, max_y]
    end
  end
end
