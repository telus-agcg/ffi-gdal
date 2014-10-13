module OGR
  module GeometryTypes
    module Curve

      # @return [Float]
      def x(point_number)
        FFI::GDAL.OGR_G_GetX(@geometry_pointer, point_number)
      end

      # @return [Float]
      def y(point_number)
        FFI::GDAL.OGR_G_GetY(@geometry_pointer, point_number)
      end

      # @return [Float]
      def z(point_number)
        FFI::GDAL.OGR_G_GetZ(@geometry_pointer, point_number)
      end

      # @return [Array<Float, Float, Float>] [x, y] if 2d or [x, y, z] if 3d.
      def point(number)
        x_ptr = FFI::MemoryPointer.new(:double)
        y_ptr = FFI::MemoryPointer.new(:double)
        z_ptr = FFI::MemoryPointer.new(:double)

        FFI::GDAL.OGR_G_GetPoint(@geometry_pointer, number, x_ptr, y_ptr, z_ptr)

        if coordinate_dimension == 2
          [x_ptr.read_double, y_ptr.read_double]
        else
          [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
        end
      end

      # Adds a point to a LineString or Point geometry.
      #
      # @param x [Float]
      # @param y [Float]
      # @param z [Float]
      def add_point(x, y, z=0)
        FFI::GDAL.OGR_G_AddPoint(@geometry_pointer, x, y, z)
      end

      def set_point(index, x, y, z=0)
        FFI::GDAL.OGR_G_SetPoint(@geometry_pointer, index, x, y, z)
      end

      # @return [Array<Array>] An array of (x, y) or (x, y, z) points.
      def points
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

        0.upto(num_points - 1).map do |i|
          point(i)
        end
      end

      # @param new_count [Fixnum]
      def point_count=(new_count)
        FFI::GDAL.OGR_G_SetPointCount(@geometry_pointer, new_count)
      end

      # Computes the length for this geometry.  Computes area for Curve or
      # MultiCurve objects.
      #
      # @param geometry [OGR::Geometry, FFI::Pointer]
      # @return [Float] 0.0 for unsupported geometry types.
      def length
        FFI::GDAL.OGR_G_Length(@geometry_pointer)
      end

      def start_point
        point(0)
      end

      def end_point
        point(point_count - 1)
      end

      def closed?
        start_point == end_point
      end
    end
  end
end
