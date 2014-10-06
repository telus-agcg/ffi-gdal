require_relative '../ffi/ogr'

module OGR
  class FieldDefinition
    include FFI::GDAL

    def initialize(ogr_field_definition)
      @ogr_field_defn_pointer = ogr_field_defn_pointer
    end

    def c_pointer
      @ogr_field_defn_pointer
    end
  end
end
