# frozen_string_literal: true

require_relative 'point'

module OGR
  # NOTE: {{#type}} will return :wkbPoint (read: 2D instead of 2.5D) until a Z
  # value is set.
  class Point25D < Point
    include GDAL::Logger

    GEOMETRY_TYPE = :wkbPoint25D

    # @return [Float, nil]
    def z
      return if empty?

      FFI::OGR::API.OGR_G_GetZ(@c_pointer, 0)
    end

    # @return [Array<Float, Float, Float>] [x, y, z].
    def point
      return [] if empty?

      x_ptr = FFI::Buffer.new_out(:double)
      y_ptr = FFI::Buffer.new_out(:double)
      z_ptr = FFI::Buffer.new_out(:double)
      FFI::OGR::API.OGR_G_GetPoint(@c_pointer, 0, x_ptr, y_ptr, z_ptr)

      [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
    end

    # @param x [Number]
    # @param y [Number]
    # @param z [Number]
    def set_point(x, y, z)
      FFI::OGR::API.OGR_G_SetPoint(@c_pointer, 0, x, y, z)
    end

    # Adds a point to a LineString or Point geometry.
    #
    # @param x [Float]
    # @param y [Float]
    # @param z [Float]
    def add_point(x, y, z)
      FFI::OGR::API.OGR_G_AddPoint(@c_pointer, x, y, z)
    end
  end
end
