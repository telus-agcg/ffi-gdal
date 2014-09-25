require_relative '../ffi/gdal'


module GDAL
  class RasterAttributeTable
    include FFI::GDAL

    # @param raster_band [GDAL::RasterBand, FFI::Pointer]
    # @param raster_attribute_table_pointer [FFI::Pointer]
    def initialize(raster_band, raster_attribute_table_pointer: nil)
      @raster_band = if raster_band.is_a? GDAL::RasterBand
        raster_band.c_pointer
      else
        raster_band
      end

      @gdal_raster_attribute_table = if raster_attribute_table_pointer
        raster_attribute_table_pointer
      else
        GDALGetDefaultRAT(@raster_band)
      end
    end

    def c_pointer
      @gdal_raster_attribute_table
    end

    # @param index [Fixnum] The column number.
    # @return [Fixnum]
    def column_count
      GDALRATGetColumnCount(c_pointer)
    end

    # @param index [Fixnum] The column number.
    # @return [String]
    def columnn_name(index)
      GDALRATGetNameOfCol(c_pointer, index)
    end

    # @param index [Fixnum] The column number.
    # @return [GDALRATFieldUsage]
    def column_usage(index)
      GDALRATGetUsageOfCol(c_pointer, index)
    end

    # @param index [Fixnum] The column number.
    # @return [GDALRATFieldType]
    def column_type(index)
      GDALRATGetTypeOfCol(c_pointer, index)
    end

    # @param field_usage [GDALRATFieldUsage]
    # @return [Fixnum] The column number.
    def column_of_usage(field_usage)
      GDALRATGetColOfUsage(c_pointer, index)
    end

    # @param field_usage [GDALRATFieldUsage]
    # @return [Fixnum] The column number.
    def row_count
      GDALRATGetRowCount(c_pointer)
    end

    # @param entry_count [Fixnum] The number of entries to produce.  The default
    #   will try to auto-determine the number.
    # @return [GDAL::ColorTable]
    def to_color_table(entry_count = -1)
      color_table_pointer = GDALRATTranslateToColorTable(c_pointer, entry_count)

      GDAL::ColorTable.new(@raster_band, color_table_pointer: color_table_pointer)
    end

    # @param file_path [String]
    def dump_readable(file_path = 'stdout')
      GDALRATDumpReadable(c_pointer, file_path)
    end
  end
end
