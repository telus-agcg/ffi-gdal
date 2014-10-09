require_relative '../ffi/ogr'

module OGR
  class Field
    # @param name [String]
    # @param type [FFI::GDAL::OGRFieldType]
    # @return [OGR::Field]
    def self.create(name, type)
      field_ptr = FFI::GDAL.OGR_Fld_Create(name, type)
      return nil if field_ptr.null?

      new(field_ptr)
    end

    # @param field [OGR::Field, FFI::Pointer]
    def initialize(field)
      @field_pointer = GDAL._pointer(OGR::Field, field)
    end

    def c_pointer
      @field_pointer
    end

    def destroy!
      FFI::GDAL.OGR_Fld_Destroy(@field_pointer)
    end

    # @return [String]
    def name
      FFI::GDAL.OGR_Fld_GetNameRef(@field_pointer)
    end

    # @param new_value [String]
    def name=(new_value)
      FFI::GDAL.OGR_Fld_SetName(@field_pointer, new_value)
    end

    # @return [FFI::GDAL::OGRJustification]
    def justification
      FFI::GDAL.OGR_Fld_GetJustify(@field_pointer)
    end

    # @param new_value [FFI::GDAL::OGRJustification]
    def justification=(new_value)
      FFI::GDAL.OGR_Fld_SetJustify(@field_pointer, new_value)
    end

    # @return [Fixnum]
    def precision
      FFI::GDAL.OGR_Fld_GetPrecision(@field_pointer)
    end

    # @param new_value [Fixnum]
    def precision=(new_value)
      FFI::GDAL.OGR_Fld_SetPrecision(@field_pointer, new_value)
    end

    # @return [FFI::GDAL::OGRFieldType]
    def type
      FFI::GDAL.OGR_Fld_GetType(@field_pointer)
    end

    # @param new_value [FFI::GDAL::OGRFieldType]
    def type=(new_value)
      FFI::GDAL.OGR_Fld_SetType(@field_pointer, new_value)
    end

    # @return [Fixnum]
    def width
      FFI::GDAL.OGR_Fld_GetWidth(@field_pointer)
    end

    # @param new_value [Fixnum]
    def width=(new_value)
      FFI::GDAL.OGR_Fld_SetWidth(@field_pointer, new_value)
    end

    # @return [Boolean]
    def ignored?
      FFI::GDAL.OGR_Fld_IsIgnored(@field_pointer)
    end

    # @param new_value [Boolean]
    def ignore=(new_value)
      FFI::GDAL.OGR_Fld_SetIgnored(@field_pointer, new_value)
    end
  end
end
