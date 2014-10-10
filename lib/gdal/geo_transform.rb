require_relative '../ffi/gdal'


module GDAL
  class GeoTransform
    include FFI::GDAL

    def self.new_pointer
      FFI::MemoryPointer.new(:double, 6)
    end

    # @param filename [String]
    # @return [GDAL::GeoTransform]
    def self.from_world_file(filename, extension=nil)
      gt_ptr = new_pointer

      result = if extension
        FFI::GDAL.GDALReadWorldFile(filename, extension, gt_ptr)
      else
        FFI::GDAL.GDALLoadWorldFile(filename, gt_ptr)
      end

      return nil unless result

      new(gt_ptr)
    end

    # @param dataset [GDAL::Dataset,FFI::Pointer]
    # @param geo_transform_pointer [FFI::Pointer]
    def initialize(geo_transform=nil)
      @geo_transform_pointer = if geo_transform.is_a? GDAL::GeoTransform
        geo_transform.c_pointer
      elsif geo_transform
        geo_transform
      else
        self.class.new_pointer
      end

      to_a
    end

    def c_pointer
      @geo_transform_pointer
    end

    def null?
      @geo_transform_pointer.null?
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

      @geo_transform_pointer[0].read_double
    end

    # @param new_x_origin [Float]
    def x_origin=(new_x_origin)
      @geo_transform_pointer[0].write_double(new_x_origin)
    end

    # AKA X-pixel size.
    # In wikipedia's World Map definition, this is "A".
    #
    # @return [Float]
    def pixel_width
      return nil if null?

      @geo_transform_pointer[1].read_double
    end

    # @param new_pixel_width [Float]
    def pixel_width=(new_pixel_width)
      @geo_transform_pointer[1].write_double(new_pixel_width)
    end

    # Rotation about the x-axis.
    # In wikipedia's World File definition, this is "B".
    #
    # @return [Float]
    def x_rotation
      return nil if null?

      @geo_transform_pointer[2].read_double
    end

    # @param new_x_rotation [Float]
    def x_rotation=(new_x_rotation)
      @geo_transform_pointer[2].write_double(new_x_rotation)
    end

    # Y-coordinate of the center of the upper left pixel.
    # In wikipedia's World Map definition, this is "F".
    #
    # @return [Float]
    def y_origin
      return nil if null?

      @geo_transform_pointer[3].read_double
    end

    # @param new_y_origin [Float]
    def y_origin=(new_y_origin)
      @geo_transform_pointer[3].write_double(new_y_origin)
    end

    # Rotation about the y-axis.
    # In wikipedia's World Map definition, this is "D".
    #
    # @return [Float]
    def y_rotation
      return nil if null?

      @geo_transform_pointer[4].read_double
    end

    # @param new_y_rotation [Float]
    def y_rotation=(new_y_rotation)
      @geo_transform_pointer[4].write_double(new_y_rotation)
    end

    # AKA Y-pixel size.
    # In wikipedia's World Map definition, this is "E".
    #
    # @return [Float]
    def pixel_height
      return nil if null?

      @geo_transform_pointer[5].read_double
    end

    # @param new_pixel_height [Float]
    def pixel_height=(new_pixel_height)
      @geo_transform_pointer[5].write_double(new_pixel_height)
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

    # Converts a (pixel, line) coordinate to a georeferenced (geo_x, geo_y)
    # location.
    #
    # @param pixel [Float] Input pixel position.
    # @param line [Float] Input line position.
    # @return [Hash{x_location: Float, y_location: Float}] longitude, latitude.
    def apply_geo_transform(pixel, line)
      geo_x_ptr = FFI::MemoryPointer.new(:double)
      geo_y_ptr = FFI::MemoryPointer.new(:double)
      GDALApplyGeoTransform(@geo_transform_pointer, pixel, line, geo_x_ptr, geo_y_ptr)

      { longitude: geo_x_ptr.read_double, latitude: geo_y_ptr.read_double }
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
    # @param x [Fixnum]
    # @param y [Fixnum]
    # @param value_type [Symbol] Data type to return: :float or :integer.
    # @return [Hash<x, y>] [pixel, line]
    def world_to_pixel(lon, lat, value_type: :float)
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

    # Composes this and the give geo_transform.  The result is equivalent to
    # applying both geotransforms to a point.
    #
    # @param other_geo_transform [GDAL::GeoTransform, FFI::Pointer]
    # @return [GDAL::GeoTransform]
    def compose(other_geo_transform)
      other_ptr = if other_geo_transform.is_a? GDAL::GeoTransform
        other_geo_transform.c_pointer
      else
        other_geo_transform
      end

      new_gt_ptr = self.class.new_pointer
      GDALComposeGeoTransforms(@geo_transform_pointer, other_pointer, new_gt_ptr)
      return nil if new_gt_ptr.null?

      GDAL::GeoTransform.new(new_gt_ptr)
    end

    # Inverts the current 3x2 set of coefficients and returns a new GeoTransform.
    # Useful for converting from the geotransform equation from pixel to geo to
    # being geo to pixel.
    #
    # @return [GDAL::GeoTransform]
    def invert
      new_geo_transform_ptr = self.class.new_pointer
      success = GDALInvGeoTransform(@geo_transform_pointer, new_geo_transform_ptr)
      return nil unless success

      self.class.new(new_geo_transform_ptr)
    end

    # @param raster_filename [String] The target raster file.
    # @param world_extension [String]
    # @return [Boolean]
    def to_world_file(raster_filename, world_extension)
      GDALWriteWorldFile(raster_filename, world_extension, @geo_transform_pointer)
    end
  end
end
