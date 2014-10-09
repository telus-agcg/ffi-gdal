require_relative '../ffi/ogr'
require_relative 'field'

module OGR
  class FeatureDefinition
    include FFI::GDAL

    def self.create(name)
      feature_defn_pointer = FFI::GDAL.OGR_FD_Create(name)
      return nil if feature_defn_pointer.null?

      new(feature_defn_pointer)
    end

    # @param name [String]
    def initialize(feature_definition)
      @feature_definition_pointer = if feature_definition.is_a? OGR::FeatureDefinition
        feature_definition.c_pointer
      else
        feature_definition
      end

      close_me = -> { FFI::GDAL.OGR_FD_Destroy(@feature_definition_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @feature_definition_pointer
    end

    # @return [String]
    def name
      OGR_FD_GetName(@feature_definition_pointer)
    end

    # @return [Fixnum]
    def field_count
      OGR_FD_GetFieldCount(@feature_definition_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::Field]
    def field(index)
      field_ptr = OGR_FD_GetFieldDefn(@feature_definition_pointer)
      return nil if field_ptr.null?

      OGR::Field.new(field_ptr)
    end

    # @param name [String]
    # @return [Fixnum] -1 if no match found
    def field_index(name)
      OGR_FD_GetFieldIndex(@feature_definition_pointer, name)
    end

    # @param name [String]
    # @return [OGR::Field]
    def field_by_name(name)
      field(field_index(name))
    end

    # @return [FFI::GDAL::OGRwkbGeometryType]
    def geometry_type
      OGR_FD_GetGeomType(@feature_definition_pointer)
    end

    # @param new_type [FFI::GDAL::OGRwkbGeometryType]
    def geometry_type=(new_type)
      OGR_FD_SetGeomType(@feature_definition_pointer, new_type)
    end

    # @return [Boolean]
    def geometry_ignored?
      OGR_FD_IsGeometryIgnored(@feature_definition_pointer)
    end

    # @param ignore [Boolean]
    def ignore_geometry!(ignore)
      OGR_FD_SetGeometryIgnored(@feature_definition_pointer, ignore)
    end

    # @return [Boolean]
    def style_ignored?
      OGR_FD_IsStyleIgnored?(@feature_definition_pointer)
    end

    # @param ignore [Boolean]
    def ignore_style!(ignore)
      OGR_FD_SetStyleIgnored(@feature_definition_pointer, ignore)
    end

    # @return [Fixnum]
    def geometry_field_count
      OGR_FD_GetGeomFieldCount(@feature_definition_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::Field]
    def geometry_field_definition(index)
      field_ptr = OGR_FD_GetGeomFieldDefn(@feature_definition_pointer, index)
      return nil if field_ptr.null?

      OGR::Field.new(field_ptr)
    end

    # @param name [String]
    # @return [Fixnum]
    def geometry_field_index(name)
      OGR_FD_GetGeomFieldIndex(@feature_definition_pointer, name)
    end

    # @param name [String]
    # @return [OGR::Field]
    def geometry_field_by_name(name)
      geometry_field_definition(geometry_field_index(name))
    end

    # @param other_feature_defintion [OGR::Feature, FFI::Pointer]
    # @return [Boolean]
    def same?(other_feature_defintion)
      fd_ptr = if other_feature_defintion.is_a? OGR::FeatureDefinition
        other_feature_defintion.c_pointer
      else
        other_feature_defintion
      end

      OGR_FD_IsSame(@feature_definition_pointer, fd_ptr)
    end
    alias_method :==, :same?
  end
end
