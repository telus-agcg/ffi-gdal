require_relative '../ffi/gdal'


module GDAL
  class GeoTransform
    include FFI::GDAL

    # @param gdal_dataset [FFI::Pointer]
    def initialize(gdal_dataset)
      @pointer_array = FFI::MemoryPointer.new(:double, 6)
      GDALGetGeoTransform(gdal_dataset, @pointer_array)
    end

    # X-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "C".
    #
    # @return [Float]
    def x_origin
      @pointer_array[0].read_double
    end

    # AKA X-pixel size.
    # In wikipedia's World Map definition, this is "A".
    #
    # @return [Float]
    def pixel_width
      @pointer_array[1].read_double
    end

    # Rotation about the x-axis.
    # In wikipedia's World Map definition, this is "B".
    #
    # @return [Float]
    def x_rotation
      @pointer_array[2].read_double
    end

    # Y-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "F".
    #
    # @return [Float]
    def y_origin
      @pointer_array[3].read_double
    end

    # Rotation about the y-axis.
    # In wikipedia's World Map definition, this is "D".
    #
    # @return [Float]
    def y_rotation
      @pointer_array[4].read_double
    end

    # AKA Y-pixel size.
    # In wikipedia's World Map definition, this is "E".
    #
    # @return [Float]
    def pixel_height
      @pointer_array[5].read_double
    end

    # The calculated UTM easting of the pixel on the map.
    #
    # @return [Float]
    def x_projection(x_pixel, y_pixel)
      (pixel_width * x_pixel) + (x_rotation * y_pixel) + x_origin
    end

    # The calculated UTM northing of the pixel on the map.
    #
    # @return [Float]
    def y_projection(x_pixel, y_pixel)
      (y_rotation * x_pixel) + (pixel_height * y_pixel) + y_origin
    end
  end
end
