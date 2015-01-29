require 'json'

module GDAL
  module GeoTransformExtensions
    # Calculates the pixel and line location of a geospatial coordinate.  Used
    # for converting from world coordinates to to image pixels.
    #
    # @param x_geo [Fixnum]
    # @param y_geo [Fixnum]
    # @return [Hash{pixel => Fixnum, line Fixnum}]
    def world_to_pixel(x_geo, y_geo)
      pixel = (x_geo - x_origin) / pixel_width
      line = (y_origin - y_geo) / pixel_height

      { pixel: pixel.round.to_i, line: line.round.to_i }
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
    def to_json(_ = nil)
      as_json.to_json
    end
  end
end
