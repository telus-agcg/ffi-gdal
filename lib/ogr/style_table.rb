require_relative '../ffi/ogr'

module OGR
  class StyleTable
    include FFI::GDAL

    # @param style_table [OGR::StyleTable, FFI::Pointer]
    def initialize(style_table)
      @ogr_style_table_pointer = if style_table.is_a? OGR::StyleTable
        style_table.c_pointer
      else
        style_table
      end
    end

    def c_pointer
      @ogr_style_table_pointer
    end
  end
end
