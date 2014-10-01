require_relative '../ffi/ogr'

module OGR
  class FieldDefinition
    include FFI::GDAL

    def initialize(ogr_field_defn_pointer: nil)
      @ogr_field_defn_pointer = if ogr_field_defn_pointer
        ogr_field_defn_pointer
      end
    end

    def c_pointer
      @ogr_field_defn_pointer
    end
  end
end
