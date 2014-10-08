require_relative '../ffi/ogr'

module OGR
  class Field
    include FFI::GDAL

    def initialize(field)
      @field_pointer = if field.is_a? OGR::Field
        field.c_pointer
      else
        field
      end
    end

    def c_pointer
      @field_pointer
    end
  end
end
