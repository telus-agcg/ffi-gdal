require_relative '../ffi/gdal'
require_relative 'color_table'
require_relative 'major_object'

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
      if dataset.is_a? GDAL::Dataset
        @dataset = dataset.c_pointer
      else
        @dataset = dataset
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

    # @return [GDAL::ColorTable]
    def color_table
      gdal_color_table = GDALGetRasterColorTable(@gdal_raster_band)
      return nil if gdal_color_table.null?

      @color_table ||= ColorTable.new(@gdal_raster_band, gdal_color_table)
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

      cpl_err.to_ruby(warning: {}) do
        {
          minimum: min.read_double,
          maximum: max.read_double,
          mean: mean.read_double,
          standard_deviation: standard_deviation.read_double
        }
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

    # def units
    #
    # end

    # @return [String]
    def unit_type
      GDALGetRasterUnitType(@gdal_raster_band)
    end

    # @param new_unit_type [String] "" indicates unknown, "m" is meters, "ft"
    #   is feet; other non-standard values are allowed.
    # @return [FFI::GDAL::CPLErr]
    def unit_type=(new_unit_type)
      GDALSetRasterUnitType(@gdal_raster_band, new_unit_type)
    end

    # def default_histogram(force=false)
    #   min_pointer = FFI::MemoryPointer.new(:double)
    #   max_pointer = FFI::MemoryPointer.new(:double)
    #   buckets_pointer = FFI::MemoryPointer.new(:int)
    #   histogram_pointer = FFI::MemoryPointer.new(:int, 256)
    #   progress = Proc.new do |double, string, pointer|
    #     puts "progress: #{string}"
    #     puts "progress: #{double}"
    #     true
    #   end
    #
    #   cpl_err = GDALGetDefaultHistogram(@gdal_raster_band,
    #     min_pointer,
    #     max_pointer,
    #     buckets_pointer,
    #     histogram_pointer,
    #     force,
    #     progress,
    #     nil
    #   )
    #
    #   min = min_pointer.read_double
    #   max = max_pointer.read_double
    #   buckets = buckets_pointer.read_int
    #   puts "min: #{min}"
    #   puts "max: #{max}"
    #   puts "buckets: #{buckets}"
    #   h = histogram_pointer.dup
    #   bucket_size = (max - min) / buckets
    #   puts "bucket size: #{bucket_size}"
    #
    #   case cpl_err
    #   when :warning then return nil
    #   when :failure then raise CPLError
    #   when :none
    #     h.read_array_of_int(256)
    #
    #   end
    # end

    # def histogram(min, max, buckets, include_out_of_range=false, approx_ok=false)
    #   histogram_pointer = FFI::MemoryPointer.new(:int, buckets)
    #
    #   progress = Proc.new do |completion, message, progress_arg|
    #     puts "progress: #{completion * 100}"
    #     puts "progress: #{message}"
    #     #puts "progress: #{progress_arg.read_string}"
    #     true
    #   end
    #
    #   cpl_err = GDALGetRasterHistogram(@gdal_raster_band,
    #     min,
    #     max,
    #     buckets,
    #     histogram_pointer,
    #     include_out_of_range,
    #     approx_ok,
    #     progress,
    #     'doing things'
    #   )
    #
    #   puts "result: #{cpl_err}"
    #   puts "min: #{min}"
    #   puts "max: #{max}"
    #
    #   case cpl_err
    #   when :warning then return nil
    #   when :failure then raise CPLError
    #   when :none
    #     histogram_pointer.read_array_of_int(0)
    #   end
    # end

    # TODO: Something about the pointer allocation smells here...
    #def read(x_offset: 0, y_offset: 0, x_size: x_size, y_size: 1, pixel_space: 0, line_space: 0)
    def readlines
      x_offset = 0
      line_size = 1
      pixel_space = 0
      line_space = 0
      scan_line = FFI::MemoryPointer.new(:float, x_size)

      1.upto(y_size) do |y|
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

        yield scan_line.read_array_of_float(x_size).dup
      end
    end

    # @param pixel_array [NArray]
    def write_array(pixel_array, x_offset: 0, y_offset: 0, data_type: :GDT_Byte)
      line_size = 1
      pixel_space = 0
      line_space = 0
      x_size = pixel_array.sizes.first
      y_size = pixel_array.sizes.last
      data_type = data_type
      starting_y = y_offset + 1
      columns_to_write = x_size - x_offset
      lines_to_write = y_size - starting_y

      scan_line = FFI::MemoryPointer.new(:float, columns_to_write)

      (y_offset + 1).upto(lines_to_write) do |y|
        pixels = pixel_array[true, y]
        #:w
        # p pixels
        scan_line.write_array_of_float(pixel_array[true, y])

        GDALRasterIO(@gdal_raster_band,
          :GF_Write,
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
      #puts "x offset: #{x_offset}"
      #puts "y offset: #{y_offset}"

      result = GDALReadBlock(@gdal_raster_band, x_offset, y_offset, image_buffer)

      if result == :none
      elsif result == :failure

      end
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
  end
end
