require 'json'

module GDAL
  module GeoTransformExtensions
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods

      # Calculates the size of an X/longitude pixel.
      #
      # @param x_max [Number]
      # @param x_min [Number]
      # @param pixel_width [Number]
      def x_size(x_max, x_min, pixel_width)
        (x_max - x_min) / pixel_width
      end

      # Calculates the size of an Y/latitude pixel.
      #
      # @param y_max [Number]
      # @param y_min [Number]
      # @param pixel_height [Number]
      def y_size(y_max, y_min, pixel_height)
        ((y_max - y_min) / pixel_height)
      end
    end

    # The calculated UTM easting of the pixel on the map.
    #
    # @return [Float]
    def x_projection(x_pixel, y_pixel)
      return nil if null?

      apply_geo_transform(x_pixel, y_pixel)[:x_location]
    end

    # The calculated UTM northing of the pixel on the map.
    #
    # @return [Float]
    def y_projection(x_pixel, y_pixel)
      return nil if null?

      apply_geo_transform(x_pixel, y_pixel)[:y_location]
    end

    # Adapted from "Advanced Geospatial Python Modeling".  Calculates the
    # pixel location of a geospatial coordinate.
    #
    # @param lon [Fixnum]
    # @param lat [Fixnum]
    # @param value_type [Symbol] Data type to return: :float or :integer.
    # @return [Hash<x, y>] [pixel, line]
    def world_to_pixel(lon, lat, value_type=:float)
      pixel = self.class.x_size(lon, x_origin, pixel_width)
      line = self.class.y_size(y_origin, lat, pixel_height)

      case value_type
      when :float
        { x: pixel.to_f, y: line.to_f }
      when :integer
        { x: pixel.to_i, y: line.to_i }
      else
        { x: pixel, y: line }
      end
    end

    # Calculates the size of an X/longitude pixel using the geotransform's
    # x_origin and pixel_width.
    #
    # @param x_max [Number]
    # @param x_min [Number]
    def x_size(x_max)
      self.class.x_size(x_max, x_origin, pixel_width)
    end

    # Calculates the size of an Y/latitude pixel using the geotransform's
    # y_origin and pixel_height.
    #
    # @param y_max [Number]
    # @param y_min [Number]
    def y_size(y_max)
      self.class.y_size(y_max, y_origin, pixel_height)
    end

    # All attributes as an Array, in the order:
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
    def as_json
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
    def to_json
      as_json.to_json
    end
  end
end
