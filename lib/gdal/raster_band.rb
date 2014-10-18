require_relative '../ffi/gdal'
require_relative '../ffi/ogr/api_h'
require_relative 'raster_band_extensions'
require_relative 'color_table'
require_relative 'major_object'
require_relative 'raster_attribute_table'
require 'narray'

module GDAL
  class RasterBand
    include MajorObject
    include GDAL::Logger
    include RasterBandExtensions

    # @param raster_band [GDAL::RasterBand, FFI::Pointer]
    def initialize(raster_band=nil)
      @raster_band_pointer = GDAL._pointer(GDAL::RasterBand, raster_band)
    end

    def c_pointer
      @raster_band_pointer
    end

    # @return [Boolean]
    def flush_cache
      cpl_err = FFI::GDAL.GDALFlushRasterCache(@raster_band_pointer)

      cpl_err.to_bool
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

    # @return [Symbol] One of FFI::GDAL::GDALColorInterp.
    def color_interpretation
      FFI::GDAL.GDALGetRasterColorInterpretation(@raster_band_pointer)
    end

    def color_interpretation=(new_color_interp)
      FFI::GDAL.GDALSetRasterColorInterpretation(@raster_band_pointer, new_color_interp).to_ruby
    end

    # @return [GDAL::ColorTable]
    def color_table
      return @color_table if @color_table

      gdal_color_table = FFI::GDAL.GDALGetRasterColorTable(@raster_band_pointer)
      return nil if gdal_color_table.null?

      @color_table = ColorTable.new(gdal_color_table)
    end

    # @param new_color_table [GDAL::ColorTable]
    def color_table=(new_color_table)
      color_table_pointer = GDAL._pointer(GDAL::ColorTable, new_color_table)
      cpl_err = FFI::GDAL.GDALSetRasterColorTable(@raster_band_pointer, color_table_pointer)
      @color_table = ColorTable.new(color_table_pointer)

      cpl_err.to_bool
    end

    # The pixel data type for this band.
    #
    # @return [Symbol] One of FFI::GDAL::GDALDataType.
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

      cpl_err = FFI::GDAL.GDALSetRasterCategoryNames(@raster_band_pointer, names_pointer)

      cpl_err.to_ruby(warning: [])
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
    def no_data_value=(value)
      cpl_err = FFI::GDAL.GDALSetRasterNoDataValue(@raster_band_pointer, value)

      cpl_err.to_bool
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
    def raster_sample_overview(desired_samples=0)
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
    def create_mask_band
      cpl_err = FFI::GDAL.GDALCreateMaskBand(@raster_band_pointer)

      cpl_err.to_bool
    end

    # Fill this band with constant value.  Useful for clearing a band and
    # setting to a default value.
    #
    # @param real_value [Float]
    # @param imaginary_value [Float]
    def fill(real_value, imaginary_value=0)
      cpl_err = FFI::GDAL.GDALFillRaster(@raster_band_pointer, real_value, imaginary_value)

      cpl_err.to_bool
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
    def statistics(approx_ok=true, force=true)
      min = FFI::MemoryPointer.new(:double)
      max = FFI::MemoryPointer.new(:double)
      mean = FFI::MemoryPointer.new(:double)
      standard_deviation = FFI::MemoryPointer.new(:double)

      cpl_err = FFI::GDAL.GDALGetRasterStatistics(@raster_band_pointer,
        approx_ok,
        force,
        min,
        max,
        mean,
        standard_deviation)

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
      else raise CPLErrFailure
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
      result = FFI::GDAL.GDALGetRasterScale(@raster_band_pointer, meaningful)

      { value: result, is_meaningful: meaningful.read_bytes(1).to_bool }
    end

    # @param new_scale [Float]
    # @return [FFI::GDAL::CPLErr]
    def scale=(new_scale)
      FFI::GDAL.GDALSetRasterScale(@raster_band_pointer, new_scale.to_f)
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
      result = FFI::GDAL.GDALGetRasterOffset(@raster_band_pointer, meaningful)

      { value: result, is_meaningful: meaningful.read_bytes(1).to_bool }
    end

    # @param new_offset [Float]
    # @return [FFI::GDAL::CPLErr]
    def offset=(new_offset)
      FFI::GDAL.GDALSetRasterOffset(@raster_band_pointer, new_offset)
    end

    # @return [String]
    def unit_type
      FFI::GDAL.GDALGetRasterUnitType(@raster_band_pointer)
    end

    # @param new_unit_type [String] "" indicates unknown, "m" is meters, "ft"
    #   is feet; other non-standard values are allowed.
    # @return [FFI::GDAL::CPLErr]
    def unit_type=(new_unit_type)
      if defined? FFI::GDAL::GDALSetRasterUnitType
        FFI::GDAL.GDALSetRasterUnitType(@raster_band_pointer, new_unit_type)
      else
        warn "GDALSetRasterUnitType is not defined.  Can't call RasterBand#unit_type="
      end
    end

    # @return [GDAL::RasterAttributeTable]
    def default_raster_attribute_table
      return @default_raster_attribute_table if @default_raster_attribute_table

      rat_pointer = FFI::GDAL.GDALGetDefaultRAT(@raster_band_pointer)
      return nil if rat_pointer.null?

      @default_raster_attribute_table = GDAL::RasterAttributeTable.new(rat_pointer)
    end

    # @return [GDAL::RasterAttributeTable]
    def default_raster_attribute_table=(rat_table)
      rat_table_ptr = GDAL._pointer(GDAL::RasterAttributeTable, rat_table)
      cpl_err = FFI::GDAL.GDALSetDefaultRAT(@raster_band_pointer, rat_table_ptr)
      @default_raster_attribute_table = GDAL::RasterAttributeTable.new(rat_table_pointer)

      cpl_err.to_bool
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

      cpl_err = FFI::GDAL.GDALGetDefaultHistogram(@raster_band_pointer,
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

      formatted_buckets(cpl_err, min, max, buckets, totals)
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

      cpl_err = FFI::GDAL.GDALGetRasterHistogram(@raster_band_pointer,
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

      formatted_buckets(cpl_err, min, max, buckets, totals)
    end

    # Copies the contents of one raster to another similarly configure band.
    # The two bands must have the same width and height but do not have to be
    # the same data type.
    #
    # Options:
    #   * :compressed
    #     * 'YES': forces alignment on the destination_band to acheive the best
    #       compression.
    #
    # @param destination_band [GDAL::RasterBand]
    # @param options [Hash]
    # @option options compress [String] Only 'YES' is supported.
    # @return [Boolean]
    def copy_whole_raster(destination_band, **options, &progress)
      destination_pointer = GDAL._pointer(GDAL::RasterBand, destination_band)
      options_ptr = GDAL::Options.pointer(options)
      cpl_err = FFI::GDAL.GDALRasterBandCopyWholeRaster(@raster_band_pointer,
        destination_pointer,
        options_ptr,
        progress,
        nil)

      cpl_err.to_bool
    end

    # Reads the raster line-by-line and returns as an NArray.  Will yield each
    # line and the line number if a block is given.
    #
    # @yieldparam pixel_line [Array]
    # @yieldparam line_number [Fixnum]
    # @return [NArray]
    def readlines(data_type: :GDT_Byte)
      x_offset = 0
      line_size = 1
      pixel_space = 0
      line_space = 0
      scan_line = FFI::MemoryPointer.new(pointer_type(data_type), x_size)

      the_array = 0.upto(y_size - 1).map do |y|
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
      scan_line = FFI::MemoryPointer.new(pointer_type(data_type), columns_to_write)

      (y_offset).upto(lines_to_write - 1) do |y|
        puts "line #{y}"
        pixels = pixel_array[true, y]
        if data_type == :GDT_Byte
          scan_line.write_array_of_uint8(pixels.to_a)
        else
          scan_line.write_array_of_float(pixels.to_a)
        end

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

    def pointer_type(data_type)
      case data_type
      when :GDT_Byte then :uchar
      when :GDT_Float32 then :float
      else
        :float
      end
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
      result = FFI::GDAL.GDALReadBlock(@raster_band_pointer, x_offset, y_offset, image_buffer)

      result.to_bool
    end

    # The minimum and maximum values for this band.
    #
    # @return [Array{min => Float, max => Float}]
    def min_max
      @min_max = if minimum_value[:value] && maximum_value[:value]
        min_max = FFI::MemoryPointer.new(:double, 2)
        min_max.put_array_of_double 0, [minimum_value[:value], maximum_value[:value]]
        FFI::GDAL.GDALComputeRasterMinMax(@raster_band_pointer, 1, min_max)

        [min_max[0].read_double, min_max[1].read_double]
      else
        [0.0, 0.0]
      end
    end

    # @return [Hash{value => Float, it_tight => Boolean}]
    def minimum_value
      is_tight = FFI::MemoryPointer.new(:bool)
      value = FFI::GDAL.GDALGetRasterMinimum(@raster_band_pointer, is_tight)

      { value: value, is_tight: is_tight.read_bytes(1).to_bool }
    end

    # @return [Hash{value => Float, it_tight => Boolean}]
    def maximum_value
      is_tight = FFI::MemoryPointer.new(:double)
      value = FFI::GDAL.GDALGetRasterMaximum(@raster_band_pointer, is_tight)

      { value: value, is_tight: is_tight.read_bytes(1).to_bool }
    end

    # Creates vector polygons for all connected regions of pixels in the raster
    # that share a common pixel value.
    #
    # @param layer [OGR::Layer, FFI::Pointer] The layer to write the polygons
    #   to.
    # @param mask_band [GDAL::RasterBand, FFI::Pointer] Optional band, where all
    #   pixels in the mask with a value other than zero will be considered
    #   suitable for collection as polygons.
    # @param pixel_value_field [Fixnum] Index of the feature attribute into
    #   which the pixel value of the polygon should be written.
    # @param options [Hash]
    # @param progress [Proc]
    # @return [OGR::Layer]
    def polygonize(layer, mask_band: nil, pixel_value_field: -1, **options, &progress)
      mask_band_ptr = GDAL._pointer(GDAL::RasterBand, mask_band, false)

      layer_ptr = GDAL._pointer(OGR::Layer, layer)
      raise "Invalid layer: #{layer.inspect}" if layer_ptr.null?

      options_ptr = GDAL::Options.pointer(options)

      cpl_err = FFI::GDAL.GDALFPolygonize(@raster_band_pointer,    # hSrcBand
        mask_band_ptr,                                  # hMaskBand
        layer_ptr,                                      # hOutLayer
        pixel_value_field,                              # iPixValField
        options_ptr,                                    # papszOptions
        progress,                                      # pfnProgress
        nil                                             # pProgressArg
      )
      cpl_err.to_ruby

      OGR::Layer.new(layer_ptr)
    end

    #---------------------------------------------------------------------------
    # Privates
    #---------------------------------------------------------------------------

    private

    def formatted_buckets(cpl_err, min, max, buckets, totals)
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
      else raise CPLError
      end
    end
  end
end
