module GDAL
  class WarpOperation
    def initialize(warp_options)
      @warp_operation_pointer = FFI::GDAL.GDALCreateWarpOperation(warp_options.ptr)
    end

    def c_pointer
      @warp_operation_pointer
    end

    def destroy!
      FFI::GDAL.GDALDestroyWarpOperation(@warp_operation_pointer)
    end

    # @param x_offset [Fixnum] X offset of the destination image.
    # @param y_offset [Fixnum] Y offset of the destination image.
    # @param x_size [Fixnum] X size (width) of the destination image.
    # @param y_size [Fixnum] Y size (height) of the destination image.
    def chunk_and_warp_image(x_offset, y_offset, x_size, y_size)
      cpl_err = FFI::GDAL.GDALChunkAndWarpImage(@warp_operation_pointer,
        x_offset,
        y_offset,
        x_size,
        y_size)

      cpl_err.to_bool
    end

    # @param x_offset [Fixnum] X offset of the destination image.
    # @param y_offset [Fixnum] Y offset of the destination image.
    # @param x_size [Fixnum] X size (width) of the destination image.
    # @param y_size [Fixnum] Y size (height) of the destination image.
    # @todo Implement
    def chunk_and_warp_multi(x_offset, y_offset, x_size, y_size)
      raise NotImplementedError, '#chunk_and_warp_multi not yet implemented.'

      FFI::GDAL.GDALChunkAndWarpMulti(@warp_operation_pointer,
      )
    end

    # @param destination_x_offset [Fixnum] X offset of the destination image.
    # @param destination_y_offset [Fixnum] Y offset of the destination image.
    # @param destination_x_size [Fixnum] X size (width) of the destination image.
    # @param destination_y_size [Fixnum] Y size (height) of the destination image.
    # @param source_x_offset [Fixnum] X offset of the source image.
    # @param source_y_offset [Fixnum] Y offset of the source image.
    # @param source_x_size [Fixnum] X size (width) of the source image.
    # @param source_y_size [Fixnum] Y size (height) of the source image.
    def warp_region(destination_x_offset, destination_y_offset,
      destination_x_size, destination_y_size,
      source_x_offset, source_y_offset,
      source_x_size, source_y_size)
      cpl_err = FFI::GDAL.GDALWarpRegion(@warp_operation_pointer,
        destination_x_offset,
        destination_y_offset,
        destination_x_size,
        destination_y_size,
        source_x_offset,
        source_y_offset,
        source_x_size,
        source_y_size)

      cpl_err.to_bool
    end

    # @param destination_x_offset [Fixnum] X offset of the destination image.
    # @param destination_y_offset [Fixnum] Y offset of the destination image.
    # @param destination_x_size [Fixnum] X size (width) of the destination image.
    # @param destination_y_size [Fixnum] Y size (height) of the destination image.
    # @param buffer [FFI::Pointer]
    # @param data_type [FFI::GDAL::GDALDataType]
    # @param source_x_offset [Fixnum] X offset of the source image.
    # @param source_y_offset [Fixnum] Y offset of the source image.
    # @param source_x_size [Fixnum] X size (width) of the source image.
    # @param source_y_size [Fixnum] Y size (height) of the source image.
    def warp_region_to_buffer(destination_x_offset, destination_y_offset,
      destination_x_size, destination_y_size,
      buffer, data_type,
      source_x_offset, source_y_offset,
      source_x_size, source_y_size)
      cpl_err = FFI::GDAL.GDALWarpRegionToBuffer(@warp_operation_pointer,
        destination_x_offset,
        destination_y_offset,
        destination_x_size,
        destination_y_size,
        buffer,
        data_type,
        source_x_offset,
        source_y_offset,
        source_x_size,
        source_y_size)

      cpl_err.to_bool
    end
  end
end
