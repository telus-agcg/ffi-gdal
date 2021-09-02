# frozen_string_literal: true

require 'ffi'
require 'narray'
require_relative '../ogr'
require_relative '../gdal'

module OGR
  class CoordinateTransformation
    class AutoPointer < ::FFI::AutoPointer
      def self.release(c_pointer)
        return if c_pointer.nil? || c_pointer.null?

        FFI::OGR::SRSAPI.OCTDestroyCoordinateTransformation(c_pointer)
      end
    end

    # Input spatial reference system objects are assigned by copy (calling clone() method)
    # and no ownership transfer occurs. This will honor the axis order
    # advertised by the source and target SRS, as well as their "data axis to
    # SRS axis mapping". To have a behavior similar to GDAL < 3.0, the
    # OGR_CT_FORCE_TRADITIONAL_GIS_ORDER configuration option can be set to YES.
    #
    # @param source_srs [OGR::SpatialReference]
    # @param destination_srs [OGR::SpatialReference]
    # @raise [FFI::GDAL::InvalidPointer]
    def self.create(source_srs, destination_srs)
      source_ptr = source_srs.c_pointer
      destination_ptr = destination_srs.c_pointer

      # NOTE: In GDAL 3, this will cause the GDAL error handler to raise a
      # GDAL::Error; in < 3, this just returns a null pointer, then gets handled
      # by the null-pointer check below.
      pointer = FFI::OGR::SRSAPI.OCTNewCoordinateTransformation(source_ptr, destination_ptr)

      raise GDAL::Error, 'Unable to create coordinate transformation' if pointer.null?

      new(OGR::CoordinateTransformation::AutoPointer.new(pointer))
    end

    # @return [OGR::CoordinateTransformation::AutoPointer, FFI::Pointer] C pointer that
    #   represents the CoordinateTransformation.
    attr_reader :c_pointer

    # @param pointer [OGR::CoordinateTransformation::AutoPointer, FFI::Pointer]
    def initialize(pointer)
      @c_pointer = pointer
    end

    # Transforms points in the +#source_coordinate_system+ space to points in the
    # +#destination_coordinate_system+ (given in {#initialize}).
    #
    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @return [Array<Array<Float>,Array<Float>,Array<Float>>] [[x1, x2, etc], [y1, y2, etc]]
    #   Will include a 3rd array of Z values if z vertices are given.
    def transform(x_vertices, y_vertices, z_vertices = nil)
      if z_vertices
        _transform_3d(x_vertices, y_vertices, z_vertices) do |point_count, x_ptr, y_ptr, z_ptr|
          FFI::OGR::SRSAPI.OCTTransform(@c_pointer, point_count, x_ptr, y_ptr, z_ptr)
        end
      else
        _transform_2d(x_vertices, y_vertices) do |point_count, x_ptr, y_ptr|
          FFI::OGR::SRSAPI.OCTTransform(@c_pointer, point_count, x_ptr, y_ptr, nil)
        end
      end
    end

    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>, nil]
    # @return [Hash{points => Array<Array<Float>,Array<Float>,Array<Float>>, success_at => Array}]
    #   [[x1, y1], [x2, y2], etc]
    def transform_ex(x_vertices, y_vertices, z_vertices = nil)
      point_count = if z_vertices
                      [x_vertices.length, y_vertices.length, z_vertices.length].max
                    else
                      [x_vertices.length, y_vertices.length].max
                    end

      raise 'No points given' unless point_count

      successes_ptr = FFI::MemoryPointer.new(:bool, point_count)

      point_array = if z_vertices
                      _transform_3d(x_vertices, y_vertices, z_vertices) do |_, x_ptr, y_ptr, z_ptr|
                        FFI::OGR::SRSAPI.OCTTransformEx(@c_pointer, point_count, x_ptr, y_ptr, z_ptr, successes_ptr)
                      end
                    else
                      _transform_2d(x_vertices, y_vertices) do |_, x_ptr, y_ptr|
                        FFI::OGR::SRSAPI.OCTTransformEx(@c_pointer, point_count, x_ptr, y_ptr, nil, successes_ptr)
                      end
                    end

      successes = successes_ptr.read_array_of_type(FFI::Type::BOOL, :read_char, point_count).map do |value|
        !value.zero?
      end

      { points: point_array, successes: successes }
    end

    private

    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @yieldparam point_count [Integer]
    # @yieldparam x_ptr [FFI::MemoryPointer]
    # @yieldparam y_ptr [FFI::MemoryPointer]
    # @yieldreturn [Boolean]
    # @return [[Array<Float>,Array<Float>] [[x1, x2, etc], [y1, y2, etc]]
    def _transform_2d(x_vertices, y_vertices)
      x_ptr, y_ptr = init_transform_pointers_2d(x_vertices, y_vertices)
      point_count = [x_vertices.length, y_vertices.length].max

      raise 'No points given' unless point_count

      success = yield point_count, x_ptr, y_ptr

      raise 'Unable to transform coordinates' unless success

      [x_ptr.read_array_of_double(point_count), y_ptr.read_array_of_double(point_count)]
    end

    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @yieldparam point_count [Integer]
    # @yieldparam x_ptr [FFI::MemoryPointer]
    # @yieldparam y_ptr [FFI::MemoryPointer]
    # @yieldparam z_ptr [FFI::MemoryPointer]
    # @yieldreturn [Boolean]
    # @return [Array<Array<Float>,Array<Float>,Array<Float>>] [[x1, x2, etc], [y1, y2, etc],
    #   [z1, z2, etc]]
    def _transform_3d(x_vertices, y_vertices, z_vertices)
      x_ptr, y_ptr, z_ptr = init_transform_pointers_3d(x_vertices, y_vertices, z_vertices)
      point_count = [x_vertices.length, y_vertices.length, z_vertices.length].max

      raise 'No points given' unless point_count

      success = yield point_count, x_ptr, y_ptr, z_ptr

      raise 'Unable to transform coordinates' unless success

      [
        x_ptr.read_array_of_double(point_count),
        y_ptr.read_array_of_double(point_count),
        z_ptr.read_array_of_double(point_count)
      ]
    end

    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @return [Array<FFI::Pointer>]
    def init_transform_pointers_2d(x_vertices, y_vertices)
      x_ptr = FFI::MemoryPointer.new(:pointer, x_vertices.size)
      x_ptr.write_array_of_double(x_vertices)
      y_ptr = FFI::MemoryPointer.new(:pointer, y_vertices.size)
      y_ptr.write_array_of_double(y_vertices)

      [x_ptr, y_ptr]
    end

    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @return [Array<FFI::Pointer>]
    def init_transform_pointers_3d(x_vertices, y_vertices, z_vertices)
      x_ptr, y_ptr = init_transform_pointers_2d(x_vertices, y_vertices)
      z_ptr = FFI::MemoryPointer.new(:pointer, z_vertices.size)
      z_ptr.write_array_of_double(z_vertices)

      [x_ptr, y_ptr, z_ptr]
    end
  end
end
