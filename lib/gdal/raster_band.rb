require_relative '../ffi/gdal'
require_relative 'color_table'
require_relative 'major_object'

module GDAL
  class RasterBand
    include FFI::GDAL
    include MajorObject

    attr_reader :dataset

    def initialize(dataset=nil, index=nil)
      @dataset = dataset

      if @dataset && !@dataset.null? && index
        @gdal_raster_band = GDALGetRasterBand(@dataset, index)
      end
    end

    # @return [Boolean]
    def null?
      @gdal_raster_band && @gdal_raster_band.null?
    end

    def c_pointer
      @gdal_raster_band
    end

    def c_pointer=(ptr)
      @gdal_raster_band = ptr
    end

    # @return [Fixnum]
    def x_size
      return nil if null?

      GDALGetRasterBandXSize(@gdal_raster_band)
    end

    # @return [Fixnum]
    def y_size
      return nil if null?

      GDALGetRasterBandYSize(@gdal_raster_band)
    end

    # @return [Symbol]
    def access_flag
      return nil if null?

      flag = GDALGetRasterAccess(@gdal_raster_band)
      GDALAccess[flag]
    end

    # @return [Fixnum]
    def number
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

    # @param names [String, Array<String>]
    # @return [Array<String>]
    def category_names=(*names)
      str_pointers = names.map do |name|
        FFI::MemoryPointer.from_string(name)
      end

      str_pointers << nil
      names_pointer = FFI::MemoryPointer.new(:pointer, str_pointers.length)

      str_pointers.each_with_index do |ptr, i|
        names_pointer[i].put_pointer(0, ptr)
      end

      cpl_err = GDALSetRasterCategoryNames(@gdal_raster_band, names_pointer)

      case cpl_err
      when :warning then return []
      when :failure then raise CPLError
      end
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

    # @return [GDAL::RasterBand]
    def overview(index)
      overview_pointer = GDALGetOverview(@gdal_raster_band, index)
      return nil if overview_pointer.null?

      o = self.class.new
      o.c_pointer = overview_pointer

      o
    end

    # @param desired_samples [Fixnum] The returned band will have at least this
    #   many pixels.
    # @return [GDAL::RasterBand] An optimal overview or the same raster band if
    #   the raster band has no overviews.
    def raster_sample_overview(desired_samples=0)
      band_pointer = GDALGetRasterSampleOverview(@gdal_raster_band, desired_samples)
      band = self.class.new
      band.c_pointer = band_pointer

      band
    end

    # @return [GDAL::RasterBand]
    def mask_band
      band_pointer = GDALGetMaskBand(@gdal_raster_band)
      return nil if band_pointer.null?

      o = self.class.new
      o.c_pointer = band_pointer

      o
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

      case cpl_err
      when :warning then return {}
      when :failure then raise CPLError
      else
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
      GDALSetRasterScale(@gdal_raster_band, new_scale)
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
    def read(line_count=nil)
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

        #puts
        # data = scan_line.read_array_of_float(x_size).dup
        #
        # yield data
        yield scan_line.read_array_of_float(x_size).dup
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

    # @return [Array{min, max}]
    def compute_min_max
      @min_max = if minimum_value[:value] && maximum_value[:value]
        min_max = FFI::MemoryPointer.new(:double, 2)
        min_max.put_array_of_double 0, [minimum_value[:value], maximum_value[:value]]
        GDALComputeRasterMinMax(@gdal_raster_band, 1, min_max)

        [min_max[0].read_double, min_max[1].read_double]
      else
        [0, 0]
      end
    end

    # @return [Float]
    def minimum_value
      min = FFI::MemoryPointer.new(:bool)
      value = GDALGetRasterMinimum(@gdal_raster_band, min)

      { value: value, is_tight: min.read_bytes(1).to_bool }
    end

    # @return [Float]
    def maximum_value
      max = FFI::MemoryPointer.new(:double)
      value = GDALGetRasterMaximum(@gdal_raster_band, max)

      { value: value, is_tight: max.read_bytes(1).to_bool }
    end
  end
end
