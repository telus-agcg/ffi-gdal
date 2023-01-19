# frozen_string_literal: true

require_relative "../dataset/internal_functions"

module GDAL
  class Dataset
    module RasterBandMethods
      # Lets you pass in :GMF_ symbols that represent mask band flags and bitwise
      # ors them.
      #
      # @param flags [Symbol]
      # @return [Integer]
      def self.parse_mask_flag_symbols(*flags)
        flags.reduce(0) do |result, flag|
          result | case flag
                   when :GMF_ALL_VALID then 0x01
                   when :GMF_PER_DATASET then 0x02
                   when :GMF_PER_ALPHA then 0x04
                   when :GMF_NODATA then 0x08
                   else 0
                   end
        end
      end

      # @param buffer_data_type [FFI::GDAL::GDAL::DataType]
      # @param x_buffer_size [Integer]
      # @param y_buffer_size [Integer]
      # @return [Integer]
      def self.valid_min_buffer_size(buffer_data_type, x_buffer_size, y_buffer_size)
        data_type_bytes = GDAL::DataType.size(buffer_data_type) / 8

        data_type_bytes * x_buffer_size * y_buffer_size
      end

      # @return [Integer, nil]
      def raster_x_size
        return nil if null?

        FFI::GDAL::GDAL.GDALGetRasterXSize(@c_pointer)
      end

      # @return [Integer, nil]
      def raster_y_size
        return nil if null?

        FFI::GDAL::GDAL.GDALGetRasterYSize(@c_pointer)
      end

      # @return [Integer]
      def raster_count
        return 0 if null?

        FFI::GDAL::GDAL.GDALGetRasterCount(@c_pointer)
      end

      # @param raster_index [Integer]
      # @return [GDAL::RasterBand]
      def raster_band(raster_index)
        if raster_index > raster_count
          raise GDAL::InvalidRasterBand, "Invalid raster band number '#{raster_index}'. Must be <= #{raster_count}"
        end

        raster_band_ptr = FFI::GDAL::GDAL.GDALGetRasterBand(@c_pointer, raster_index)
        raster_band_ptr.autorelease = false

        GDAL::RasterBand.new(raster_band_ptr, self)
      end

      # @param type [FFI::GDAL::GDAL::DataType]
      # @param options [Hash]
      # @raise [GDAL::Error]
      # @return [GDAL::RasterBand, nil]
      def add_band(type, **options)
        options_ptr = GDAL::Options.pointer(options)

        GDAL::CPLErrorHandler.manually_handle("Unable to add band") do
          FFI::GDAL::GDAL.GDALAddBand(@c_pointer, type, options_ptr)
        end

        raster_band(raster_count)
      end

      # Adds a mask band to the dataset.
      #
      # @param flags [Array<Symbol>, Symbol] Any of the :GMF symbols.
      # @raise [GDAL::Error]
      def create_mask_band(*flags)
        flag_value = RasterBandMethods.parse_mask_flag_symbols(flags)

        GDAL::CPLErrorHandler.manually_handle("Unable to create Dataset mask band") do
          FFI::GDAL::GDAL.GDALCreateDatasetMaskBand(@c_pointer, flag_value)
        end
      end

      # @param access_flag [String] 'r' or 'w'.
      # @param buffer [FFI::MemoryPointer] The pointer to the data to read/write
      #   to the dataset.
      # @param x_size [Integer] If not given, uses {{#raster_x_size}}.
      # @param y_size [Integer] If not given, uses {{#raster_y_size}}.
      # @param x_offset [Integer] The pixel number in the line to start operating
      #   on. Note that when using this, +x_size+ - +x_offset+ should be >= 0,
      #   otherwise this means you're telling the method to read past the end of
      #   the line. Defaults to 0.
      # @param y_offset [Integer] The line number to start operating on. Note that
      #   when using this, +y_size+ - +y_offset+ should be >= 0, otherwise this
      #   means you're telling the method to read more lines than the raster has.
      #   Defaults to 0.
      # @param buffer_x_size [Integer] The width of the buffer image in which to
      #   read/write the raster data into/from. Typically this should be the same
      #   size as +x_size+; if it's different, GDAL will resample accordingly.
      # @param buffer_y_size [Integer] The height of the buffer image in which to
      #   read/write the raster data into/from. Typically this should be the same
      #   size as +y_size+; if it's different, GDAL will resample accordingly.
      # @param buffer_data_type [FFI::GDAL::GDAL::DataType] Can be used to convert the
      #   data to a different type. You must account for this when reading/writing
      #   to/from your buffer--your buffer size must be +buffer_x_size+ *
      #   +buffer_y_size+.
      # @param band_numbers [Array<Integer>] The numbers of the bands to do IO on.
      #   Pass +nil+ defaults to choose the first band.
      # @param pixel_space [Integer] The byte offset from the start of one pixel
      #   value in the buffer to the start of the next pixel value within a line.
      #   If defaulted (0), the size of +buffer_data_type+ is used.
      # @param line_space [Integer] The byte offset from the start of one line in
      #   the buffer to the start of the next. If defaulted (0), the size of
      #   +buffer_data_type+ * +buffer_x_size* is used.
      # @param band_space [Integer] The byte offset from the start of one band's
      #   data to the start of the next. If defaulted (0), the size of
      #   +line_space+ * +buffer_y_size* is used.
      # @return [FFI::MemoryPointer] The buffer that was passed in.
      # @raise [GDAL::Error] On failure.
      # rubocop:disable Metrics/ParameterLists
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

        band_numbers_ptr, band_count = InternalFunctions.band_numbers_args(band_numbers)
        band_count = raster_count if band_count.zero?

        buffer ||= GDAL._pointer_from_data_type(buffer_data_type, buffer_x_size * buffer_y_size * band_count)

        gdal_access_flag = GDAL._gdal_access_flag(access_flag)

        min_buffer_size = RasterBandMethods.valid_min_buffer_size(buffer_data_type, buffer_x_size, buffer_y_size)

        unless buffer.size >= min_buffer_size
          raise GDAL::BufferTooSmall, "Buffer size (#{buffer.size}) too small (#{min_buffer_size})"
        end

        GDAL::CPLErrorHandler.manually_handle("Unable to perform raster band IO") do
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
        end

        buffer
      end
      # rubocop:enable Metrics/ParameterLists
    end
  end
end
