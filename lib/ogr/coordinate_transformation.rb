require 'narray'
require_relative '../ffi/ogr'

module OGR
  class CoordinateTransformation

    # @param source_srs [OGR::SpatialReference, FFI::Pointer]
    # @param destination_srs [OGR::SpatialReference, FFI::Pointer]
    # @return [OGR::CoordinateTransformation]
    def self.create(source_srs, destination_srs)
      source_ptr = GDAL._pointer(OGR::SpatialReference, source_srs)
      destination_ptr = GDAL._pointer(OGR::SpatialReference, destination_srs)
      ct_ptr = FFI::GDAL.OCTNewCoordinateTransformation(source_ptr, destination_ptr)
      return nil if ct_ptr.null?

      source = if source_srs.is_a?(OGR::SpatialReference)
        source_srs
      else
        OGR::SpatialReference.new(source_srs)
      end

      destination = if destination_srs.is_a?(OGR::SpatialReference)
        destination_srs
      else
        OGR::SpatialReference.new(destination_srs)
      end

      new(ct_ptr, source, destination)
    end

    # @param proj4_source [String]
    # @return [String]
    def self.proj4_normalize(proj4_source)
      FFI::GDAL.OCTProj4Normalize(proj4_source)
    end

    # @return [OGR::SpatialReference]
    attr_reader :source_coordinate_system

    # @return [OGR::SpatialReference]
    attr_reader :destination_coordinate_system

    # @param coordinate_transformation [OGR::CoordinateTransformation,
    #   FFI::Pointer]
    def initialize(coordinate_transformation, source, destination)
      @transformation_pointer = GDAL._pointer(OGR::CoordinateTransformation,
        coordinate_transformation)
      @source_coordinate_system = source
      @destination_coordinate_system = destination

      close_me = -> { destroy! }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @transformation_pointer
    end

    # Deletes the object and deallocates all related resources.
    def destroy!
      FFI::GDAL.OCTDestroyCoordinateTransformation(@transformation_pointer)
    end

    # Transforms points in the +source_srs+ space to points in the
    # +destination_space+ (given in .create).
    #
    # @param x_vertices [Array<Float>]
    # @param y_vertices [Array<Float>]
    # @param z_vertices [Array<Float>]
    # @return [Array<Array<Float>,Array<Float>,Array<Float>>] [[x1, y1], [x2,
    #   y2], etc]
    def transform(x_vertices, y_vertices, z_vertices=[])
      x_ptr = FFI::MemoryPointer.new(:pointer, x_vertices.size)
      x_ptr.write_array_of_double(x_vertices)
      y_ptr = FFI::MemoryPointer.new(:pointer, y_vertices.size)
      y_ptr.write_array_of_double(y_vertices)

      if z_vertices.empty?
        z_ptr = nil
      else
        z_ptr = FFI::MemoryPointer.new(:pointer, z_vertices.size)
        z_ptr.write_array_of_double(z_vertices)
      end

      point_count = x_vertices.size + y_vertices.size + z_vertices.size

      result = FFI::GDAL.OCTTransform(@transformation_pointer, point_count,
        x_ptr, y_ptr, z_ptr)

      # maybe this should raise?
      return false unless result

      x_vals = x_ptr.read_array_of_double
      y_vals = y_ptr.read_array_of_double
      z_vals = z_ptr.read_array_of_double unless z_vertices.empty?

      points = if z_vertices.empty?
                 NArray[x_vals, y_vals]
               else
                 NArray[x_vals, y_vals, z_vals]
               end

      points.rot90(3).to_a
    end
  end
end
