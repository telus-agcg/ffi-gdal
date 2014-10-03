require_relative '../ffi/gdal'


module GDAL
  class GeoTransform
    include FFI::GDAL

    attr_accessor :gdal_dataset

    # @param dataset [GDAL::Dataset,FFI::Pointer]
    # @param geo_transform_pointer [FFI::Pointer]
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
        GDALGetGeoTransform(@gdal_dataset, container_pointer).to_ruby
        container_pointer
      end

      to_a
    end

    def c_pointer
      @gdal_geo_transform
    end

    def null?
      @gdal_geo_transform.null?
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

      @gdal_geo_transform[0].read_double
    end

    # @param new_x_origin [Float]
    def x_origin=(new_x_origin)
      @gdal_geo_transform[0].write_double(new_x_origin)
    end

    # AKA X-pixel size.
    # In wikipedia's World Map definition, this is "A".
    #
    # @return [Float]
    def pixel_width
      return nil if null?

      @gdal_geo_transform[1].read_double
    end

    # @param new_pixel_width [Float]
    def pixel_width=(new_pixel_width)
      @gdal_geo_transform[1].write_double(new_pixel_width)
    end

    # Rotation about the x-axis.
    # In wikipedia's World File definition, this is "B".
    #
    # @return [Float]
    def x_rotation
      return nil if null?

      @gdal_geo_transform[2].read_double
    end

    # @param new_x_rotation [Float]
    def x_rotation=(new_x_rotation)
      @gdal_geo_transform[2].write_double(new_x_rotation)
    end

    # Y-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "F".
    #
    # @return [Float]
    def y_origin
      return nil if null?

      @gdal_geo_transform[3].read_double
    end

    # @param new_y_origin [Float]
    def y_origin=(new_y_origin)
      @gdal_geo_transform[3].write_double(new_y_origin)
    end


    # Rotation about the y-axis.
    # In wikipedia's World Map definition, this is "D".
    #
    # @return [Float]
    def y_rotation
      return nil if null?

      @gdal_geo_transform[4].read_double
    end

    # @param new_y_rotation [Float]
    def y_rotation=(new_y_rotation)
      @gdal_geo_transform[4].write_double(new_y_rotation)
    end

    # AKA Y-pixel size.
    # In wikipedia's World Map definition, this is "E".
    #
    # @return [Float]
    def pixel_height
      return nil if null?

      @gdal_geo_transform[5].read_double
    end

    # @param new_pixel_height [Float]
    def pixel_height=(new_pixel_height)
      @gdal_geo_transform[5].write_double(new_pixel_height)
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
