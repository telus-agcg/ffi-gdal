# frozen_string_literal: true

module OGR
  class GeometryFieldDefinition
    # @return [FFI::Pointer]
    attr_reader :c_pointer

    # @param value [Boolean]
    attr_writer :read_only

    # @param name_or_pointer [String, FFI::Pointer]
    # @param type [FFI::OGR::API::WKBGeometryType]
    def initialize(name_or_pointer, type = :wkbUnknown)
      @c_pointer =
        if name_or_pointer.is_a? String
          FFI::OGR::API.OGR_GFld_Create(name_or_pointer, type)
        else
          name_or_pointer
        end

      unless @c_pointer.is_a?(FFI::Pointer) && !@c_pointer.null?
        raise OGR::InvalidGeometryFieldDefinition,
          "Unable to create #{self.class.name} from #{name_or_pointer}"
      end

      @read_only = false
    end

    # @return [Boolean]
    def read_only?
      @read_only || false
    end

    def destroy!
      return unless @c_pointer

      FFI::OGR::API.OGR_GFld_Destroy(@c_pointer)
      @c_pointer = nil
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_GFld_GetNameRef(@c_pointer)
    end

    # @param new_name [String]
    def name=(new_name)
      raise OGR::ReadOnlyObject if @read_only

      FFI::OGR::API.OGR_GFld_SetName(@c_pointer, new_name)
    end

    # @return [FFI::OGR::API::WKBGeometryType]
    def type
      FFI::OGR::API.OGR_GFld_GetType(@c_pointer)
    end

    # @param new_type [FFI::OGR::API::WKBGeometryType]
    def type=(new_type)
      raise OGR::ReadOnlyObject if @read_only

      FFI::OGR::API.OGR_GFld_SetType(@c_pointer, new_type)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_ptr = FFI::OGR::API.OGR_GFld_GetSpatialRef(@c_pointer)

      if spatial_ref_ptr.nil? || spatial_ref_ptr.null?
        nil
      else
        OGR::SpatialReference.new(spatial_ref_ptr)
      end
    end

    # @param new_spatial_reference [OGR::SpatialReference, FFI::Pointer]
    def spatial_reference=(new_spatial_reference)
      raise OGR::ReadOnlyObject if @read_only

      spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, new_spatial_reference)

      FFI::OGR::API.OGR_GFld_SetSpatialRef(
        @c_pointer,
        spatial_ref_ptr
      )
    end

    # @return [Boolean]
    def ignored?
      FFI::OGR::API.OGR_GFld_IsIgnored(@c_pointer)
    end

    # @param value [Boolean]
    def ignore=(value)
      raise OGR::ReadOnlyObject if @read_only

      FFI::OGR::API.OGR_GFld_SetIgnored(@c_pointer, value)
    end
  end
end
