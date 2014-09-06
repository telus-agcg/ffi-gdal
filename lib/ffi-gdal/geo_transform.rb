require_relative '../ffi/gdal'


module GDAL
  class GeoTransform
    include FFI::GDAL

    attr_accessor :gdal_dataset

    # @param gdal_dataset [FFI::Pointer]
    def initialize(gdal_dataset=nil)
      @gdal_dataset = gdal_dataset || FFI::MemoryPointer.new(:pointer)
    end

    def gdal_geo_transform
      return @gdal_geo_transform if @gdal_geo_transform

      @gdal_geo_transform = FFI::MemoryPointer.new(:double, 6)
      GDALGetGeoTransform(@gdal_dataset, @gdal_geo_transform)

      @gdal_geo_transform
    end

    def null?
      gdal_geo_transform.null?
    end

    # X-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "C".
    #
    # @return [Float]
    def x_origin
      return nil if null?

      gdal_geo_transform[0].read_double
    end

    # AKA X-pixel size.
    # In wikipedia's World Map definition, this is "A".
    #
    # @return [Float]
    def pixel_width
      return nil if null?

      gdal_geo_transform[1].read_double
    end

    # Rotation about the x-axis.
    # In wikipedia's World Map definition, this is "B".
    #
    # @return [Float]
    def x_rotation
      return nil if null?

      gdal_geo_transform[2].read_double
    end

    # Y-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "F".
    #
    # @return [Float]
    def y_origin
      return nil if null?

      gdal_geo_transform[3].read_double
    end

    # Rotation about the y-axis.
    # In wikipedia's World Map definition, this is "D".
    #
    # @return [Float]
    def y_rotation
      return nil if null?

      gdal_geo_transform[4].read_double
    end

    # AKA Y-pixel size.
    # In wikipedia's World Map definition, this is "E".
    #
    # @return [Float]
    def pixel_height
      return nil if null?

      gdal_geo_transform[5].read_double
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
