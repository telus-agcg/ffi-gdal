require_relative '../ffi/gdal'


module GDAL
  class GeoTransform
    include FFI::GDAL

    attr_accessor :gdal_dataset

    # @param gdal_dataset [FFI::Pointer]
    def initialize(dataset, geo_transform_pointer: nil)
      @gdal_dataset = if dataset.nil?
        FFI::MemoryPointer.new(:pointer)
      elsif dataset.is_a? GDAL::Dataset
        dataset.c_pointer
      else
        dataset
      end

      @gdal_geo_transform = if geo_transform_pointer
        geo_transform_pointer
      else
        container_pointer = FFI::MemoryPointer.new(:double, 6)
        GDALGetGeoTransform(@gdal_dataset, container_pointer)
        container_pointer
      end
    end

    def c_pointer
      @gdal_geo_transform
    end

    def null?
      c_pointer.null?
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

    # X-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "C".
    #
    # @return [Float]
    def x_origin
      return nil if null?

      c_pointer[0].read_double
    end

    # AKA X-pixel size.
    # In wikipedia's World Map definition, this is "A".
    #
    # @return [Float]
    def pixel_width
      return nil if null?

      c_pointer[1].read_double
    end

    # Rotation about the x-axis.
    # In wikipedia's World Map definition, this is "B".
    #
    # @return [Float]
    def x_rotation
      return nil if null?

      c_pointer[2].read_double
    end

    # Y-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "F".
    #
    # @return [Float]
    def y_origin
      return nil if null?

      c_pointer[3].read_double
    end

    # Rotation about the y-axis.
    # In wikipedia's World Map definition, this is "D".
    #
    # @return [Float]
    def y_rotation
      return nil if null?

      c_pointer[4].read_double
    end

    # AKA Y-pixel size.
    # In wikipedia's World Map definition, this is "E".
    #
    # @return [Float]
    def pixel_height
      return nil if null?

      c_pointer[5].read_double
    end

    # The calculated UTM easting of the pixel on the map.
    #
    # @return [Float]
    def x_projection(x_pixel, y_pixel)
      return nil if null?

      (pixel_width * x_pixel) + (x_rotation * y_pixel) + x_origin
    end

    # The calculated UTM northing of the pixel on the map.
    #
    # @return [Float]
    def y_projection(x_pixel, y_pixel)
      return nil if null?

      (y_rotation * x_pixel) + (pixel_height * y_pixel) + y_origin
    end
  end
end
