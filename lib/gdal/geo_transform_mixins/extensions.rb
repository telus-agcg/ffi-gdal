require 'json'
require_relative '../exceptions'

module GDAL
  module GeoTransformMixins
    module Extensions
      # @param base [Class,Module]
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Builds a GeoTransform from the x and y mins and maxes from the
        # +envelope+. Uses +raster_width+ and +raster_height+ to calculate the
        # pixel dimensions. Assumes north-up.
        #
        # @param envelope [OGR::Envelope]
        # @param raster_width [Fixnum]
        # @param raster_height [Fixnum]
        def new_from_envelope(envelope, raster_width, raster_height)
          gt = GDAL::GeoTransform.new
          gt.x_origin = envelope.x_min
          gt.y_origin = envelope.y_min
          gt.pixel_width = envelope.x_size / raster_width
          gt.pixel_height = envelope.y_size / raster_height

          gt
        end
      end

      # Calculates the pixel and line location of a geospatial coordinate.  Used
      # for converting from world coordinates to to image pixels.
      #
      # @param x_geo [Number]
      # @param y_geo [Number]
      # @return [Hash{pixel => Fixnum, line Fixnum}]
      def world_to_pixel(x_geo, y_geo)
        pixel = world_to_x_pixel(x_geo)
        line = world_to_y_pixel(y_geo)

        { pixel: pixel, line: line }
      end

      # Calculates the pixel location using the current GeoTransform and
      # +x_geo+ coordinate.
      #
      # @param x_geo [Number]
      # @return [Fixnum]
      # @raise [GDAL::InvalidGeoTransform] if {GDAL::GeoTransform#pixel_width}
      #   is 0.
      def world_to_x_pixel(x_geo)
        pixel = (x_geo - x_origin) / pixel_width

        pixel.round.to_i
      rescue FloatDomainError
        raise GDAL::InvalidGeoTransform, "Invalid pixel_width (#{pixel_width})"
      end

      # Calculates the line location using the current GeoTransform and +y_geo+
      # coordinate.
      #
      # @param y_geo [Number]
      # @return [Fixnum]
      # @raise [GDAL::InvalidGeoTransform] if {GDAL::GeoTransform#pixel_height}
      #   is 0.
      def world_to_y_pixel(y_geo)
        line = (y_origin - y_geo) / pixel_height

        line.round.to_i
      rescue FloatDomainError
        raise GDAL::InvalidGeoTransform, "Invalid pixel_height (#{pixel_height})"
      end

      # All attributes as an Array, in the order the C-Struct describes them:
      #   * x_origin
      #   * pixel_width
      #   * x_rotation
      #   * y_origin
      #   * y_rotation
      #   * pixel_height
      #
      # @return [Array]
      def to_a
        [
          x_origin,
          pixel_width,
          x_rotation,
          y_origin,
          y_rotation,
          pixel_height
        ]
      end

      # @return [Hash]
      def as_json(_options = nil)
        {
          x_origin: x_origin,
          x_rotation: x_rotation,
          pixel_width: pixel_width,
          y_origin: y_origin,
          y_rotation: y_rotation,
          pixel_height: pixel_height
        }
      end

      # @return [String]
      def to_json(options = nil)
        as_json(options).to_json
      end
    end
  end
end
