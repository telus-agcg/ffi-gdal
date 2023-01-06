# frozen_string_literal: true

require 'ogr/envelope'

module OGR
  class Envelope
    module Extensions
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
      # @return [Hash{x_min => Integer, y_min => Integer, x_max => Integer, y_max => Integer}]
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
      # @param other [OGR::Envelope]
      # @return [Boolean]
      def ==(other)
        x_min == other.x_min && y_min == other.y_min &&
          x_max == other.x_max && y_max == other.y_max
      end

      # Stolen from http://www.gdal.org/ogr__core_8h_source.html.
      #
      # @param other_envelope [OGR::Envelope] The Envelope to merge self with.
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
      # @param other_envelope [OGR::Envelope] The Envelope to check intersection
      #   with.
      # @return [Boolean]
      def intersects?(other_envelope)
        x_min <= other_envelope.x_max &&
          x_max >= other_envelope.x_min &&
          y_min <= other_envelope.y_max &&
          y_max >= other_envelope.y_min
      end

      # Stolen from http://www.gdal.org/ogr__core_8h_source.html.
      #
      # @param other_envelope [OGR::Envelope] The Envelope to check containment
      #   with.
      # @return [Boolean]
      def contains?(other_envelope)
        x_min <= other_envelope.x_min &&
          y_min <= other_envelope.y_min &&
          x_max >= other_envelope.x_max &&
          y_max >= other_envelope.y_max
      end

      # @return [OGR::Polygon]
      def to_polygon
        ring = OGR::LinearRing.new
        ring.point_count = 5
        ring.set_point(0, x_min, y_max)
        ring.set_point(1, x_max, y_max)
        ring.set_point(2, x_max, y_min)
        ring.set_point(3, x_min, y_min)
        ring.set_point(4, x_min, y_max)

        polygon = OGR::Polygon.new
        polygon.add_geometry(ring)

        polygon
      end

      def to_a
        [x_min, y_min, x_max, y_max]
      end
    end
  end
end

OGR::Envelope.include(OGR::Envelope::Extensions)
