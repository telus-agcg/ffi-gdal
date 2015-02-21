require_relative 'geometry_field_definition_extensions'

module OGR
  class GeometryFieldDefinition
    include GeometryFieldDefinitionExtensions

    # @param name_or_pointer [String, FFI::Pointer]
    # @param type [FFI::OGR::API::WKBGeometryType]
    def initialize(name_or_pointer, type = :wkbUnknown)
      @geometry_field_definition_pointer =
        if name_or_pointer.is_a? String
          FFI::OGR::API.OGR_GFld_Create(name_or_pointer, type)
        else
          name_or_pointer
        end

      unless @geometry_field_definition_pointer.is_a?(FFI::Pointer) && !@geometry_field_definition_pointer.null?
        fail OGR::InvalidGeometryFieldDefinition,
          "Unable to create #{self.class.name} from #{name_or_pointer}"
      end

      @read_only = false
    end

    # @param value [Boolean]
    def read_only=(value)
      @read_only = value
    end

    def c_pointer
      @geometry_field_definition_pointer
    end

    def destroy!
      FFI::OGR::API.OGR_GFld_Destroy(@geometry_field_definition_pointer)
      @geometry_field_definition_pointer = nil
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_GFld_GetNameRef(@geometry_field_definition_pointer)
    end

    # @param new_name [String]
    def name=(new_name)
      fail OGR::ReadOnlyObject if @read_only

      FFI::OGR::API.OGR_GFld_SetName(@geometry_field_definition_pointer, new_name)
    end

    # @return [FFI::OGR::API::WKBGeometryType]
    def type
      FFI::OGR::API.OGR_GFld_GetType(@geometry_field_definition_pointer)
    end

    # @param new_type [FFI::OGR::API::WKBGeometryType]
    def type=(new_type)
      fail OGR::ReadOnlyObject if @read_only

      FFI::OGR::API.OGR_GFld_SetType(@geometry_field_definition_pointer, new_type)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_ptr = FFI::OGR::API.OGR_GFld_GetSpatialRef(@geometry_field_definition_pointer)

      if spatial_ref_ptr.nil? || spatial_ref_ptr.null?
        nil
      else
        OGR::SpatialReference.new(spatial_ref_ptr)
      end
    end

    # @param new_spatial_reference [OGR::SpatialReference, FFI::Pointer]
    def spatial_reference=(new_spatial_reference)
      fail OGR::ReadOnlyObject if @read_only

      spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, new_spatial_reference)

      FFI::OGR::API.OGR_GFld_SetSpatialRef(
        @geometry_field_definition_pointer,
        spatial_ref_ptr)
    end

    # @return [Boolean]
    def ignored?
      FFI::OGR::API.OGR_GFld_IsIgnored(@geometry_field_definition_pointer)
    end

    # @param value [Boolean]
    def ignore=(value)
      fail OGR::ReadOnlyObject if @read_only

      FFI::OGR::API.OGR_GFld_SetIgnored(@geometry_field_definition_pointer, value)
    end
  end
end
