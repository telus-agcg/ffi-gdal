require_relative '../ffi/ogr'
require_relative 'field_definition'

module OGR
  class FeatureDefinition
    include FFI::GDAL

    def self.create(name)
      ogr_feature_defn_pointer = OGR_FD_Create(name)

      new(ogr_field_defn_pointer)
    end

    # @param name [String]
    def initialize(feature_definition)
      @ogr_feature_defn_pointer = if feature_definition.is_a? OGR::FeatureDefinition
        feature_definition.c_pointer
      else
        feature_definition
      end

      close_me = -> { FFI::GDAL.OGR_FD_Destroy(@ogr_feature_defn_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @ogr_feature_defn_pointer
    end

    # @return [String]
    def name
      OGR_FD_GetName(@ogr_feature_defn_pointer)
    end

    # @return [Fixnum]
    def field_count
      OGR_FD_GetFieldCount(@ogr_feature_defn_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::FieldDefinition]
    def field_definition(index)
      field_def_ptr = OGR_FD_GetFieldDefn(@ogr_feature_defn_pointer)
      return nil if field_def_ptr.null?

      OGR::FieldDefinition.new(field_def_ptr)
    end

    # @param name [String]
    # @return [Fixnum] -1 if no match found
    def field_index(name)
      OGR_FD_GetFieldIndex(@ogr_feature_defn_pointer, name)
    end

    # @param name [String]
    # @return [OGR::FieldDefinition]
    def field_by_name(name)
      field_definition(field_index(name))
    end

    # @return [FFI::GDAL::OGRwkbGeometryType]
    def geometry_type
      OGR_FD_GetGeomType(@ogr_feature_defn_pointer)
    end

    # @param new_type [FFI::GDAL::OGRwkbGeometryType]
    def geometry_type=(new_type)
      OGR_FD_SetGeomType(@ogr_feature_defn_pointer, new_type)
    end

    # @return [Boolean]
    def geometry_ignored?
      OGR_FD_IsGeometryIgnored(@ogr_feature_defn_pointer)
    end

    # @param ignore [Boolean]
    def ignore_geometry!(ignore)
      OGR_FD_SetGeometryIgnored(@ogr_feature_defn_pointer, ignore)
    end

    # @return [Boolean]
    def style_ignored?
      OGR_FD_IsStyleIgnored?(@ogr_feature_defn_pointer)
    end

    # @param ignore [Boolean]
    def ignore_style!(ignore)
      OGR_FD_SetStyleIgnored(@ogr_feature_defn_pointer, ignore)
    end

    # @return [Fixnum]
    def geometry_field_count
      OGR_FD_GetGeomFieldCount(@ogr_feature_defn_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::FieldDefinition]
    def geometry_field_definition(index)
      fd_ptr = OGR_FD_GetGeomFieldDefn(@ogr_feature_defn_pointer, index)
      return nil if fd_ptr.null?

      OGR::FieldDefinition.new(fd_ptr)
    end

    # @param name [String]
    # @return [Fixnum]
    def geometry_field_index(name)
      OGR_FD_GetGeomFieldIndex(@ogr_feature_defn_pointer, name)
    end

    # @param name [String]
    # @return [OGR::FieldDefinition]
    def geometry_field_by_name(name)
      geometry_field_definition(geometry_field_index(name))
    end

    # @param other_field_defintion [OGR::FieldDefinition, FFI::Pointer]
    # @return [Boolean]
    def same?(other_field_defintion)
      fd_ptr = if other_field_defintion.is_a? OGR::FieldDefinition
        other_field_defintion.c_pointer
      else
        other_field_defintion
      end

      OGR_FD_IsSame(@ogr_feature_defn_pointer, fd_ptr)
    end
    alias_method :==, :same?
  end
end
