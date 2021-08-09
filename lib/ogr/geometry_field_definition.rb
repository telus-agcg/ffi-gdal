# frozen_string_literal: true

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

    # Use for instantiating an OGR::GeometryFieldDefinition from a borrowed
    # pointer (one that shouldn't be freed).
    #
    # @param c_pointer [FFI::Pointer]
    # @return [OGR::GeometryFieldDefinition]
    # @raise [FFI::GDAL::InvalidPointer] if +c_pointer+ is null.
    def self.new_borrowed(c_pointer)
      raise FFI::GDAL::InvalidPointer, "Can't instantiate GeometryFieldDefinition from null pointer" if c_pointer.null?

      c_pointer.autorelease = false

      new(c_pointer).freeze
    end

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
  end
end
