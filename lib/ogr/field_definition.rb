# frozen_string_literal: true

require 'ffi'
require_relative '../ogr'

module OGR
  class FieldDefinition
    class AutoPointer < ::FFI::AutoPointer
      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::OGR::API.OGR_Fld_Destroy(pointer)
      end
    end

    # Use for instantiating an OGR::FieldDefinition from a borrowed pointer (one
    # that shouldn't be freed).
    #
    # @param c_pointer [String, FFI::Pointer]
    # @return [OGR::FieldDefinition]
    def self.new_borrowed(c_pointer)
      raise OGR::InvalidPointer if c_pointer.null?

      c_pointer.autorelease = false

      new(c_pointer)
    end

    # @param field_name [String]
    # @param type [FFI::OGR::Core::FieldType]
    # @return [OGR::FieldDefinition]
    def self.create(field_name, type)
      pointer = FFI::OGR::API.OGR_Fld_Create(field_name, type)

      raise OGR::InvalidFieldDefinition, "Unable to create #{name} from #{field_name}" if pointer.null?

      new(OGR::FieldDefinition::AutoPointer.new(pointer))
    end

    # @param field_type  [FFI::OGR::Core::FieldType]
    # @return [String]
    def self.field_type_name(field_type)
      FFI::OGR::API.OGR_GetFieldTypeName(field_type).freeze
    end

    # @return [FFI::Pointer, OGR::FieldDefinition::AutoPointer] C pointer to the C FieldDefn.
    attr_reader :c_pointer

    # @param c_pointer [FFI::Pointer]
    def initialize(c_pointer)
      @c_pointer = c_pointer
    end

    # Set all defining attributes in one call.
    #
    # @param name [String]
    # @param type [FFI::OGR::FieldType]
    # @param width [Integer] Defaults to 0.
    # @param precision [Integer] Defaults to undefined.
    # @param justification [FFI::OGR::Justification] Defaults to :OJUndefined.
    def set(name, type, width: nil, precision: nil, justification: nil)
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
      FFI::OGR::API.OGR_Fld_GetNameRef(@c_pointer).freeze
    end

    # @param new_name [String]
    def name=(new_name)
      FFI::OGR::API.OGR_Fld_SetName(@c_pointer, new_name)
    end

    # @return [FFI::OGR::Justification]
    def justification
      FFI::OGR::API.OGR_Fld_GetJustify(@c_pointer)
    end

    # @param new_justification [FFI::OGR::Justification]
    def justification=(new_justification)
      FFI::OGR::API.OGR_Fld_SetJustify(@c_pointer, new_justification)
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

    # @param new_type [FFI::OGR::FieldType]
    def type=(new_type)
      FFI::OGR::API.OGR_Fld_SetType(@c_pointer, new_type)
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

    # @return [FFI::OGR::FieldSubType]
    def sub_type
      FFI::OGR::API::OGR_Fld_GetSubType(@c_pointer)
    end

    # @param field_sub_type [FFI::OGR::FieldSubType]
    def sub_type=(field_sub_type)
      FFI::OGR::API::OGR_Fld_SetSubType(@c_pointer, field_sub_type)
    end

    # @return [Boolean]
    def nullable?
      FFI::OGR::API::OGR_Fld_IsNullable(@c_pointer)
    end

    # @param is_nullable [bool]
    def nullable=(is_nullable)
      FFI::OGR::API::OGR_Fld_SetNullable(@c_pointer, is_nullable)
    end

    # Is the default value driver-specific?
    #
    # @return [Boolean]
    def default_driver_specific?
      FFI::OGR::API::OGR_Fld_IsDefaultDriverSpecific(@c_pointer)
    end
  end
end
