# frozen_string_literal: true

module GDAL
  class Dataset
    module ClassMethods
      # @param path [String] Path to the file that contains the dataset.  Can be
      #   a local file or a URL.
      # @param access_flag [String] 'r' or 'w'.
      # @param shared [Boolean] Whether or not to open using GDALOpenShared
      #   vs GDALOpen. Defaults to +true+.
      def open(path, access_flag, shared: true)
        ds = new(path, access_flag, shared_open: shared)

        if block_given?
          result = yield ds
          ds.close
          result
        else
          ds
        end
      end

      # Copy all dataset raster data.
      #
      # This function copies the complete raster contents of one dataset to
      # another similarly configured dataset. The source and destination dataset
      # must have the same number of bands, and the same width and height. The
      # bands do not have to have the same data type.
      #
      # This function is primarily intended to support implementation of driver
      # specific CreateCopy() functions. It implements efficient copying, in
      # particular "chunking" the copy in substantial blocks and, if appropriate,
      # performing the transfer in a pixel interleaved fashion.
      #
      # @param source [GDAL::Dataset, FFI::Pointer]
      # @param destination [GDAL::Dataset, FFI::Pointer]
      # @param options [Hash]
      # @option options interleave: 'pixel'
      # @option options compressed: true
      # @option options skip_holes: true
      # @param progress_function [Proc]
      # @raise [GDAL::Error]
      def copy_whole_raster(source, destination, options = {}, progress_function = nil)
        source_ptr = GDAL._pointer(GDAL::Dataset, source, autorelease: false)
        dest_ptr = GDAL._pointer(GDAL::Dataset, destination, autorelease: false)
        options_ptr = GDAL::Options.pointer(options)

        GDAL::CPLErrorHandler.manually_handle("Unable to copy whole raster") do
          FFI::GDAL::GDAL.GDALDatasetCopyWholeRaster(source_ptr, dest_ptr, options_ptr, progress_function, nil)
        end
      end

      # @param dataset [GDAL::Dataset]
      # @return [FFI::AutoPointer]
      def new_pointer(dataset, warn_on_nil: true)
        ptr = GDAL._pointer(GDAL::Dataset, dataset, warn_on_nil: warn_on_nil, autorelease: false)

        FFI::AutoPointer.new(ptr, Dataset.method(:release))
      end

      # @param pointer [FFI::Pointer]
      def release(pointer)
        return unless pointer && !pointer.null?

        FFI::GDAL::GDAL.GDALClose(pointer)
      end
    end
  end
end
