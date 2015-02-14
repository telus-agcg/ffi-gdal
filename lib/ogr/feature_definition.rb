require_relative '../ffi/ogr'
require_relative 'feature_definition_extensions'
require_relative 'field'

module OGR
  class FeatureDefinition
    include FeatureDefinitionExtensions

    # @param name_or_pointer [String, FFI::Pointer] When given a String, it will
    #   create a new FeatureDefinition with that name. When given an
    #   FFI::Pointer, the new object will simply wrap the C FeatureDefinition
    #   at that address.
    def initialize(name_or_pointer)
      @feature_definition_pointer = if name_or_pointer.is_a? String
                                      FFI::GDAL.OGR_FD_Create(name_or_pointer)
                                    else
                                      name_or_pointer
                                    end

      if !@feature_definition_pointer.is_a?(FFI::Pointer) || @feature_definition_pointer.null?
        fail OGR::InvalidFeatureDefinition, "Unable to create #{self.class.name} from #{name_or_pointer}"
      end

      close_me = -> { FFI::GDAL.OGR_FD_Destroy(@feature_definition_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @feature_definition_pointer
    end

    def release!
      FFI::GDAL.OGR_FD_Release(@feature_definition_pointer)
    end

    # @return [String]
    def name
      FFI::GDAL.OGR_FD_GetName(@feature_definition_pointer)
    end

    # @return [Fixnum]
    def field_count
      FFI::GDAL.OGR_FD_GetFieldCount(@feature_definition_pointer)
    end

    # Note that this returns an OGR::Field, not an OGR::FieldDefinition.
    #
    # @param index [Fixnum]
    # @return [OGR::Field]
    def field_definition(index)
      field_definition_ptr =
        FFI::GDAL.OGR_FD_GetFieldDefn(@feature_definition_pointer, index)
      return nil if field_definition_ptr.null?

      OGR::Field.new(field_definition_ptr, nil)
    end

    # @param new_field_definition [OGR::Field, FFI::Pointer]
    def add_field_definition(field)
      field_ptr = GDAL._pointer(OGR::Field, field)

      if field_ptr.nil?
        fail OGR::InvalidField, "Unable to add OGR::Field: '#{field}'"
      end

      FFI::GDAL.OGR_FD_AddFieldDefn(@feature_definition_pointer, field_ptr)
    end

    # @param index [Fixnum] Index of the field definition to delete.
    # @return [Boolean]
    def delete_field_definition(index)
      ogr_err = FFI::GDAL.OGR_FD_DeleteFieldDefn(
        @feature_definition_pointer,
        index)

      ogr_err.handle_result "Unable to delete field definition at index #{index}"
    end

    # @param name [String]
    # @return [Fixnum] nil if no match found
    def field_index(name)
      result = FFI::GDAL.OGR_FD_GetFieldIndex(@feature_definition_pointer, name)

      result < 0 ? nil : result
    end

    # @return [FFI::GDAL::OGRwkbGeometryType]
    def geometry_type
      FFI::GDAL.OGR_FD_GetGeomType(@feature_definition_pointer)
    end

    # @param new_type [FFI::GDAL::OGRwkbGeometryType]
    def geometry_type=(new_type)
      FFI::GDAL.OGR_FD_SetGeomType(@feature_definition_pointer, new_type)
    end

    # @return [Boolean]
    def geometry_ignored?
      FFI::GDAL.OGR_FD_IsGeometryIgnored(@feature_definition_pointer)
    end

    # @param ignore [Boolean]
    def ignore_geometry!(ignore = true)
      FFI::GDAL.OGR_FD_SetGeometryIgnored(@feature_definition_pointer, ignore)
    end

    # @return [Boolean]
    def style_ignored?
      FFI::GDAL.OGR_FD_IsStyleIgnored(@feature_definition_pointer)
    end

    # @param ignore [Boolean]
    def ignore_style!(ignore = true)
      FFI::GDAL.OGR_FD_SetStyleIgnored(@feature_definition_pointer, ignore)
    end

    # @return [Fixnum]
    def geometry_field_count
      FFI::GDAL.OGR_FD_GetGeomFieldCount(@feature_definition_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::Field]
    def geometry_field_definition(index)
      geometry_field_definition_ptr =
        FFI::GDAL.OGR_FD_GetGeomFieldDefn(@feature_definition_pointer, index)
      return nil if geometry_field_definition_ptr.null?

      OGR::GeometryFieldDefinition.new(geometry_field_definition_ptr)
    end

    # @param name [String]
    # @return [Fixnum]
    def geometry_field_index(name)
      result = FFI::GDAL.OGR_FD_GetGeomFieldIndex(@feature_definition_pointer, name)

      result < 0 ? nil : result
    end

    # @param geometry_field_definition [OGR::GeometryFieldDefinition, FFI::Pointer]
    def add_geometry_field_definition(geometry_field_definition)
      geometry_field_definition_ptr = GDAL._pointer(OGR::GeometryFieldDefinition,
        geometry_field_definition)
      FFI::GDAL.OGR_FD_AddGeomFieldDefn(@feature_definition_pointer,
        geometry_field_definition_ptr)
    end

    # @param index [Fixnum]
    # @return [Boolean]
    def delete_geometry_field_definition(index)
      ogr_err = FFI::GDAL.OGR_FD_DeleteGeomFieldDefn(@feature_definition_pointer,
        index)

      ogr_err.handle_result "Unable to delete geometry field definition at index #{index}"
    end

    # @param other_feature_definition [OGR::Feature, FFI::Pointer]
    # @return [Boolean]
    def same?(other_feature_definition)
      fd_ptr = GDAL._pointer(OGR::FeatureDefinition, other_feature_definition)

      FFI::GDAL.OGR_FD_IsSame(@feature_definition_pointer, fd_ptr)
    end
  end
end
