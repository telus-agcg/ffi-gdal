module OGR
  module GeometryTypes
    module Curve
      # @return [Float]
      def x(point_number)
        FFI::OGR::API.OGR_G_GetX(@c_pointer, point_number)
      end

      # @return [Float]
      def y(point_number)
        FFI::OGR::API.OGR_G_GetY(@c_pointer, point_number)
      end

      # @return [Float]
      def z(point_number)
        FFI::OGR::API.OGR_G_GetZ(@c_pointer, point_number)
      end

      # @return [Array<Float, Float, Float>] [x, y] if 2d or [x, y, z] if 3d.
      def point(number)
        x_ptr = FFI::MemoryPointer.new(:double)
        y_ptr = FFI::MemoryPointer.new(:double)
        z_ptr = FFI::MemoryPointer.new(:double)

        FFI::OGR::API.OGR_G_GetPoint(@c_pointer, number, x_ptr, y_ptr, z_ptr)

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
      def add_point(x, y, z = 0)
        if coordinate_dimension == 3
          FFI::OGR::API.OGR_G_AddPoint(@c_pointer, x, y, z)
        else
          FFI::OGR::API.OGR_G_AddPoint_2D(@c_pointer, x, y)
        end
      end

      # @param index [Fixnum] The index of the vertex to assign.
      # @param x [Number]
      # @param y [Number]
      # @param z [Number]
      def set_point(index, x, y, z = 0)
        FFI::OGR::API.OGR_G_SetPoint(@c_pointer, index, x, y, z)
      end

      def points
        require_relative '../geometries/point'

        point_values.map.with_index do |coords, i|
          point = OGR::Point.new
          point.set_point(i, *coords)
          point
        end
      end

      # @return [Array<Array>] An array of (x, y) or (x, y, z) points.
      def point_values
        x_stride = FFI::Type::DOUBLE.size
        y_stride = FFI::Type::DOUBLE.size
        z_stride = coordinate_dimension == 3 ? FFI::Type::DOUBLE.size : 0

        buffer_size = point_count
        x_buffer = FFI::MemoryPointer.new(:buffer_out, buffer_size)
        y_buffer = FFI::MemoryPointer.new(:buffer_out, buffer_size)

        z_buffer = if coordinate_dimension == 3
                     FFI::MemoryPointer.new(:buffer_out, buffer_size)
                   end

        num_points = FFI::OGR::API.OGR_G_GetPoints(@c_pointer,
          x_buffer,
          x_stride,
          y_buffer,
          y_stride,
          z_buffer,
          z_stride)

        x_array = x_buffer.read_array_of_double(buffer_size)
        y_array = y_buffer.read_array_of_double(buffer_size)

        if z_buffer
          z_array = z_buffer.read_array_of_double(buffer_size)

          [x_array, y_array, z_array].transpose
        else
          [x_array, y_array].transpose
        end
      end

      # @param geo_transform [GDAL::GeoTransform]
      # @return [Array<Array>]
      def pixels(geo_transform)
        log "points count: #{point_count}"
        points.map do |x_and_y|
          result = geo_transform.world_to_pixel(*x_and_y)

          [result[:pixel].to_i.abs, result[:line].to_i.abs]
        end
      end

      # @param new_count [Fixnum]
      def point_count=(new_count)
        FFI::OGR::API.OGR_G_SetPointCount(@c_pointer, new_count)
      end

      # Computes the length for this geometry.  Computes area for Curve or
      # MultiCurve objects.
      #
      # @return [Float] 0.0 for unsupported geometry types.
      def length
        FFI::OGR::API.OGR_G_Length(@c_pointer)
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
