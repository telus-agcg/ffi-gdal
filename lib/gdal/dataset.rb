# frozen_string_literal: true

require_relative "../gdal"
require_relative "../ogr"
require_relative "major_object"
require_relative "dataset/internal_functions"
require_relative "dataset/class_methods"
require_relative "dataset/accessors"
require_relative "dataset/raster_band_methods"
require_relative "dataset/matching"
require_relative "dataset/algorithm_methods"
require_relative "dataset/warp_methods"

module GDAL
  # A set of associated raster bands and info common to them all.  It's also
  # responsible for the georeferencing transform and coordinate system
  # definition of all bands.
  class Dataset
    extend Dataset::ClassMethods

    include MajorObject
    include Dataset::Accessors
    include Dataset::RasterBandMethods
    include Dataset::Matching
    include Dataset::AlgorithmMethods
    include Dataset::WarpMethods
    include GDAL::Logger

    ACCESS_FLAGS = {
      "r" => :GA_ReadOnly,
      "w" => :GA_Update
    }.freeze

    #---------------------------------------------------------------------------
    # Instance methods
    #---------------------------------------------------------------------------

    # @return [FFI::Pointer] Pointer to the GDALDatasetH that's represented by
    #   this Ruby object.
    attr_reader :c_pointer

    # @param path_or_pointer [String, FFI::Pointer] Path to the file that
    #   contains the dataset or a pointer to the dataset. If it's a path, it can
    #   be a local file or a URL.
    # @param access_flag [String] 'r' or 'w'.
    # @param shared_open [Boolean] Whether or not to open using GDALOpenShared
    #   vs GDALOpen. Defaults to +true+.
    def initialize(path_or_pointer, access_flag, shared_open: true)
      @c_pointer =
        if path_or_pointer.is_a? String
          if shared_open
            FFI::GDAL::GDAL.GDALOpenShared(path_or_pointer, ACCESS_FLAGS[access_flag])
          else
            FFI::GDAL::GDAL.GDALOpen(path_or_pointer, ACCESS_FLAGS[access_flag])
          end
        else
          path_or_pointer
        end

      raise OpenFailure, path_or_pointer if @c_pointer.null?

      @geo_transform = nil
      @spatial_reference = nil
    end

    # Close the dataset.
    def close
      Dataset.release(@c_pointer)

      @c_pointer = nil
    end

    # @return [Symbol]
    def access_flag
      flag = FFI::GDAL::GDAL.GDALGetAccess(@c_pointer)

      FFI::GDAL::GDAL::Access[flag]
    end

    # Fetches all files that form the dataset.
    # @return [Array<String>]
    def file_list
      list_pointer = FFI::GDAL::GDAL.GDALGetFileList(@c_pointer)
      return [] if list_pointer.null?

      file_list = list_pointer.get_array_of_string(0)
      FFI::CPL::String.CSLDestroy(list_pointer)

      file_list
    end

    # Flushes all write-cached data to disk.
    def flush_cache
      FFI::GDAL::GDAL.GDALFlushCache(@c_pointer)
    end

    # @param resampling [String, Symbol] One of:
    #   * :nearest          - Nearest neighbor resampling
    #   * :gauss            - Gaussian kernel resampling
    #   * :cubic            - Cubic convolution resampling
    #   * :average          - Average of all non-NODATA
    #   * :mode             - Selects the value that occurs most often
    #   * :average_magphase - Averages complex data in mag/phase space
    #   * :none
    # @param overview_levels [Array<Integer>] The list of overview decimation
    #   factors to build.
    # @param band_numbers [Array<Integer>] The numbers of the bands to build
    #   overviews from.
    # @see http://www.gdal.org/gdaladdo.html
    # @raise [GDAL::Error]
    def build_overviews(resampling, overview_levels, band_numbers: nil, &progress)
      resampling_string = case resampling
                          when String
                            resampling.upcase
                          when Symbol
                            resampling.to_s.upcase
                          end

      overview_levels_ptr = FFI::MemoryPointer.new(:int, overview_levels.size)
      overview_levels_ptr.write_array_of_int(overview_levels)
      band_numbers_ptr, band_count = InternalFunctions.band_numbers_args(band_numbers)

      GDAL::CPLErrorHandler.manually_handle("Unable to build overviews") do
        FFI::GDAL::GDAL.GDALBuildOverviews(
          @c_pointer,
          resampling_string,
          overview_levels.size,
          overview_levels_ptr,
          band_count,
          band_numbers_ptr,
          progress,
          nil
        )
      end
    end
  end
end
