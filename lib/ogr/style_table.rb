require_relative '../ffi/ogr'

module OGR
  class StyleTable
    include FFI::GDAL

    def initialize(ogr_style_table_pointer: nil)
      @ogr_style_table_pointer = if ogr_style_table_pointer
        ogr_style_table_pointer
      end
    end

    def c_pointer
      @ogr_style_table_pointer
    end
  end
end
