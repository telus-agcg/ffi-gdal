module OGR
  module PointExtensions
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
                 end

      _num_points = FFI::OGR::API.OGR_G_GetPoints(@c_pointer,
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
