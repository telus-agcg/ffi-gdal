require_relative '../ffi/ogr'
require_relative 'style_table_extensions'

module OGR
  class StyleTable
    include StyleTableExtensions

    def initialize
      @style_table_pointer = FFI::GDAL.OGR_STBL_Create

      if @style_table_pointer.null?
        fail "Unable to create StyleTable using class #{style_table_class}"
      end
    end

    def c_pointer
      @style_table_pointer
    end

    def destroy!
      FFI::GDAL.OGR_STBL_Destroy(@style_table_pointer)
      @style_table_pointer = nil
    end

    # @param name [String] Name of the style.
    # @param style [String]
    # @return [Boolean]
    def add_style(name, style)
      FFI::GDAL.OGR_STBL_AddStyle(@style_table_pointer, name, style)
    end

    # @param style_name [String]
    # @return [String, nil]
    def find(style_name)
      FFI::GDAL.OGR_STBL_Find(@style_table_pointer, style_name)
    end

    # @return [String, nil] The style name of the last string fetched with #next_style.
    def last_style_name
      FFI::GDAL.OGR_STBL_GetLastStyleName(@style_table_pointer)
    end

    # @return [String, nil] The next style string from the table.
    def next_style
      FFI::GDAL.OGR_STBL_GetNextStyle(@style_table_pointer)
    end

    # @param file_name [String]
    # @return [Boolean]
    def load!(file_name)
      FFI::GDAL.OGR_STBL_LoadStyleTable(@style_table_pointer, file_name)
    end

    # Resets the #next_style to the 0th style.
    def reset_style_string_reading
      FFI::GDAL.OGR_STBL_ResetStyleStringReading(@style_table_pointer)
    end

    # @param file_name [String] Path to the file to save to.
    # @return [Boolean]
    def save(file_name)
      FFI::GDAL.OGR_STBL_SaveStyleTable(@style_table_pointer, file_name)
    end
  end
end
