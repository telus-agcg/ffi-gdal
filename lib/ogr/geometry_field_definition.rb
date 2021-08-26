# frozen_string_literal: true

require_relative 'new_borrowed'

module OGR
  class GeometryFieldDefinition
    class AutoPointer < ::FFI::AutoPointer
      def self.release(c_pointer)
        return if c_pointer.nil? || c_pointer.null?

        FFI::OGR::API.OGR_GFld_Destroy(c_pointer)
      end
    end

    # @param field_name [String]
    # @param geometry_type [FFI::OGR::Core::WKBGeometryType]
    def self.create(field_name, geometry_type)
      pointer = FFI::OGR::API.OGR_GFld_Create(field_name, geometry_type)

      raise OGR::InvalidGeometryFieldDefinition, "Unable to create #{name} from #{field_name}" if pointer.null?

      new(OGR::GeometryFieldDefinition::AutoPointer.new(pointer))
    end

    extend OGR::NewBorrowed

    # @return [OGR::GeometryFieldDefinition::AutoPointer, FFI::Pointer]
    attr_reader :c_pointer

    # @param c_pointer [OGR::GeometryFieldDefinition::AutoPointer, FFI::Pointer]
    def initialize(c_pointer)
      if !c_pointer.is_a?(FFI::Pointer) || c_pointer.null?
        raise FFI::GDAL::InvalidPointer, "Can't instantiate GeometryFieldDefinition from null pointer"
      end

      @c_pointer = c_pointer
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_GFld_GetNameRef(@c_pointer).freeze
    end

    # @param new_name [String]
    def name=(new_name)
      FFI::OGR::API.OGR_GFld_SetName(@c_pointer, new_name)
    end

    # @return [FFI::OGR::API::WKBGeometryType]
    def type
      FFI::OGR::API.OGR_GFld_GetType(@c_pointer)
    end

    # @param new_type [FFI::OGR::API::WKBGeometryType]
    def type=(new_type)
      FFI::OGR::API.OGR_GFld_SetType(@c_pointer, new_type)
    end

    # @return [OGR::SpatialReference, nil]
    def spatial_reference
      spatial_ref_ptr = FFI::OGR::API.OGR_GFld_GetSpatialRef(@c_pointer)

      return if spatial_ref_ptr.null?

      OGR::SpatialReference.new_borrowed(spatial_ref_ptr)
    end

    # This function drops the reference of the previously set SRS object and
    # acquires a new reference on the passed object (if non-NULL).
    #
    # @param new_spatial_reference [OGR::SpatialReference]
    # @raise [FFI::GDAL::InvalidPointer]
    def spatial_reference=(new_spatial_reference)
      spatial_ref = OGR::SpatialReference.new_borrowed(new_spatial_reference.c_pointer)

      FFI::OGR::API.OGR_GFld_SetSpatialRef(
        @c_pointer,
        spatial_ref.c_pointer
      )
    end

    # @return [Boolean]
    def ignored?
      FFI::OGR::API.OGR_GFld_IsIgnored(@c_pointer)
    end

    # @param value [Boolean]
    def ignore=(value)
      FFI::OGR::API.OGR_GFld_SetIgnored(@c_pointer, value)
    end

    # @return [Boolean]
    def nullable?
      FFI::OGR::API::OGR_GFld_IsNullable(@c_pointer)
    end

    # @param is_nullable [bool]
    def nullable=(is_nullable)
      FFI::OGR::API::OGR_GFld_SetNullable(@c_pointer, is_nullable)
    end
  end
end
