module OGR
  class GeometryFieldDefinition
    # @param name [String]
    # @param type [FFI::GDAL::OGRwkbGeometryType]
    def initialize(name, type = :wkbUnknown)
      @geometry_field_definition_pointer = FFI::GDAL.OGR_GFld_Create(name, type)
      @spatial_reference = nil
    end

    def c_pointer
      @geometry_field_definition_pointer
    end

    def destroy!
      FFI::GDAL.OGR_GFld_Destroy(@geometry_field_definition_pointer)
      @geometry_field_definition_pointer = nil
    end

    # @return [String]
    def name
      FFI::GDAL.OGR_GFld_GetNameRef(@geometry_field_definition_pointer)
    end

    # @param new_name [String]
    def name=(new_name)
      FFI::GDAL.OGR_GFld_SetName(@geometry_field_definition_pointer, new_name)
    end

    # @return [FFI::GDAL::OGRwkbGeometryType]
    def type
      FFI::GDAL.OGR_GFld_GetType(@geometry_field_definition_pointer)
    end

    # @param new_type [FFI::GDAL::OGRwkbGeometryType]
    def type=(new_type)
      FFI::GDAL.OGR_GFld_SetType(@geometry_field_definition_pointer, new_type)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      return @spatial_reference if @spatial_reference

      spatial_ref_ptr = FFI::GDAL.OGR_GFld_GetSpatialRef(@geometry_field_definition_pointer)

      if spatial_ref_ptr.nil? || spatial_ref_ptr.null?
        nil
      else
        @spatial_reference = OGR::SpatialReference.new(spatial_ref_ptr)
      end
    end

    # @param new_spatial_reference [OGR::SpatialReference, FFI::Pointer]
    def spatial_reference=(new_spatial_reference)
      spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, new_spatial_reference)

      FFI::GDAL.OGR_GFld_SetSpatialRef(
        @geometry_field_definition_pointer,
        spatial_ref_ptr)

      @spatial_reference =
        if new_spatial_reference.instance_of?(OGR::SpatialReference)
          new_spatial_reference
        else
          OGR::SpatialReference.new(spatial_ref_ptr)
        end
    end

    # @return [Boolean]
    def ignored?
      FFI::GDAL.OGR_GFld_IsIgnored(@geometry_field_definition_pointer)
    end
  end
end
