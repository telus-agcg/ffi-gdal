# frozen_string_literal: true

require 'uri'
require_relative '../gdal'
require_relative '../ogr'
require_relative 'major_object'
require_relative 'dataset_mixins/extensions'
require_relative 'dataset_mixins/matching'
require_relative 'dataset_mixins/algorithm_methods'
require_relative 'dataset_mixins/warp_methods'

module GDAL
  # A set of associated raster bands and info common to them all.  It's also
  # responsible for the georeferencing transform and coordinate system
  # definition of all bands.
  class Dataset
    include MajorObject
    include DatasetMixins::Extensions
    include DatasetMixins::Matching
    include DatasetMixins::AlgorithmMethods
    include DatasetMixins::WarpMethods
    include GDAL::Logger

    ACCESS_FLAGS = {
      'r' => :GA_ReadOnly,
      'w' => :GA_Update
    }.freeze

    # @param path [String] Path to the file that contains the dataset.  Can be
    #   a local file or a URL.
    # @param access_flag [String] 'r' or 'w'.
    # @param shared_open [Boolean] Whether or not to open using GDALOpenShared
    #   vs GDALOpen. Defaults to +true+.
    def self.open(path, access_flag, shared_open = true)
      ds = new(path, access_flag, shared_open)

      if block_given?
        result = yield ds
        ds.close
        result
      else
        ds
      end
    end

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
    def initialize(path_or_pointer, access_flag, shared_open = true)
      @c_pointer =
        if path_or_pointer.is_a? String
          file_path = begin
            uri = URI.parse(path_or_pointer)
            uri.scheme.nil? ? ::File.expand_path(path_or_pointer) : path_or_pointer
          rescue URI::InvalidURIError
            path_or_pointer
          end

          if shared_open
            FFI::GDAL::GDAL.GDALOpenShared(file_path, ACCESS_FLAGS[access_flag])
          else
            FFI::GDAL::GDAL.GDALOpen(file_path, ACCESS_FLAGS[access_flag])
          end
        else
          path_or_pointer
        end

      raise OpenFailure, path_or_pointer if @c_pointer.null?

      @geo_transform = nil
      @spatial_reference = nil
      @raster_bands = Array.new(raster_count)
    end

    # Close the dataset.
    def close
      return unless @c_pointer

      FFI::GDAL::GDAL.GDALClose(@c_pointer)
      @c_pointer = nil
    end

    # @return [Symbol]
    def access_flag
      flag = FFI::GDAL::GDAL.GDALGetAccess(@c_pointer)

      FFI::GDAL::GDAL::Access[flag]
    end

    # @return [GDAL::Driver] The driver to be used for working with this
    #   dataset.
    def driver
      driver_ptr = FFI::GDAL::GDAL.GDALGetDatasetDriver(@c_pointer)

      Driver.new(driver_ptr)
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

    # @return [Fixnum]
    def raster_x_size
      return nil if null?

      FFI::GDAL::GDAL.GDALGetRasterXSize(@c_pointer)
    end

    # @return [Fixnum]
    def raster_y_size
      return nil if null?

      FFI::GDAL::GDAL.GDALGetRasterYSize(@c_pointer)
    end

    # @return [Fixnum]
    def raster_count
      return 0 if null?

      FFI::GDAL::GDAL.GDALGetRasterCount(@c_pointer)
    end

    # @param raster_index [Fixnum]
    # @return [GDAL::RasterBand]
    def raster_band(raster_index)
      if raster_index > raster_count
        raise GDAL::InvalidRasterBand, "Invalid raster band number '#{raster_index}'. Must be <= #{raster_count}"
      end

      raster_band_ptr = FFI::GDAL::GDAL.GDALGetRasterBand(@c_pointer, raster_index)

      GDAL::RasterBand.new(raster_band_ptr)
    end

    # @param type [FFI::GDAL::GDAL::DataType]
    # @param options [Hash]
    # @return [GDAL::RasterBand, nil]
    def add_band(type, **options)
      options_ptr = GDAL::Options.pointer(options)
      FFI::GDAL::GDAL.GDALAddBand(@c_pointer, type, options_ptr)

      raster_band(raster_count)
    end

    # Adds a mask band to the dataset.
    #
    # @param flags [Array<Symbol>, Symbol] Any of the :GMF symbols.
    # @return [Boolean]
    def create_mask_band(*flags)
      flag_value = parse_mask_flag_symbols(flags)

      !!FFI::GDAL::GDAL.GDALCreateDatasetMaskBand(@c_pointer, flag_value)
    end

    # @return [String]
    def projection
      FFI::GDAL::GDAL.GDALGetProjectionRef(@c_pointer) || ''
    end

    # @param new_projection [String]
    # @return [Boolean]
    def projection=(new_projection)
      FFI::GDAL::GDAL.GDALSetProjection(@c_pointer, new_projection.to_s)
    end

    # @return [GDAL::GeoTransform]
    def geo_transform
      return @geo_transform if @geo_transform

      geo_transform_pointer = GDAL::GeoTransform.new_pointer
      geo_transform_pointer.autorelease = false
      FFI::GDAL::GDAL.GDALGetGeoTransform(@c_pointer, geo_transform_pointer)

      @geo_transform = GeoTransform.new(geo_transform_pointer)
    end

    # @param new_transform [GDAL::GeoTransform, FFI::Pointer]
    # @return [GDAL::GeoTransform]
    def geo_transform=(new_transform)
      new_pointer = GDAL._pointer(GDAL::GeoTransform, new_transform)
      FFI::GDAL::GDAL.GDALSetGeoTransform(@c_pointer, new_pointer)

      @geo_transform = new_transform.is_a?(FFI::Pointer) ? GeoTransform.new(new_pointer) : new_transform
    end

    # @return [Fixnum]
    def gcp_count
      return 0 if null?

      FFI::GDAL::GDAL.GDALGetGCPCount(@c_pointer)
    end

    # @return [String]
    def gcp_projection
      return '' if null?

      FFI::GDAL::GDAL.GDALGetGCPProjection(@c_pointer)
    end

    # @return [FFI::GDAL::GCP]
    def gcps
      return FFI::GDAL::GCP.new if null?

      gcp_array_pointer = FFI::GDAL::GDAL.GDALGetGCPs(@c_pointer)

      if gcp_array_pointer.null?
        FFI::GDAL::GCP.new
      else
        FFI::GDAL::GCP.new(gcp_array_pointer)
      end
    end

    # @param resampling [String, Symbol] One of:
    #   * :nearest          - Nearest neighbor resampling
    #   * :gauss            - Gaussian kernel resampling
    #   * :cubic            - Cubic convolution resampling
    #   * :average          - Average of all non-NODATA
    #   * :mode             - Selects the value that occurs most often
    #   * :average_magphase - Averages complex data in mag/phase space
    #   * :none
    # @param overview_levels [Array<Fixnum>] The list of overview decimation
    #   factors to build.
    # @param band_numbers [Array<Fixnum>] The numbers of the bands to build
    #   overviews from.
    # @see http://www.gdal.org/gdaladdo.html
    def build_overviews(resampling, overview_levels, band_numbers: nil, &progress)
      resampling_string = if resampling.is_a? String
                            resampling.upcase
                          elsif resampling.is_a? Symbol
                            resampling.to_s.upcase
                          end

      overview_levels_ptr = FFI::MemoryPointer.new(:int, overview_levels.size)
      overview_levels_ptr.write_array_of_int(overview_levels)
      band_numbers_ptr, band_count = band_numbers_args(band_numbers)

      !!FFI::GDAL::GDAL.GDALBuildOverviews(
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

    # @param access_flag [String] 'r' or 'w'.
    # @param buffer [FFI::MemoryPointer] The pointer to the data to read/write
    #   to the dataset.
    # @param x_size [Fixnum] If not given, uses {{#raster_x_size}}.
    # @param y_size [Fixnum] If not given, uses {{#raster_y_size}}.
    # @param x_offset [Fixnum] The pixel number in the line to start operating
    #   on. Note that when using this, {#x_size} - +x_offset+ should be >= 0,
    #   otherwise this means you're telling the method to read past the end of
    #   the line. Defaults to 0.
    # @param y_offset [Fixnum] The line number to start operating on. Note that
    #   when using this, {#y_size} - +y_offset+ should be >= 0, otherwise this
    #   means you're telling the method to read more lines than the raster has.
    #   Defaults to 0.
    # @param buffer_x_size [Fixnum] The width of the buffer image in which to
    #   read/write the raster data into/from. Typically this should be the same
    #   size as +x_size+; if it's different, GDAL will resample accordingly.
    # @param buffer_y_size [Fixnum] The height of the buffer image in which to
    #   read/write the raster data into/from. Typically this should be the same
    #   size as +y_size+; if it's different, GDAL will resample accordingly.
    # @param buffer_data_type [FFI::GDAL::GDAL::DataType] Can be used to convert the
    #   data to a different type. You must account for this when reading/writing
    #   to/from your buffer--your buffer size must be +buffer_x_size+ *
    #   +buffer_y_size+.
    # @param band_numbers [Array<Fixnum>] The numbers of the bands to do IO on.
    # @param pixel_space [Fixnum] The byte offset from the start of one pixel
    #   value in the buffer to the start of the next pixel value within a line.
    #   If defaulted (0), the size of +buffer_data_type+ is used.
    # @param line_space [Fixnum] The byte offset from the start of one line in
    #   the buffer to the start of the next. If defaulted (0), the size of
    #   +buffer_data_type+ * +buffer_x_size* is used.
    # @param band_space [Fixnum] The byte offset from the start of one band's
    #   data to the start of the next. If defaulted (0), the size of
    #   +line_space+ * +buffer_y_size* is used.
    def raster_io(access_flag, buffer = nil,
      x_size: nil, y_size: nil, x_offset: 0, y_offset: 0,
      buffer_x_size: nil, buffer_y_size: nil, buffer_data_type: nil,
      band_numbers: nil,
      pixel_space: 0, line_space: 0, band_space: 0)
      x_size ||= raster_x_size
      y_size ||= raster_y_size
      buffer_x_size ||= x_size
      buffer_y_size ||= y_size
      buffer_data_type ||= raster_band(1).data_type
      band_numbers_ptr, band_count = band_numbers_args(band_numbers)
      band_count = raster_count if band_count.zero?

      buffer ||= GDAL._pointer_from_data_type(buffer_data_type, buffer_x_size * buffer_y_size * band_count)

      gdal_access_flag = GDAL._gdal_access_flag(access_flag)

      min_buffer_size = valid_min_buffer_size(buffer_data_type, buffer_x_size, buffer_y_size)

      unless buffer.size >= min_buffer_size
        raise GDAL::BufferTooSmall, "Buffer size (#{buffer.size}) too small (#{min_buffer_size})"
      end

      FFI::GDAL::GDAL::GDALDatasetRasterIO(
        @c_pointer,                     # hDS
        gdal_access_flag,               # eRWFlag
        x_offset,                       # nXOff
        y_offset,                       # nYOff
        x_size,                         # nXSize
        y_size,                         # nYSize
        buffer,                         # pData
        buffer_x_size,                  # nBufXSize
        buffer_y_size,                  # nBufYSize
        buffer_data_type,               # eBufType
        band_count,                     # nBandCount
        band_numbers_ptr,               # panBandMap (WTH is this?)
        pixel_space,                    # nPixelSpace
        line_space,                     # nLineSpace
        band_space                      # nBandSpace
      )

      buffer
    end

    private

    # Lets you pass in :GMF_ symbols that represent mask band flags and bitwise
    # ors them.
    #
    # @param flags [Symbol]
    # @return [Fixnum]
    def parse_mask_flag_symbols(*flags)
      flags.reduce(0) do |result, flag|
        result |= case flag
                  when :GMF_ALL_VALID then 0x01
                  when :GMF_PER_DATASET then 0x02
                  when :GMF_PER_ALPHA then 0x04
                  when :GMF_NODATA then 0x08
                  else 0
                  end
      end
    end

    # @param buffer_data_type [FFI::GDAL::GDAL::DataType]
    # @param x_buffer_size [Fixnum]
    # @param y_buffer_size [Fixnum]
    # @return [Fixnum]
    def valid_min_buffer_size(buffer_data_type, x_buffer_size, y_buffer_size)
      data_type_bytes = GDAL::DataType.size(buffer_data_type) / 8

      data_type_bytes * x_buffer_size * y_buffer_size
    end

    # Makes a pointer of +band_numbers+.
    #
    # @param band_numbers [Array<Fixnum>]
    # @return [Array<FFI::Pointer, Fixnum>]
    def band_numbers_args(band_numbers)
      if band_numbers
        band_count = band_numbers.size
        band_numbers_ptr = FFI::MemoryPointer.new(:int, band_count)
        band_numbers_ptr.write_array_of_int(band_numbers)
      else
        band_numbers_ptr = nil
        band_count = 0
      end

      [band_numbers_ptr, band_count]
    end
  end
end
