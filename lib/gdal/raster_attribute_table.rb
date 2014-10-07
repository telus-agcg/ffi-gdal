require_relative '../ffi/gdal'


module GDAL
  class RasterAttributeTable
    include FFI::GDAL

    # @return [GDAL::RasterAttributeTable]
    def self.create
      raster_attribute_table_ptr = FFI::GDAL.GDALCreateRasterAttributeTable

      new(raster_attribute_table_ptr)
    end

    # @param raster_attribute_table [GDAL::RasterAttributeTable, FFI::Pointer]
    def initialize(raster_attribute_table=nil)
      @rat_pointer = if raster_attribute_table.is_a? GDAL::RasterAttributeTable
        raster_attribute_table.c_pointer
      else
        raster_attribute_table
      end
    end

    def c_pointer
      @rat_pointer
    end

    # @param index [Fixnum] The column number.
    # @return [Fixnum]
    def column_count
      GDALRATGetColumnCount(@rat_pointer)
    end

    # @param index [Fixnum] The column number.
    # @return [String]
    def columnn_name(index)
      GDALRATGetNameOfCol(@rat_pointer, index)
    end

    # @param index [Fixnum] The column number.
    # @return [GDALRATFieldUsage]
    def column_usage(index)
      GDALRATGetUsageOfCol(@rat_pointer, index)
    end

    # @param index [Fixnum] The column number.
    # @return [GDALRATFieldType]
    def column_type(index)
      GDALRATGetTypeOfCol(@rat_pointer, index)
    end

    # @param field_usage [GDALRATFieldUsage]
    # @return [Fixnum] The column number.
    def column_of_usage(field_usage)
      GDALRATGetColOfUsage(@rat_pointer, index)
    end

    # @param field_usage [GDALRATFieldUsage]
    # @return [Fixnum] The column number.
    def row_count
      GDALRATGetRowCount(@rat_pointer)
    end

    # @param entry_count [Fixnum] The number of entries to produce.  The default
    #   will try to auto-determine the number.
    # @return [GDAL::ColorTable]
    def to_color_table(entry_count = -1)
      color_table_pointer = GDALRATTranslateToColorTable(@rat_pointer, entry_count)

      GDAL::ColorTable.new(color_table_pointer)
    end

    # @param file_path [String]
    def dump_readable(file_path = 'stdout')
      GDALRATDumpReadable(@rat_pointer, file_path)
    end
  end
end
