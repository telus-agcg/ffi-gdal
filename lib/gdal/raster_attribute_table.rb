require_relative '../ffi/gdal'


module GDAL
  class RasterAttributeTable
    include FFI::GDAL

    # @return [GDAL::RasterAttributeTable]
    def self.create
      raster_attribute_table_ptr = FFI::GDAL.GDALCreateRasterAttributeTable

      new(raster_attribute_table_ptr)
    end

    # Create an object from a ColorTable.
    #
    # @param color_table [GDAL::ColorTable, FFI::Pointer]
    # @return [GDAL::RasterAttributeTable]
    def self.from_color_table(color_table)
      color_table_ptr = if color_table.is_a? GDAL::ColorTable
        color_table.c_pointer
      else
        color_table
      end

      rat_ptr = FFI::MemoryPointer.new(:GDALRasterAttributeTableH)
      cpl_err = FFI::GDAL.GDALRATInitializeFromColorTable(rat_ptr, color_table_ptr)
      cpl_err.to_bool

      new(rat_ptr)
    end

    # @param raster_attribute_table [GDAL::RasterAttributeTable, FFI::Pointer]
    def initialize(raster_attribute_table=nil)
      @rat_pointer = if raster_attribute_table.is_a? GDAL::RasterAttributeTable
        raster_attribute_table.c_pointer
      else
        raster_attribute_table
      end
    end

    def destroy!
      GDALDestroyRasterAttributeTable(@rat_pointer)
    end

    def c_pointer
      @rat_pointer
    end


    # Clone using the C API.
    #
    # @return [GDAL::RasterAttributeTable]
    def clone
      rat_ptr = GDALRATClone(@rat_pointer)
      return nil if rat_ptr.null?

      self.class.new(rat_ptr)
    end

    # +true+ if the changes made to this RAT have been written to the associated
    # dataset.
    #
    # @return [Boolean]
    def changes_written_to_file?
      GDALRATChangesAreWrittenToFile(@rat_pointer)
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

    # @param name [String]
    # @param type [FFI::GDALRATFieldType]
    # @param usage [FFI::GDALRATFieldUsage]
    # @return [Boolean]
    def create_column(name, type, usage)
      cpl_err = GDALRATCreateColumn(@rat_pointer, name, type, usage)

      cpl_err.to_bool
    end

    # @return [Fixnum] The number of rows.
    def row_count
      GDALRATGetRowCount(@rat_pointer)
    end

    # @return [Fixnum] The number of rows.
    def row_count=(count)
      GDALRATSetRowCount(@rat_pointer, count)
    end

    # Get the row for a pixel value.
    #
    # @param value [Float]
    # @return [Fixnum]
    def row_of_value(value)
      GDALRATGetRowOfValue(@rat_pointer, value)
    end

    # @param row [Fixnum]
    # @param field [Fixnum]
    # @return [String]
    def value_to_s(row, field)
      GDALRATGetValueAsString(@rat_pointer, row, field)
    end

    # @param row [Fixnum]
    # @param field [Fixnum]
    # @return [Fixnum]
    def value_to_i(row, field)
      GDALRATGetValueAsInt(@rat_pointer, row, field)
    end

    # @param row [Fixnum]
    # @param field [Fixnum]
    # @return [Float]
    def value_to_f(row, field)
      GDALRATGetValueAsDouble(@rat_pointer, row, field)
    end

    # @param row [Fixnum]
    # @param field [Fixnum]
    # @param value [String, Float, Fixnum]
    def add_value(row, field, value)
      case value.class.name
      when 'String'
        GDALRATSetValueAsString(@rat_pointer, row, field, value)
      when 'Float'
        GDALRATSetValueAsDouble(@rat_pointer, row, field, value)
      when 'Fixnum'
        GDALRATSetValueAsInt(@rat_pointer, row, field, value)
      else
        raise "Unknown value type for value '#{value}'"
      end
    end

    # @return [Hash{row_0_minimum => Float, bin_size => Float}]
    def linear_binning
      row_0_min_ptr = FFI::MemoryPointer.new(:double)
      bin_size_ptr = FFI::MemoryPointer.new(:double)
      GDALRATGetLinearBinning(@rat_pointer, row_0_min_ptr, bin_size_ptr)

      {
        row_0_minimum: row_0_min_ptr.read_double,
        bin_size: bin_size_ptr.read_double
      }
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
