# frozen_string_literal: true

require_relative 'geometry/geometry_methods'
require_relative 'geometry/has_two_coordinate_dimensions'
require_relative 'geometry/not_a_geometry_collection'

module OGR
  class Point
    include GDAL::Logger
    include OGR::Geometry::GeometryMethods
    include OGR::Geometry::HasTwoCoordinateDimensions
    include OGR::Geometry::NotAGeometryCollection

    GEOMETRY_TYPE = :wkbPoint

    def self.new_from_coordinates(x, y)
      c_pointer = OGR::Geometry.create(GEOMETRY_TYPE)
      point = new(c_pointer: c_pointer)
      point.add_point(x, y)

      point
    end

    attr_reader :c_pointer

    def initialize(c_pointer: nil, spatial_reference: nil)
      @c_pointer = c_pointer || OGR::Geometry.create(GEOMETRY_TYPE)
      self.spatial_reference = spatial_reference if spatial_reference
    end

    # @return [Float, nil]
    def x
      return nil if empty?

      FFI::OGR::API.OGR_G_GetX(@c_pointer, 0)
    end

    # @return [Float, nil]
    def y
      return nil if empty?

      FFI::OGR::API.OGR_G_GetY(@c_pointer, 0)
    end

    # @return [<Array<Float, Float>] [x, y].
    def point
      return [] if empty?

      x_ptr = FFI::Buffer.new_out(:double)
      y_ptr = FFI::Buffer.new_out(:double)
      z_ptr = FFI::Buffer.new_out(:double)
      FFI::OGR::API.OGR_G_GetPoint(@c_pointer, 0, x_ptr, y_ptr, z_ptr)

      [x_ptr.read_double, y_ptr.read_double]
    end
    alias point_value point

    # @param x [Number]
    # @param y [Number]
    def set_point(x, y)
      FFI::OGR::API.OGR_G_SetPoint_2D(@c_pointer, 0, x, y)
    end

    # Adds a point to a LineString or Point geometry.
    #
    # @param x [Float]
    # @param y [Float]
    def add_point(x, y)
      FFI::OGR::API.OGR_G_AddPoint_2D(@c_pointer, x, y)
    end

    # @return [Integer]
    def point_count
      FFI::OGR::API.OGR_G_GetPointCount(@c_pointer)
    end
  end
end
