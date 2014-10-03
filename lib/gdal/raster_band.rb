require_relative '../ffi/gdal'
require_relative 'color_table'
require_relative 'major_object'
require_relative 'raster_attribute_table'
require 'narray'

module GDAL
  class RasterBand
    include FFI::GDAL
    include MajorObject

    attr_reader :dataset

    # @param dataset [GDAL::Dataset, FFI::Pointer]
    # @param band_id [Fixnum] Requried if not passing in +raster_band_pointer+.
    # @param raster_band_pointer [FFI::Pointer] Requried if not passing in
    #   +band_id+.
    def initialize(dataset, band_id: nil, raster_band_pointer: nil)
      @dataset = if dataset.is_a? GDAL::Dataset
        dataset.c_pointer
      else
        dataset
      end

      @gdal_raster_band = if raster_band_pointer
        raster_band_pointer
      elsif band_id
        GDALGetRasterBand(@dataset, band_id)
      else
        raise 'Must pass in band_id or the raster_band_pointer.'
      end
    end

    def c_pointer
      @gdal_raster_band
    end

    # The raster width in pixels.
    #
    # @return [Fixnum]
    def x_size
      return nil if null?

      GDALGetRasterBandXSize(@gdal_raster_band)
    end

    # The raster height in pixels.
    #
    # @return [Fixnum]
    def y_size
      return nil if null?

      GDALGetRasterBandYSize(@gdal_raster_band)
    end

    # The type of access to the raster band this object currently has.
    #
    # @return [Symbol] Either :GA_Update or :GA_ReadOnly.
    def access_flag
      return nil if null?

      GDALGetRasterAccess(@gdal_raster_band)
    end

    # The number of band within the associated dataset that this band
    # represents.
    #
    # @return [Fixnum]
    def band_number
      return nil if null?

      GDALGetBandNumber(@gdal_raster_band)
    end

    # @return [Symbol] One of FFI::GDAL::GDALColorInterp.
    def color_interpretation
      GDALGetRasterColorInterpretation(@gdal_raster_band)
    end

    def color_interpretation=(new_color_interp)
      GDALSetRasterColorInterpretation(@gdal_raster_band, new_color_interp).to_ruby
    end

    # @return [GDAL::ColorTable]
    def color_table
      return @color_table if @color_table

      gdal_color_table = GDALGetRasterColorTable(@gdal_raster_band)
      return nil if gdal_color_table.null?

      @color_table ||= ColorTable.new(@gdal_raster_band,
        color_table_pointer: gdal_color_table)
    end

    # @param new_color_table [GDAL::ColorTable]
    def color_table=(new_color_table)
      color_table_pointer = if new_color_table.is_a? GDAL::ColorTable
                              new_color_table.c_pointer
                            else
                              new_color_table
                            end

      cpl_err = GDALSetRasterColorTable(@gdal_raster_band, color_table_pointer)

      cpl_err.to_bool
    end

    def build_color_table(palette_interpretation)
      @color_table = ColorTable.create(@gdal_raster_band, palette_interpretation)
    end

    # The pixel data type for this band.
    #
    # @return [Symbol] One of FFI::GDAL::GDALDataType.
    def data_type
      GDALGetRasterDataType(@gdal_raster_band)
    end

    # The natural block size is the block size that is most efficient for
    # accessing the format. For many formats this is simply a whole scanline
    # in which case x is set to #x_size, and y is set to 1.
    #
    # @return [Hash{x => Fixnum, y => Fixnum}]
    def block_size
      x_pointer = FFI::MemoryPointer.new(:int)
      y_pointer = FFI::MemoryPointer.new(:int)
      GDALGetBlockSize(@gdal_raster_band, x_pointer, y_pointer)

      { x: x_pointer.read_int, y: y_pointer.read_int }
    end

    # @return [Array<String>]
    def category_names
      names = GDALGetRasterCategoryNames(@gdal_raster_band)
      return [] if names.null?

      names.get_array_of_string(0)
    end

    # @param names [Array<String>]
    # @return [Array<String>]
    def category_names=(names)
      str_pointers = names.map do |name|
        FFI::MemoryPointer.from_string(name.to_s)
      end

      str_pointers << nil
      names_pointer = FFI::MemoryPointer.new(:pointer, str_pointers.length)

      str_pointers.each_with_index do |ptr, i|
        names_pointer[i].put_pointer(0, ptr)
      end

      cpl_err = GDALSetRasterCategoryNames(@gdal_raster_band, names_pointer)

      cpl_err.to_ruby(warning: [])
    end

    # The no data value for a band is generally a special marker value used to
    # mark pixels that are not valid data. Such pixels should generally not be
    # displayed, nor contribute to analysis operations.
    #
    # @return [Hash{value => Float, is_associated => Boolean}]
    def no_data_value
      associated = FFI::MemoryPointer.new(:bool)
      value = GDALGetRasterNoDataValue(@gdal_raster_band, associated)

      { value: value, is_associated: associated.read_bytes(1).to_bool }
    end

    # Sets the no data value for this band.
    #
    # @param value [Float]
    def no_data_value=(value)
      cpl_err = GDALSetRasterNoDataValue(@gdal_raster_band, value)

      cpl_err.to_bool
    end

    # @return [Fixnum]
    def overview_count
      GDALGetOverviewCount(@gdal_raster_band)
    end

    # @return [Boolean]
    def arbitrary_overviews?
      GDALHasArbitraryOverviews(@gdal_raster_band).zero? ? false : true
    end

    # @param index [Fixnum] Must be between 0 and (#overview_count - 1).
    # @return [GDAL::RasterBand]
    def overview(index)
      return nil if overview_count.zero?

      overview_pointer = GDALGetOverview(@gdal_raster_band, index)
      return nil if overview_pointer.null?

      self.class.new(dataset, raster_band_pointer: overview_pointer)
    end

    # @param desired_samples [Fixnum] The returned band will have at least this
    #   many pixels.
    # @return [GDAL::RasterBand] An optimal overview or the same raster band if
    #   the raster band has no overviews.
    def raster_sample_overview(desired_samples=0)
      band_pointer = GDALGetRasterSampleOverview(@gdal_raster_band, desired_samples)
      return nil if band_pointer.null?

      self.class.new(dataset, raster_band_pointer: band_pointer)
    end

    # @return [GDAL::RasterBand]
    def mask_band
      band_pointer = GDALGetMaskBand(@gdal_raster_band)
      return nil if band_pointer.null?

      self.class.new(dataset, raster_band_pointer: band_pointer)
    end

    # @return [Array<Symbol>]
    def mask_flags
      flag_list = GDALGetMaskFlags(@gdal_raster_band).to_s(2).scan(/\d/)
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

    # Returns minimum, maximum, mean, and standard deviation of all pixel values
    # in this band.
    #
    # @param approx_ok [Boolean] If +true+, stats may be computed based on
    #   overviews or a subset of all tiles.
    # @param force [Boolean] If +false+, stats will only be returned if the
    #   calculating can be done without rescanning the image.
    # @return [Hash{mininum: Float, maximum: Float, mean: Float,
    #   standard_deviation: Float}]
    def statistics(approx_ok=true, force=true)
      min = FFI::MemoryPointer.new(:double)
      max = FFI::MemoryPointer.new(:double)
      mean = FFI::MemoryPointer.new(:double)
      standard_deviation = FFI::MemoryPointer.new(:double)

      cpl_err = GDALGetRasterStatistics(@gdal_raster_band,
        approx_ok,
        force,
        min,
        max,
        mean,
        standard_deviation)

      minimum = min.null? ? 0.0 : min.read_double

      case cpl_err.to_ruby
      when :none, :debug
        {
          minimum: min.read_double,
          maximum: max.read_double,
          mean: mean.read_double,
          standard_deviation: standard_deviation.read_double
        }
      when :warning then {}
      when :failure, :fatal then raise CPLErrFailure
      end
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
      result = GDALGetRasterScale(@gdal_raster_band, meaningful)

      { value: result, is_meaningful: meaningful.read_bytes(1).to_bool }
    end

    # @param new_scale [Float]
    # @return [FFI::GDAL::CPLErr]
    def scale=(new_scale)
      GDALSetRasterScale(@gdal_raster_band, new_scale.to_f)
    end

    # This value (in combination with the GetScale() value) is used to
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
      result = GDALGetRasterOffset(@gdal_raster_band, meaningful)

      { value: result, is_meaningful: meaningful.read_bytes(1).to_bool }
    end

    # @param new_offset [Float]
    # @return [FFI::GDAL::CPLErr]
    def offset=(new_offset)
      GDALSetRasterOffset(@gdal_raster_band, new_offset)
    end

    # @return [String]
    def unit_type
      GDALGetRasterUnitType(@gdal_raster_band)
    end

    # @param new_unit_type [String] "" indicates unknown, "m" is meters, "ft"
    #   is feet; other non-standard values are allowed.
    # @return [FFI::GDAL::CPLErr]
    def unit_type=(new_unit_type)
      if defined? FFI::GDAL::GDALSetRasterUnitType
        GDALSetRasterUnitType(@gdal_raster_band, new_unit_type)
      else
        warn "GDALSetRasterUnitType is not defined.  Can't call RasterBand#unit_type="
      end
    end

    # @return [GDAL::RasterAttributeTable]
    def default_raster_attribute_table
      rat_pointer = GDALGetDefaultRAT(c_pointer)
      return nil if rat_pointer.null?

      GDAL::RasterAttributeTable.new(c_pointer,
        raster_attribute_table_pointer: rat_pointer)
    end

    # Gets the default raster histogram.  Results are returned as a Hash so some
    # metadata about the histogram can be returned.  Example:
    #
    #   {
    #     :mininum => -0.9,
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
    # @param block [Proc] No required, but can be used to output progess info
    #   during processing.
    #
    # @yieldparam completion [Float] The ration completed as a decimal.
    # @yieldparam message [String] Message string to display.
    #
    # @return [Hash{minimum => Float, maximum => Float, buckets => Fixnum,
    #   totals => Array<Fixnum>}] Returns +nil+ if no default histogram is
    #   available.
    def default_histogram(force=false, &block)
      min_pointer = FFI::MemoryPointer.new(:double)
      max_pointer = FFI::MemoryPointer.new(:double)
      buckets_pointer = FFI::MemoryPointer.new(:int)
      histogram_pointer = FFI::MemoryPointer.new(:pointer)
      progress_proc = block || nil

      cpl_err = GDALGetDefaultHistogram(@gdal_raster_band,
        min_pointer,
        max_pointer,
        buckets_pointer,
        histogram_pointer,
        force,
        progress_proc,
        nil
      )

      min = min_pointer.read_double
      max = max_pointer.read_double
      buckets = buckets_pointer.read_int

      totals = if buckets.zero?
        []
      else
        histogram_pointer.get_pointer(0).read_array_of_int(buckets)
      end

      formated_buckets(cpl_err, min, max, buckets, totals)
    end

    # Computes a histogram using the given inputs.  If you just want the default
    # histogram, use #default_histogram.
    #
    # @param min [Float]
    # @param max [Float]
    # @param buckets [Fixnum]
    # @param include_out_of_range [Boolean]
    # @param approx_ok [Boolean]
    # @param block [Proc] No required, but can be used to output progess info
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

      cpl_err = GDALGetRasterHistogram(@gdal_raster_band,
        min.to_f,
        max.to_f,
        buckets,
        histogram_pointer,
        include_out_of_range,
        approx_ok,
        progress_proc,
        'doing things')

      totals = if buckets.zero?
        []
      else
        histogram_pointer.read_array_of_int(buckets)
      end

      formated_buckets(cpl_err, min, max, buckets, totals)
    end

    # TODO: Something about the pointer allocation smells here...
    #def read(x_offset: 0, y_offset: 0, x_size: x_size, y_size: 1, pixel_space: 0, line_space: 0)
    def readlines
      x_offset = 0
      line_size = 1
      pixel_space = 0
      line_space = 0
      scan_line = FFI::MemoryPointer.new(:float, x_size)

      0.upto(y_size - 1) do |y|
        GDALRasterIO(@gdal_raster_band,
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

        yield(scan_line.read_array_of_float(x_size).dup, y)
      end
    end

    # @param pixel_array [NArray] The NArray of pixels.
    # @param x_offset [Fixnum] The left-most pixel to start writing.
    # @param y_offset [Fixnum] The top-most pixel to start writing.
    # @param data_type [FFI::GDAL::GDALDataType] The type of pixel contained in
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
      scan_line = FFI::MemoryPointer.new(:float, columns_to_write)

      (y_offset).upto(lines_to_write - 1) do |y|
        pixels = pixel_array[true, y]
        scan_line.write_array_of_float(pixels.to_a)

        GDALRasterIO(@gdal_raster_band,
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

      GDALFlushRasterCache(@gdal_raster_band)
    end

    # Read a block of image data, more efficiently than #read.  Doesn't
    # resample or do data type conversion.
    #
    # @param x_offset [Fixnum] The horizontal block offset, with 0 indicating
    #   the left-most block, 1 the next block, etc.
    # @param y_offset [Fixnum] The vertical block offset, with 0 indicating the
    #   top-most block, 1 the next block, etc.
    def read_block(x_offset, y_offset, image_buffer=nil)
      image_buffer ||= FFI::MemoryPointer.new(:void)
      result = GDALReadBlock(@gdal_raster_band, x_offset, y_offset, image_buffer)

      result.to_bool
    end

    # The minimum and maximum values for this band.
    #
    # @return [Array{min => Float, max => Float}]
    def compute_min_max
      @min_max = if minimum_value[:value] && maximum_value[:value]
        min_max = FFI::MemoryPointer.new(:double, 2)
        min_max.put_array_of_double 0, [minimum_value[:value], maximum_value[:value]]
        GDALComputeRasterMinMax(@gdal_raster_band, 1, min_max)

        [min_max[0].read_double, min_max[1].read_double]
      else
        [0.0, 0.0]
      end
    end

    # @return [Hash{value => Float, it_tight => Boolean}]
    def minimum_value
      is_tight = FFI::MemoryPointer.new(:bool)
      value = GDALGetRasterMinimum(@gdal_raster_band, is_tight)

      { value: value, is_tight: is_tight.read_bytes(1).to_bool }
    end

    # @return [Hash{value => Float, it_tight => Boolean}]
    def maximum_value
      is_tight = FFI::MemoryPointer.new(:double)
      value = GDALGetRasterMaximum(@gdal_raster_band, is_tight)

      { value: value, is_tight: is_tight.read_bytes(1).to_bool }
    end

    # Iterates through all lines and builds an NArray of pixels.
    #
    # @return [NArray]
    def to_a
      lines = []

      readlines do |line|
        lines << line
      end

      NArray.to_na(lines)
    end

    #---------------------------------------------------------------------------
    # Privates
    #---------------------------------------------------------------------------

    private

    def formated_buckets(cpl_err, min, max, buckets, totals)
      case cpl_err.to_ruby
      when :none
        {
          minimum: min,
          maximum: max,
          buckets: buckets,
          totals: totals
        }
      when :warning then return nil
      when :failure then raise CPLError
      end
    end

  end
end
