module OGR
  class Point < Geometry
    # def area
    #   0.0
    # end

    # @return [Float]
    def x
      return nil if empty?

      FFI::GDAL.OGR_G_GetX(@geometry_pointer, 0)
    end

    # @return [Float]
    def y
      return nil if empty?

      FFI::GDAL.OGR_G_GetY(@geometry_pointer, 0)
    end

    # @return [Float]
    def z
      return nil if empty?

      FFI::GDAL.OGR_G_GetZ(@geometry_pointer, 0)
    end

    # @return [Array<Float, Float, Float>] [x, y] if 2d or [x, y, z] if 3d.
    def point
      return [] if empty?

      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double)

      FFI::GDAL.OGR_G_GetPoint(@geometry_pointer, 0, x_ptr, y_ptr, z_ptr)

      if coordinate_dimension == 2
        [x_ptr.read_double, y_ptr.read_double]
      else
        [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
      end
    end

    def set_point(x, y, z=0)
      FFI::GDAL.OGR_G_SetPoint(@geometry_pointer, 0, x, y, z)
    end

    # Adds a point to a LineString or Point geometry.
    #
    # @param x [Float]
    # @param y [Float]
    # @param z [Float]
    def add_point(x, y, z=0)
      FFI::GDAL.OGR_G_AddPoint(@geometry_pointer, x, y, z)
    end

    # @return [Array<Array>] An array of (x, y) or (x, y, z) points.
    def points
      return [[]] if empty?

      x_stride = 2
      y_stride = 2
      z_stride = coordinate_dimension == 3 ? 1 : 0

      buffer_size = FFI::Type::DOUBLE.size * 2 * point_count

      x_buffer = FFI::MemoryPointer.new(:buffer_out, buffer_size)
      y_buffer = FFI::MemoryPointer.new(:buffer_out, buffer_size)

      z_buffer = if coordinate_dimension == 3
        z_size = FFI::Type::DOUBLE.size * point_count
        FFI::MemoryPointer.new(:buffer_out, z_size)
      else
        nil
      end

      num_points = FFI::GDAL.OGR_G_GetPoints(@geometry_pointer,
        x_buffer,
        x_stride,
        y_buffer,
        y_stride,
        z_buffer,
        z_stride)

      [point]
    end
  end
end
