require 'json'

module GDAL
  module GeoTransformExtensions

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

    # The algorithm per http://www.gdal.org/gdal_datamodel.html.
    def pixel_to_world(pixel, line)
      x_geo = x_origin + (pixel * pixel_width) + (line * x_rotation)
      y_geo = y_origin + (pixel * pixel_height) + (line * y_rotation)

      { longitude: y_geo, latitude: x_geo }
    end

    # Adapted from "Advanced Geospatial Python Modeling".  Calculates the
    # pixel location of a geospatial coordinate.
    #
    # @param lon [Fixnum]
    # @param lat [Fixnum]
    # @param value_type [Symbol] Data type to return: :float or :integer.
    # @return [Hash<x, y>] [pixel, line]
    def world_to_pixel(lon, lat, value_type=:float)
      pixel = (lon - x_origin) / pixel_width
      line = (y_origin - lat) / pixel_height

      case value_type
      when :float
        { x: pixel.to_f, y: line.to_f }
      when :integer
        { x: pixel.to_i, y: line.to_i }
      else
        { x: pixel, y: line }
      end
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
