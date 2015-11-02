require_relative '../ffi/gdal'
require_relative 'raster_attribute_table_mixins/extensions'

module GDAL
  class RasterAttributeTable
    include RasterAttributeTableMixins::Extensions

    # Create an object from a ColorTable.
    #
    # @param color_table [GDAL::ColorTable, FFI::Pointer]
    # @return [GDAL::RasterAttributeTable]
    def self.from_color_table(color_table)
      color_table_ptr = GDAL._pointer(GDAL::ColorTable, color_table)
      rat_ptr = FFI::GDAL::GDAL.GDALCreateRasterAttributeTable
      FFI::GDAL::GDAL.GDALRATInitializeFromColorTable(rat_ptr, color_table_ptr)

      new(rat_ptr)
    end

    # @return [FFI::Pointer] The C pointer that represents the C RAT.
    attr_reader :c_pointer

    # @param pointer [FFI::Pointer]
    def initialize(pointer = nil)
      @c_pointer = pointer || FFI::GDAL::GDAL.GDALCreateRasterAttributeTable
    end

    def destroy!
      return unless @c_pointer

      FFI::GDAL::GDAL.GDALDestroyRasterAttributeTable(@c_pointer)
      @c_pointer = nil
    end

    # Clone using the C API.
    #
    # @return [GDAL::RasterAttributeTable]
    def clone
      rat_ptr = FFI::GDAL::GDAL.GDALRATClone(@c_pointer)
      return nil if rat_ptr.null?

      self.class.new(rat_ptr)
    end

    # +true+ if the changes made to this RAT have been written to the associated
    # dataset.
    #
    # @return [Boolean]
    def changes_written_to_file?
      FFI::GDAL::GDAL.GDALRATChangesAreWrittenToFile(@c_pointer)
    end

    # @return [Fixnum]
    def column_count
      FFI::GDAL::GDAL.GDALRATGetColumnCount(@c_pointer)
    end

    # @param index [Fixnum] The column number.
    # @return [String]
    def column_name(index)
      FFI::GDAL::GDAL.GDALRATGetNameOfCol(@c_pointer, index)
    end

    # @param index [Fixnum] The column number.
    # @return [GDALRATFieldUsage]
    def column_usage(index)
      FFI::GDAL::GDAL.GDALRATGetUsageOfCol(@c_pointer, index)
    end

    # @param index [Fixnum] The column number.
    # @return [GDALRATFieldType]
    def column_type(index)
      FFI::GDAL::GDAL.GDALRATGetTypeOfCol(@c_pointer, index)
    end

    # @param field_usage [GDALRATFieldUsage]
    # @return [Fixnum] The column number.
    def column_of_usage(field_usage)
      FFI::GDAL::GDAL.GDALRATGetColOfUsage(@c_pointer, field_usage)
    end

    # @param name [String]
    # @param type [FFI::GDAL::GDALRATFieldType]
    # @param usage [FFI::GDAL::GDALRATFieldUsage]
    # @return [Boolean]
    def create_column(name, type, usage)
      !!FFI::GDAL::GDAL.GDALRATCreateColumn(@c_pointer, name, type, usage)
    end

    # @return [Fixnum] The number of rows.
    def row_count
      FFI::GDAL::GDAL.GDALRATGetRowCount(@c_pointer)
    end

    # @return [Fixnum] The number of rows.
    def row_count=(count)
      FFI::GDAL::GDAL.GDALRATSetRowCount(@c_pointer, count)
    end

    # Get the row for a pixel value.
    #
    # @param value [Float]
    # @return [Fixnum]
    def row_of_value(value)
      FFI::GDAL::GDAL.GDALRATGetRowOfValue(@c_pointer, value)
    end

    # @param row [Fixnum]
    # @param field [Fixnum]
    # @return [String]
    def value_to_s(row, field)
      FFI::GDAL::GDAL.GDALRATGetValueAsString(@c_pointer, row, field)
    end

    # @param row [Fixnum]
    # @param field [Fixnum]
    # @return [Fixnum]
    def value_to_i(row, field)
      FFI::GDAL::GDAL.GDALRATGetValueAsInt(@c_pointer, row, field)
    end

    # @param row [Fixnum]
    # @param field [Fixnum]
    # @return [Float]
    def value_to_f(row, field)
      FFI::GDAL::GDAL.GDALRATGetValueAsDouble(@c_pointer, row, field)
    end

    # @param row [Fixnum]
    # @param field [Fixnum]
    # @param value [String, Float, Fixnum]
    def add_value(row, field, value)
      case value.class.name
      when 'String'
        FFI::GDAL::GDAL.GDALRATSetValueAsString(@c_pointer, row, field, value)
      when 'Float'
        FFI::GDAL::GDAL.GDALRATSetValueAsDouble(@c_pointer, row, field, value)
      when 'Fixnum'
        FFI::GDAL::GDAL.GDALRATSetValueAsInt(@c_pointer, row, field, value)
      else
        fail "Unknown value type for value '#{value}'"
      end
    end

    # @return [Hash{row_0_minimum => Float, bin_size => Float}]
    def linear_binning
      row_0_min_ptr = FFI::MemoryPointer.new(:double)
      bin_size_ptr = FFI::MemoryPointer.new(:double)
      FFI::GDAL::GDAL.GDALRATGetLinearBinning(@c_pointer, row_0_min_ptr, bin_size_ptr)

      {
        row_0_minimum: row_0_min_ptr.read_double,
        bin_size: bin_size_ptr.read_double
      }
    end

    # @param entry_count [Fixnum] The number of entries to produce.  The default
    #   will try to auto-determine the number.
    # @return [GDAL::ColorTable]
    def to_color_table(entry_count = -1)
      color_table_pointer = FFI::GDAL::GDAL.GDALRATTranslateToColorTable(@c_pointer, entry_count)

      GDAL::ColorTable.new(color_table_pointer)
    end

    # @param file_path [String]
    def dump_readable(file_path = nil)
      file = if file_path
               File.open(file_path, 'r')
             else
               file_path
             end
      FFI::GDAL::GDAL.GDALRATDumpReadable(@c_pointer, file)
    end
  end
end
