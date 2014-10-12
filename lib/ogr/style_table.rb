require 'json'
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

    # @return [String]
    def as_json
      'StyleTable interface not yet wrapped with ffi-ruby'
    end

    # @return [String]
    def to_json
      as_json.to_json
    end
  end
end
