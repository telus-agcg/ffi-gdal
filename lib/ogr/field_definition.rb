require_relative '../ffi/ogr'
require_relative 'field_definition_extensions'

module OGR
  class FieldDefinition
    include FieldDefinitionExtensions

    # @param name_or_pointer [String, FFI::Pointer]
    # @param type [FFI::OGR::FieldType]
    def initialize(name_or_pointer, type)
      @field_pointer = if name_or_pointer.is_a? String
                         FFI::OGR::API.OGR_Fld_Create(name_or_pointer, type)
                       else
                         name_or_pointer
                       end

      unless @field_pointer.is_a?(FFI::Pointer) && !@field_pointer.null?
        fail OGR::InvalidFieldDefinition, "Unable to create #{self.class.name} from #{name_or_pointer}"
      end

      ObjectSpace.define_finalizer(self, -> { destroy! })
    end

    def c_pointer
      @field_pointer
    end

    def destroy!
      FFI::OGR::API.OGR_Fld_Destroy(@field_pointer)
      @field_pointer = nil
    end

    # Set all defining attributes in one call.
    #
    # @param name [String]
    # @param type [FFI::OGR::FieldType]
    # @param width [Fixnum]
    # @param precision [Fixnum]
    # @param justification [FFI::OGR::Justification]
    def set(name, type, width, precision, justification)
      FFI::OGR::API.OGR_Fld_Set(
        @field_pointer,
        name,
        type,
        width,
        precision,
        justification
      )
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_Fld_GetNameRef(@field_pointer)
    end

    # @param new_value [String]
    def name=(new_value)
      FFI::OGR::API.OGR_Fld_SetName(@field_pointer, new_value)
    end

    # @return [FFI::OGR::Justification]
    def justification
      FFI::OGR::API.OGR_Fld_GetJustify(@field_pointer)
    end

    # @param new_value [FFI::OGR::Justification]
    def justification=(new_value)
      FFI::OGR::API.OGR_Fld_SetJustify(@field_pointer, new_value)
    end

    # @return [Fixnum]
    def precision
      FFI::OGR::API.OGR_Fld_GetPrecision(@field_pointer)
    end

    # @param new_value [Fixnum]
    def precision=(new_value)
      FFI::OGR::API.OGR_Fld_SetPrecision(@field_pointer, new_value)
    end

    # @return [FFI::OGR::FieldType]
    def type
      FFI::OGR::API.OGR_Fld_GetType(@field_pointer)
    end

    # @param new_value [FFI::OGR::FieldType]
    def type=(new_value)
      FFI::OGR::API.OGR_Fld_SetType(@field_pointer, new_value)
    end

    # @return [Fixnum]
    def width
      FFI::OGR::API.OGR_Fld_GetWidth(@field_pointer)
    end

    # @param new_value [Fixnum]
    def width=(new_value)
      FFI::OGR::API.OGR_Fld_SetWidth(@field_pointer, new_value)
    end

    # @return [Boolean]
    def ignored?
      FFI::OGR::API.OGR_Fld_IsIgnored(@field_pointer)
    end

    # @param new_value [Boolean]
    def ignore=(new_value)
      FFI::OGR::API.OGR_Fld_SetIgnored(@field_pointer, new_value)
    end
  end
end