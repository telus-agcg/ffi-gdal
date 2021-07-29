# frozen_string_literal: true

module OGR
  module Geometry
    module Interfaces
      module XYZPoints
        # @param point_number [Integer]
        # @return [Float]
        # @raise [GDAL::UnsupportedOperation] If `point_number` doesn't exist.
        def x(point_number)
          FFI::OGR::API.OGR_G_GetX(@c_pointer, point_number)
        end

        # @param point_number [Integer]
        # @return [Float]
        # @raise [GDAL::UnsupportedOperation] If `point_number` doesn't exist.
        def y(point_number)
          FFI::OGR::API.OGR_G_GetY(@c_pointer, point_number)
        end

        # @param point_number [Integer]
        # @return [Float]
        # @raise [GDAL::UnsupportedOperation] If `point_number` doesn't exist.
        def z(point_number)
          FFI::OGR::API.OGR_G_GetZ(@c_pointer, point_number)
        end

        # Adds a point to a LineString or Point geometry.
        #
        # @param x [Float]
        # @param y [Float]
        # @param z [Float]
        def add_point(x, y, z)
          FFI::OGR::API.OGR_G_AddPoint(@c_pointer, x, y, z)
        end

        # @param point_number [Integer] Index of the point to get.
        # @return [Array<Float, Float, Float>] [x, y] if 2d or [x, y, z] if 3d.
        # @raise [GDAL::UnsupportedOperation] If `point_number` doesn't exist.
        def point(point_number)
          x_ptr = FFI::Buffer.new_out(:double)
          y_ptr = FFI::Buffer.new_out(:double)
          z_ptr = FFI::Buffer.new_out(:double)

          FFI::OGR::API.OGR_G_GetPoint(@c_pointer, point_number, x_ptr, y_ptr, z_ptr)

          [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
        end
        alias get_point point

        # @param point_number [Integer] The index of the vertex to assign.
        # @param x [Float]
        # @param y [Float]
        # @param z [Float]
        def set_point(point_number, x, y, z)
          FFI::OGR::API.OGR_G_SetPoint(@c_pointer, point_number, x, y, z)
        end

        # @return [Array<[Float, Float, Float]>] An array of (x, y, z) points.
        def points
          stride = FFI::Type::DOUBLE.size

          buffer_size = point_count
          x_buffer = FFI::Buffer.new_out(:buffer_out, buffer_size)
          y_buffer = FFI::Buffer.new_out(:buffer_out, buffer_size)
          z_buffer = FFI::Buffer.new_out(:buffer_out, buffer_size)

          num_points = FFI::OGR::API.OGR_G_GetPoints(@c_pointer,
                                                     x_buffer, stride, y_buffer,
                                                     stride, z_buffer, stride)

          log 'Got different number of points than point_count in #point_values' unless num_points == point_count

          x_array = x_buffer.read_array_of_double(buffer_size)
          y_array = y_buffer.read_array_of_double(buffer_size)
          z_array = z_buffer.read_array_of_double(buffer_size)

          [x_array, y_array, z_array].transpose
        end
        alias get_points points
        alias point_values points

        # @param new_count [Integer]
        def point_count=(new_count)
          FFI::OGR::API.OGR_G_SetPointCount(@c_pointer, new_count)
        end

        # @return [Integer]
        def point_count
          FFI::OGR::API.OGR_G_GetPointCount(@c_pointer)
        end
      end
    end
  end
end
