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

    # @return [Symbol] One of FFI::GDAL::GDALDataType.
    def raster_data_type
      GDALGetRasterDataType(@gdal_raster_band)
    end

    # @return [Hash{x => Fixnum, y => Fixnum}]
    def block_size
      x_pointer = FFI::MemoryPointer.new(:int)
      y_pointer = FFI::MemoryPointer.new(:int)
      GDALGetBlockSize(@gdal_raster_band, x_pointer, y_pointer)

      { x: x_pointer.read_int, y: y_pointer.read_int }
    end

    # @return [Float]
    def minimum_value
      min_max.first
    end

    # @return [Float]
    def maximum_value
      min_max.last
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
      o = GDAL::RasterBand.new
      o.c_pointer = overview_pointer

      o
    end

    # TODO: Something about the pointer allocation smells here...
    def read(x_offset: 0, y_offset: 0, x_size: x_size, y_size: 1, pixel_space: 0, line_space: 0)
      x_size ||= self.x_size
      scan_line = FFI::Pointer.new CPLMalloc(FFI::Type::FLOAT.size * x_size)

      GDALRasterIO(@gdal_raster_band,
        :GF_Read,
        x_offset,
        y_offset,
        x_size,
        y_size,
        scan_line,
        x_size,
        y_size,
        raster_data_type,
        pixel_space,
        line_space
      )

      data = scan_line.read_float
      CPLFree(scan_line)

      data
    end

    private

    def min_max
      @min_max = if _minimum_value && _maximum_value
        min_max = FFI::MemoryPointer.new(:double, 2)
        min_max.put_array_of_double 0, [_minimum_value, _maximum_value]
        GDALComputeRasterMinMax(@gdal_raster_band, 1, min_max)

        [min_max[0].read_double, min_max[1].read_double]
      else
        [0, 0]
      end
    end

    def _minimum_value
      min = FFI::MemoryPointer.new(:double)
      GDALGetRasterMinimum(@gdal_raster_band, min)
    end

    def _maximum_value
      max = FFI::MemoryPointer.new(:double)
      GDALGetRasterMaximum(@gdal_raster_band, max)
    end
  end
end
