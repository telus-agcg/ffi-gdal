require 'json'

module OGR
  module EnvelopeExtensions
    # @return [Float] x_max - x_min
    def x_size
      x_max - x_min
    end

    # @return [Float] y_max - y_min
    def y_size
      y_max - y_min
    end

    # @return [Float] z_max - z_min
    def z_size
      return unless z_max && z_min

      z_max - z_min
    end

    # Adapted from "Advanced Geospatial Python Modeling".  Calculates the
    # pixel locations of these geospatial coordinates according to the given
    # GeoTransform.
    #
    # @param geo_transform [GDAL::GeoTransform]
    # @return [Hash{x_min => Fixnum, y_min => Fixnum, x_max => Fixnum, y_max => Fixnum}]
    def world_to_pixels(geo_transform)
      min_values = geo_transform.world_to_pixel(x_min, y_max)
      max_values = geo_transform.world_to_pixel(x_max, y_min)

      {
        x_min: min_values[:pixel].round.to_i,
        y_min: min_values[:line].round.to_i,
        x_max: max_values[:pixel].round.to_i,
        y_max: max_values[:line].round.to_i
      }
    end

    # Compares min/max X and min/max Y to the other envelope.  The envelopes are
    # considered equal if those values are the same.
    #
    # @param other_envelope [OGR::Envelope]
    # @return [Boolean]
    def ==(other_envelope)
      x_min == other_envelope.x_min && y_min == other_envelope.y_min &&
        x_max == other_envelope.x_max && y_max == other_envelope.y_max
    end

    # Stolen from http://www.gdal.org/ogr__core_8h_source.html.
    #
    # @param [OGR::Envelope] The Envelope to merge self with.
    # @return [OGR::Envelope]
    def merge(other_envelope)
      new_envelope = OGR::Envelope.new
      new_envelope.x_min = [x_min, other_envelope.x_min].min
      new_envelope.x_max = [x_max, other_envelope.x_max].max
      new_envelope.y_min = [y_min, other_envelope.y_min].min
      new_envelope.y_max = [y_max, other_envelope.y_max].max

      new_envelope
    end

    # Stolen from http://www.gdal.org/ogr__core_8h_source.html.
    #
    # @param [OGR::Envelope] The Envelope to check intersection with.
    # @return [OGR::Envelope]
    def intersects?(other_envelope)
      x_min <= other_envelope.x_max &&
        x_max >= other_envelope.x_min &&
        y_min <= other_envelope.y_max &&
        y_max >= other_envelope.y_min
    end

    # Stolen from http://www.gdal.org/ogr__core_8h_source.html.
    #
    # @param [OGR::Envelope] The Envelope to check containment with.
    # @return [OGR::Envelope]
    def contains?(other_envelope)
      x_min <= other_envelope.x_min &&
        y_min <= other_envelope.y_min &&
        x_max >= other_envelope.x_max &&
        y_max >= other_envelope.y_max
    end

    # @return [Hash]
    def as_json(options = nil)
      json = {
        x_min: x_min,
        x_max: x_max,
        y_min: y_min,
        y_max: y_max
      }

      if @c_struct.is_a? FFI::GDAL::OGREnvelope3D
        json.merge!(z_min: z_min, z_max: z_max)
      end

      json
    end

    # @return [String]
    def to_json(options = nil)
      as_json(options).to_json
    end

    def to_a
      [x_min, y_min, x_max, y_max]
    end
  end
end
