# frozen_string_literal: true

require_relative '../ogr'

module OGR
  class FieldDefinition
    # @return [FFI::Pointer] C pointer to the C FieldDefn.
    attr_reader :c_pointer

    # @param pointer [FFI::Pointer]
    def self.release(pointer)
      FFI::OGR::API.OGR_Fld_Destroy(pointer) unless pointer.nil? || pointer.null?
    end

    # @param name_or_pointer [String, FFI::Pointer]
    # @param type [FFI::OGR::FieldType]
    def initialize(name_or_pointer, type)
      @c_pointer = if name_or_pointer.is_a? String
                     FFI::OGR::API.OGR_Fld_Create(name_or_pointer, type)
                   else
                     name_or_pointer
                   end

      return if @c_pointer.is_a?(FFI::Pointer) && !@c_pointer.null?

      raise OGR::InvalidFieldDefinition, "Unable to create #{self.class.name} from #{name_or_pointer}"
    end

    def destroy!
      FieldDefinition.release(@c_pointer)

      @c_pointer = nil
    end

    # Set all defining attributes in one call.
    #
    # @param name [String]
    # @param type [FFI::OGR::FieldType]
    # @param width [Integer]
    # @param precision [Integer]
    # @param justification [FFI::OGR::Justification]
    def set(name, type, width, precision, justification)
      FFI::OGR::API.OGR_Fld_Set(
        @c_pointer,
        name,
        type,
        width,
        precision,
        justification
      )
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_Fld_GetNameRef(@c_pointer)
    end

    # @param new_value [String]
    def name=(new_value)
      FFI::OGR::API.OGR_Fld_SetName(@c_pointer, new_value)
    end

    # @return [FFI::OGR::Justification]
    def justification
      FFI::OGR::API.OGR_Fld_GetJustify(@c_pointer)
    end

    # @param new_value [FFI::OGR::Justification]
    def justification=(new_value)
      FFI::OGR::API.OGR_Fld_SetJustify(@c_pointer, new_value)
    end

    # @return [Integer]
    def precision
      FFI::OGR::API.OGR_Fld_GetPrecision(@c_pointer)
    end

    # @param new_value [Integer]
    def precision=(new_value)
      FFI::OGR::API.OGR_Fld_SetPrecision(@c_pointer, new_value)
    end

    # @return [FFI::OGR::FieldType]
    def type
      FFI::OGR::API.OGR_Fld_GetType(@c_pointer)
    end

    # @param new_value [FFI::OGR::FieldType]
    def type=(new_value)
      FFI::OGR::API.OGR_Fld_SetType(@c_pointer, new_value)
    end

    # @return [Integer]
    def width
      FFI::OGR::API.OGR_Fld_GetWidth(@c_pointer)
    end

    # @param new_value [Integer]
    def width=(new_value)
      FFI::OGR::API.OGR_Fld_SetWidth(@c_pointer, new_value)
    end

    # @return [Boolean]
    def ignored?
      FFI::OGR::API.OGR_Fld_IsIgnored(@c_pointer)
    end

    # @param new_value [Boolean]
    def ignore=(new_value)
      FFI::OGR::API.OGR_Fld_SetIgnored(@c_pointer, new_value)
    end
  end
end
