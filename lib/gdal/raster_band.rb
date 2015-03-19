require_relative '../ffi/gdal'
require_relative '../ffi/ogr/api'
require_relative 'raster_band_mixins/algorithm_methods'
require_relative 'raster_band_mixins/extensions'
require_relative 'color_table'
require_relative 'major_object'
require_relative 'raster_attribute_table'
require 'narray'

module GDAL
  class RasterBand
    include MajorObject
    include GDAL::Logger
    include RasterBandMixins::AlgorithmMethods
    include RasterBandMixins::Extensions

    ALL_VALID = 0x01
    PER_DATASET = 0x02
    ALPHA = 0x04
    NODATA = 0x08

    # @param raster_band [GDAL::RasterBand, FFI::Pointer]
    def initialize(raster_band)
      @raster_band_pointer = GDAL._pointer(GDAL::RasterBand, raster_band)
    end

    def c_pointer
      @raster_band_pointer
    end

    # @return [Boolean]
    def flush_cache
      !!FFI::GDAL.GDALFlushRasterCache(@raster_band_pointer)
    end

    # The raster width in pixels.
    #
    # @return [Fixnum]
    def x_size
      return nil if null?

      FFI::GDAL.GDALGetRasterBandXSize(@raster_band_pointer)
    end

    # The raster height in pixels.
    #
    # @return [Fixnum]
    def y_size
      return nil if null?

      FFI::GDAL.GDALGetRasterBandYSize(@raster_band_pointer)
    end

    # The type of access to the raster band this object currently has.
    #
    # @return [Symbol] Either :GA_Update or :GA_ReadOnly.
    def access_flag
      return nil if null?

      FFI::GDAL.GDALGetRasterAccess(@raster_band_pointer)
    end

    # The number of band within the associated dataset that this band
    # represents.
    #
    # @return [Fixnum]
    def number
      return nil if null?

      FFI::GDAL.GDALGetBandNumber(@raster_band_pointer)
    end

    # @return [GDAL::Dataset, nil]
    def dataset
      return @dataset if @dataset

      dataset_ptr = FFI::GDAL.GDALGetBandDataset(@raster_band_pointer)
      return nil if dataset_ptr.null?

      @dataset = GDAL::Dataset.new(dataset_ptr)
    end

    # @return [Symbol] One of FFI::GDAL::ColorInterp.
    def color_interpretation
      FFI::GDAL.GDALGetRasterColorInterpretation(@raster_band_pointer)
    end

    # @param new_color_interp [FFI::GDAL::ColorInterp]
    # @return [Boolean]
    def color_interpretation=(new_color_interp)
      !!FFI::GDAL.GDALSetRasterColorInterpretation(@raster_band_pointer,
        new_color_interp)
    end

    # @return [GDAL::ColorTable]
    def color_table
      gdal_color_table = FFI::GDAL.GDALGetRasterColorTable(@raster_band_pointer)
      return nil if gdal_color_table.null?

      ColorTable.new(gdal_color_table)
    end

    # @param new_color_table [GDAL::ColorTable]
    def color_table=(new_color_table)
      color_table_pointer = GDAL._pointer(GDAL::ColorTable, new_color_table)
      FFI::GDAL.GDALSetRasterColorTable(@raster_band_pointer, color_table_pointer)
    end

    # The pixel data type for this band.
    #
    # @return [Symbol] One of FFI::GDAL::DataType.
    def data_type
      FFI::GDAL.GDALGetRasterDataType(@raster_band_pointer)
    end

    # The natural block size is the block size that is most efficient for
    # accessing the format. For many formats this is simply a whole scanline
    # in which case x is set to #x_size, and y is set to 1.
    #
    # @return [Hash{x => Fixnum, y => Fixnum}]
    def block_size
      x_pointer = FFI::MemoryPointer.new(:int)
      y_pointer = FFI::MemoryPointer.new(:int)
      FFI::GDAL.GDALGetBlockSize(@raster_band_pointer, x_pointer, y_pointer)

      { x: x_pointer.read_int, y: y_pointer.read_int }
    end

    # @return [Array<String>]
    def category_names
      names = FFI::GDAL.GDALGetRasterCategoryNames(@raster_band_pointer)
      return [] if names.null?

      names.get_array_of_string(0)
    end

    # @param names [Array<String>]
    # @return [Boolean]
    def category_names=(names)
      names_pointer = GDAL._string_array_to_pointer(names)

      !!FFI::GDAL.GDALSetRasterCategoryNames(@raster_band_pointer, names_pointer)
    end

    # The no data value for a band is generally a special marker value used to
    # mark pixels that are not valid data. Such pixels should generally not be
    # displayed, nor contribute to analysis operations.
    #
    # @return [Hash{value => Float, is_associated => Boolean}]
    def no_data_value
      associated = FFI::MemoryPointer.new(:bool)
      value = FFI::GDAL.GDALGetRasterNoDataValue(@raster_band_pointer, associated)

      { value: value, is_associated: associated.read_bytes(1).to_bool }
    end

    # Sets the no data value for this band.
    #
    # @param value [Float]
    # @return [Boolean]
    def no_data_value=(value)
      !!FFI::GDAL.GDALSetRasterNoDataValue(@raster_band_pointer, value)
    end

    # @return [Fixnum]
    def overview_count
      FFI::GDAL.GDALGetOverviewCount(@raster_band_pointer)
    end

    # @return [Boolean]
    def arbitrary_overviews?
      FFI::GDAL.GDALHasArbitraryOverviews(@raster_band_pointer).zero? ? false : true
    end

    # @param index [Fixnum] Must be between 0 and (#overview_count - 1).
    # @return [GDAL::RasterBand]
    def overview(index)
      return nil if overview_count.zero?

      overview_pointer = FFI::GDAL.GDALGetOverview(@raster_band_pointer, index)
      return nil if overview_pointer.null?

      self.class.new(overview_pointer)
    end

    # @param desired_samples [Fixnum] The returned band will have at least this
    #   many pixels.
    # @return [GDAL::RasterBand] An optimal overview or the same raster band if
    #   the raster band has no overviews.
    def raster_sample_overview(desired_samples = 0)
      band_pointer = FFI::GDAL.GDALGetRasterSampleOverview(@raster_band_pointer, desired_samples)
      return nil if band_pointer.null?

      self.class.new(band_pointer)
    end

    # @return [GDAL::RasterBand]
    def mask_band
      band_pointer = FFI::GDAL.GDALGetMaskBand(@raster_band_pointer)
      return nil if band_pointer.null?

      self.class.new(band_pointer)
    end

    # @return [Array<Symbol>]
    def mask_flags
      flag_list = FFI::GDAL.GDALGetMaskFlags(@raster_band_pointer).to_s(2).scan(/\d/)
      flags = []

      flag_list.reverse.each_with_index do |flag, i|
        if i == 0 && flag.to_i == 1
          flags << :GMF_ALL_VALID
        elsif i == 1 && flag.to_i == 1
          flags << :GMF_PER_DATASET
        elsif i == 2 && flag.to_i == 1
          flags << :GMF_ALPHA
        elsif i == 3 && flag.to_i == 1
          flags << :GMF_NODATA
        end
      end

      flags
    end

    # @return [Boolean]
    def create_mask_band(flags)
      !!FFI::GDAL.GDALCreateMaskBand(@raster_band_pointer, flags)
    end

    # Fill this band with constant value.  Useful for clearing a band and
    # setting to a default value.
    #
    # @param real_value [Float]
    # @param imaginary_value [Float]
    def fill(real_value, imaginary_value = 0)
      !!FFI::GDAL.GDALFillRaster(@raster_band_pointer, real_value, imaginary_value)
    end

    # Returns minimum, maximum, mean, and standard deviation of all pixel values
    # in this band.
    #
    # @param approx_ok [Boolean] If +true+, stats may be computed based on
    #   overviews or a subset of all tiles.
    # @param force [Boolean] If +false+, stats will only be returned if the
    #   calculating can be done without rescanning the image.
    # @return [Hash{minimum: Float, maximum: Float, mean: Float,
    #   standard_deviation: Float}]
    def statistics(approx_ok = true, force = true)
      min = FFI::MemoryPointer.new(:double)
      max = FFI::MemoryPointer.new(:double)
      mean = FFI::MemoryPointer.new(:double)
      standard_deviation = FFI::MemoryPointer.new(:double)

      handler = GDAL::CPLErrorHandler.new
      handler.on_warning = proc { Hash.new }
      handler.on_none = proc do
        {
          minimum: min.read_double,
          maximum: max.read_double,
          mean: mean.read_double,
          standard_deviation: standard_deviation.read_double
        }
      end

      handler.custom_handle do
        FFI::GDAL.GDALGetRasterStatistics(@raster_band_pointer,
          approx_ok,
          force,
          min,
          max,
          mean,
          standard_deviation)
      end
    end

    # @param approx_ok [Boolean] If +true+, allows for some approximating,
    #   which may speed up calculations.
    # @return [Hash{minimum => Float, maximum => Float, mean => Float,
    #   standard_deviation => Float}]
    def compute_statistics(approx_ok: false, &progress_block)
      min_ptr = FFI::MemoryPointer.new(:double)
      max_ptr = FFI::MemoryPointer.new(:double)
      mean_ptr = FFI::MemoryPointer.new(:double)
      standard_deviation_ptr = FFI::MemoryPointer.new(:double)

      FFI::GDAL::GDALComputeRasterStatistics(
        @raster_band_pointer,                           # hBand
        approx_ok,                                      # bApproxOK
        min_ptr,                                        # pdfMin
        max_ptr,                                        # pdfMax
        mean_ptr,                                       # pdfMean
        standard_deviation_ptr,                         # pdfStdDev
        progress_block,                                 # pfnProgress
        nil                                             # pProgressData
      )

      {
        minimum: min_ptr.read_double,
        maximum: max_ptr.read_double,
        mean: mean_ptr.read_double,
        standard_deviation: standard_deviation_ptr.read_double
      }
    end

    # The raster value scale.  This value (in combination with the #offset
    # value) is used to transform raw pixel values into the units returned by
    # #units. For example this might be used to store elevations in GUInt16
    # bands with a precision of 0.1, and starting from -100.
    #
    # Units value = (raw value * scale) + offset
    #
    # For file formats that don't know this intrinsically a value of one is
    # returned.
    #
    # @return [Hash{value => Float, is_meaningful => Boolean}]
    def scale
      meaningful = FFI::MemoryPointer.new(:bool)
      result = FFI::GDAL.GDALGetRasterScale(@raster_band_pointer, meaningful)

      { value: result, is_meaningful: meaningful.read_bytes(1).to_bool }
    end

    # @param new_scale [Float]
    # @return [Boolean]
    def scale=(new_scale)
      !!FFI::GDAL.GDALSetRasterScale(@raster_band_pointer, new_scale.to_f)
    end

    # This value (in combination with the #scale value) is used to
    # transform raw pixel values into the units returned by #units. For example
    # this might be used to store elevations in GUInt16 bands with a precision
    # of 0.1, and starting from -100.
    #
    # Units value = (raw value * scale) + offset.
    #
    # For file formats that don't know this intrinsically a value of 0.0 is
    # returned.
    #
    # @return [Hash{value => Float, is_meaningful => Boolean}]
    def offset
      meaningful = FFI::MemoryPointer.new(:bool)
      result = FFI::GDAL.GDALGetRasterOffset(@raster_band_pointer, meaningful)

      { value: result, is_meaningful: meaningful.read_bytes(1).to_bool }
    end

    # @param new_offset [Float]
    # @return [Boolean]
    def offset=(new_offset)
      !!FFI::GDAL.GDALSetRasterOffset(@raster_band_pointer, new_offset)
    end

    # @return [String]
    def unit_type
      FFI::GDAL.GDALGetRasterUnitType(@raster_band_pointer)
    end

    # @param new_unit_type [String] "" indicates unknown, "m" is meters, "ft"
    #   is feet; other non-standard values are allowed.
    # @return [Boolean]
    def unit_type=(new_unit_type)
      if defined? FFI::GDAL::GDALSetRasterUnitType
        !!FFI::GDAL.GDALSetRasterUnitType(@raster_band_pointer, new_unit_type)
      else
        warn "GDALSetRasterUnitType is not defined.  Can't call RasterBand#unit_type="
      end
    end

    # @return [GDAL::RasterAttributeTable]
    def default_raster_attribute_table
      rat_pointer = FFI::GDAL.GDALGetDefaultRAT(@raster_band_pointer)
      return nil if rat_pointer.null?

      GDAL::RasterAttributeTable.new(rat_pointer)
    end

    # @return [GDAL::RasterAttributeTable]
    def default_raster_attribute_table=(rat_table)
      rat_table_ptr = GDAL._pointer(GDAL::RasterAttributeTable, rat_table)
      FFI::GDAL.GDALSetDefaultRAT(@raster_band_pointer, rat_table_ptr)
    end

    # Gets the default raster histogram.  Results are returned as a Hash so some
    # metadata about the histogram can be returned.  Example:
    #
    #   {
    #     :minimum => -0.9,
    #     :maximum => 255.9,
    #     :buckets => 256,
    #     :totals => [
    #       3954, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 1, 0,
    #       0, 0, 10, 27, 201, 699, 1766, 3472, 5013, 6464, 7698, 8352,
    #       9039, 10054, 11378, 13132, 14377, 14371, 14221, 14963, 14740,
    #       14379, 13724, 12938, 11318, 9828, 8504, 7040, 5700, 4890,
    #       4128, 3276, 2749, 2322, 1944, 1596, 1266, 1050, 784, 663,
    #       547, 518, 367, 331, 309, 279, 178, 169, 162, 149, 109, 98,
    #       90, 89, 82, 85, 74, 75, 42, 40, 39, 35, 39, 36, 36, 27, 20,
    #       12, 13, 19, 16, 12, 11, 6, 6, 8, 12, 6, 8, 11, 3, 7, 9, 2,
    #       5, 2, 5, 1, 4, 0, 0, 1, 0, 1, 2, 1, 0, 2, 1, 0, 0, 1, 0, 1,
    #       1, 1, 0, 2, 1, 2, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    #       0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
    #     ]
    #   }
    #
    # Also, you can pass a block to get status on the processing.  Conforms to
    # FFI::GDAL::GDALProgressFunc.
    #
    # @param force [Boolean] Forces the computation of the histogram.  If
    #   +false+ and the default histogram isn't available, this returns nil.
    # @param block [Proc] No required, but can be used to output progress info
    #   during processing.
    #
    # @yieldparam completion [Float] The ration completed as a decimal.
    # @yieldparam message [String] Message string to display.
    #
    # @return [Hash{minimum => Float, maximum => Float, buckets => Fixnum,
    #   totals => Array<Fixnum>}] Returns +nil+ if no default histogram is
    #   available.
    def default_histogram(force = false, &block)
      min_pointer = FFI::MemoryPointer.new(:double)
      max_pointer = FFI::MemoryPointer.new(:double)
      buckets_pointer = FFI::MemoryPointer.new(:int)
      histogram_pointer = FFI::MemoryPointer.new(:pointer)
      progress_proc = block || nil

      handler = GDAL::CPLErrorHandler.new
      handler.on_warning = proc { nil }
      handler.on_none = proc do
        min = min_pointer.read_double
        max = max_pointer.read_double
        buckets = buckets_pointer.read_int

        totals = if buckets.zero?
                   []
                 else
                   histogram_pointer.get_pointer(0).read_array_of_int(buckets)
                 end

        {
          minimum: min,
          maximum: max,
          buckets: buckets,
          totals: totals
        }
      end

      handler.custom_handle do
        FFI::GDAL.GDALGetDefaultHistogram(@raster_band_pointer,
          min_pointer,
          max_pointer,
          buckets_pointer,
          histogram_pointer,
          force,
          progress_proc,
          nil
        )
      end
    end

    # Computes a histogram using the given inputs.  If you just want the default
    # histogram, use #default_histogram.
    #
    # @param min [Float]
    # @param max [Float]
    # @param buckets [Fixnum]
    # @param include_out_of_range [Boolean]
    # @param approx_ok [Boolean]
    # @param block [Proc] No required, but can be used to output progress info
    #   during processing.
    #
    # @yieldparam completion [Float] The ration completed as a decimal.
    # @yieldparam message [String] Message string to display.
    #
    # @return [Hash{minimum => Float, maximum => Float, buckets => Fixnum,
    #   totals => Array<Fixnum>}]
    #
    # @see #default_histogram for more info.
    def histogram(min, max, buckets, include_out_of_range: false,
      approx_ok: false, &block)
      histogram_pointer = FFI::MemoryPointer.new(:pointer, buckets)
      progress_proc = block || nil

      handler = GDAL::CPLErrorHandler.new
      handler.on_warning = proc { nil }
      handler.on_none = proc do
        totals = if buckets.zero?
                   []
                 else
                   histogram_pointer.read_array_of_int(buckets)
                 end

        {
          minimum: min,
          maximum: max,
          buckets: buckets,
          totals: totals
        }
      end

      handler.custom_handle do
        FFI::GDAL.GDALGetRasterHistogram(@raster_band_pointer,
          min.to_f,
          max.to_f,
          buckets,
          histogram_pointer,
          include_out_of_range,
          approx_ok,
          progress_proc,
          nil)
      end
    end

    # Copies the contents of one raster to another similarly configure band.
    # The two bands must have the same width and height but do not have to be
    # the same data type.
    #
    # Options:
    #   * :compressed
    #     * 'YES': forces alignment on the destination_band to achieve the best
    #       compression.
    #
    # @param destination_band [GDAL::RasterBand]
    # @param options [Hash]
    # @option options compress [String] Only 'YES' is supported.
    # @return [Boolean]
    def copy_whole_raster(destination_band, **options, &progress)
      destination_pointer = GDAL._pointer(GDAL::RasterBand, destination_band)
      options_ptr = GDAL::Options.pointer(options)

      !!FFI::GDAL.GDALRasterBandCopyWholeRaster(@raster_band_pointer,
        destination_pointer,
        options_ptr,
        progress,
        nil)
    end

    # Reads the raster line-by-line and returns as an NArray.  Will yield each
    # line and the line number if a block is given.
    #
    # @yieldparam pixel_line [Array]
    # @yieldparam line_number [Fixnum]
    # @return [NArray]
    # TODO: Extract RasterIO to separate function.
    def readlines(data_type: :GDT_Byte)
      x_offset = 0
      line_size = 1
      pixel_space = 0
      line_space = 0
      scan_line = GDAL._pointer_from_data_type(data_type, x_size)

      the_array = y_size.times.map do |y|
        FFI::GDAL.GDALRasterIO(@raster_band_pointer,
          :GF_Read,
          x_offset,
          y,
          x_size,
          line_size,
          scan_line,
          x_size,
          line_size,
          data_type,
          pixel_space,
          line_space
        )

        line_array = if data_type == :GDT_Byte
                       scan_line.read_array_of_uint8(x_size)
                     else
                       scan_line.read_array_of_float(x_size)
                     end

        yield(line_array, y) if block_given?

        line_array
      end

      NArray.to_na(the_array)
    end

    # @param pixel_array [NArray] The list of pixels.
    # @param x_offset [Fixnum] The left-most pixel to start writing.
    # @param y_offset [Fixnum] The top-most pixel to start writing.
    # @param data_type [FFI::GDAL::DataType] The type of pixel contained in
    #   the +pixel_array+.
    # @param line_space [Fixnum]
    # @param pixel_space [Fixnum]
    # TODO: Write using #buffer_size to write most efficiently.
    # TODO: Return a value!
    def write_array(pixel_array, x_offset: 0, y_offset: 0, data_type: :GDT_Byte,
      line_space: 0, pixel_space: 0)
      line_size = 1
      x_size = pixel_array.sizes.first
      y_size = pixel_array.sizes.last

      columns_to_write = x_size - x_offset
      lines_to_write = y_size - y_offset
      scan_line = GDAL._pointer_from_data_type(data_type, columns_to_write)

      (y_offset).upto(lines_to_write - 1) do |y|
        pixels = pixel_array[true, y]
        ffi_type = GDAL._gdal_data_type_to_ffi(data_type)
        meth = "write_array_of_#{ffi_type}".to_sym
        scan_line.send(meth, pixels.to_a)

        FFI::GDAL.GDALRasterIO(@raster_band_pointer,
          :GF_Write,
          x_offset,     # nXOff
          y,
          x_size,       # nXSize
          line_size,    # nYSize
          scan_line,    # pData
          x_size,       # nBufXSize
          line_size,    # nBufYSize
          data_type,    # eBufType
          pixel_space,  # nPixelSpace
          line_space    # nLineSpace
        )
      end

      flush_cache
    end

    # Read a block of image data, more efficiently than #read.  Doesn't
    # resample or do data type conversion.
    #
    # @param x_offset [Fixnum] The horizontal block offset, with 0 indicating
    #   the left-most block, 1 the next block, etc.
    # @param y_offset [Fixnum] The vertical block offset, with 0 indicating the
    #   top-most block, 1 the next block, etc.
    # @return [FFI::MemoryPointer] The image buffer.
    def read_block(x_offset, y_offset, image_buffer = nil)
      image_buffer ||= FFI::MemoryPointer.new(:void)

      FFI::GDAL.GDALReadBlock(@raster_band_pointer, x_offset, y_offset, image_buffer)

      image_buffer
    end

    # The minimum and maximum values for this band.
    #
    # @return [Hash{min => Float, max => Float}]
    def min_max(approx_ok: false)
      min_max = FFI::MemoryPointer.new(:double, 2)
      FFI::GDAL.GDALComputeRasterMinMax(@raster_band_pointer, approx_ok, min_max)

      { min: min_max[0].read_double, max: min_max[1].read_double }
    end

    # The minimum value in the band, not counting NODATA values. For file
    # formats that don't know this intrinsically, the minimum supported value
    # for the data type will generally be returned.
    #
    # @return [Hash{value => Float, is_tight => Boolean}] The +is_tight+ value
    #   tells whether the minimum is a tight minimum.
    def minimum_value
      is_tight = FFI::MemoryPointer.new(:bool)
      value = FFI::GDAL.GDALGetRasterMinimum(@raster_band_pointer, is_tight)

      { value: value, is_tight: is_tight.read_bytes(1).to_bool }
    end

    # The maximum value in the band, not counting NODATA values. For file
    # formats that don't know this intrinsically, the maximum supported value
    # for the data type will generally be returned.
    #
    # @return [Hash{value => Float, is_tight => Boolean}] The +is_tight+ value
    #   tells whether the maximum is a tight maximum.
    def maximum_value
      is_tight = FFI::MemoryPointer.new(:bool)
      value = FFI::GDAL.GDALGetRasterMaximum(@raster_band_pointer, is_tight)

      { value: value, is_tight: is_tight.read_bytes(1).to_bool }
    end
  end
end