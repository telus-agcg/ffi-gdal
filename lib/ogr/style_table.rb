require_relative '../ffi/ogr'

module OGR
  class StyleTable

    # @param style_table [OGR::StyleTable, FFI::Pointer]
    def initialize(style_table)
      @ogr_style_table_pointer = GDAL._pointer(OGR::StyleTable, style_table)
    end

    def c_pointer
      @ogr_style_table_pointer
    end
  end
end
