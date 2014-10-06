require_relative '../ffi/ogr'

module OGR
  class CoordinateTransformation
    include FFI::GDAL

    # @param source_srs [OGR::SpatialReference, FFI::Pointer]
    # @param destination_srs [OGR::SpatialReference, FFI::Pointer]
    # @return [OGR::CoordinateTransformation]
    def self.create(source_srs, destination_srs)
      source_ptr = if source_srs.is_a?(OGR::SpatialReference)
        source_srs.c_pointer
      else
        source_srs
      end

      destination_ptr = if destination_srs.is_a?(OGR::SpatialReference)
        destination_srs.c_pointer
      else
        destination_srs
      end

      ct_ptr = FFI::GDAL::OCTNewCoordinateTransformation(source_ptr, destination_ptr)

      new(ct_ptr)
    end

    # @param coordinate_transformation [OGR::CoordinateTransformation,
    #   FFI::Pointer]
    def initialize(coordinate_transformation)
      @ogr_layer_pointer = if coordinate_transformation.is_a? OGR::CoordinateTransformation
        coordinate_transformation.c_pointer
      else
        coordinate_transformation
      end

      close_me = -> { OCTDestroyCoordinateTransformation(@ogr_layer_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @ogr_layer_pointer
    end

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

      OCTTransform(@ogr_layer_pointer, point_count, x_ptr, y_ptr, z_ptr)
    end
  end
end
