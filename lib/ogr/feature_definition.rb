# frozen_string_literal: true

require_relative '../gdal'
require_relative '../ogr'
require_relative 'new_borrowed'

module OGR
  class FeatureDefinition
    class AutoPointer < ::FFI::AutoPointer
      # @param pointer [FFI::Pointer]
      def self.release(pointer)
        return unless pointer && !pointer.null?

        FFI::OGR::API.OGR_FD_Release(pointer)
      end
    end

    # @param feature_name [String]
    # @return [OGR::FeatureDefinition]
    def self.create(feature_name)
      pointer = FFI::OGR::API.OGR_FD_Create(feature_name)

      raise OGR::InvalidFeatureDefinition, "Unable to create #{name} from #{feature_name}" if pointer.null?

      new(OGR::FeatureDefinition::AutoPointer.new(pointer))
    end

    extend OGR::NewBorrowed

    # @return [FFI::Pointer] C pointer of the C FeatureDefn.
    attr_reader :c_pointer

    # @param pointer [FFI::Pointer]
    def initialize(pointer)
      @c_pointer = pointer
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_FD_GetName(@c_pointer).freeze
    end

    # @return [Integer]
    def field_count
      FFI::OGR::API.OGR_FD_GetFieldCount(@c_pointer)
    end

    # @param index [Integer]
    # @return [OGR::FieldDefinition]
    def field_definition(index)
      OGR::FieldDefinition.new_borrowed(FFI::OGR::API.OGR_FD_GetFieldDefn(@c_pointer, index))
    end

    # @param field_definition [OGR::FieldDefinition, FFI::Pointer]
    # @raise [FFI::GDAL::InvalidPointer]
    def add_field_definition(field_definition)
      field_definition_ptr = GDAL._pointer(field_definition)

      FFI::OGR::API.OGR_FD_AddFieldDefn(@c_pointer, field_definition_ptr)
    end

    # @param index [Integer] Index of the field definition to delete.
    # @raise [OGR::Failure]
    def delete_field_definition(index)
      OGR::ErrorHandling.handle_ogr_err("Unable to delete field definition at index #{index}") do
        FFI::OGR::API.OGR_FD_DeleteFieldDefn(
          @c_pointer,
          index
        )
      end
    end

    # @param name [String]
    # @return [Integer] nil if no match found
    def field_index(name)
      result = FFI::OGR::API.OGR_FD_GetFieldIndex(@c_pointer, name)

      result.negative? ? nil : result
    end

    # @return [FFI::OGR::API::WKBGeometryType]
    def geometry_type
      FFI::OGR::API.OGR_FD_GetGeomType(@c_pointer)
    end

    # @param new_type [FFI::OGR::API::WKBGeometryType]
    def geometry_type=(new_type)
      FFI::OGR::API.OGR_FD_SetGeomType(@c_pointer, new_type)
    end

    # @return [Boolean]
    def geometry_ignored?
      FFI::OGR::API.OGR_FD_IsGeometryIgnored(@c_pointer)
    end

    # @param ignore [Boolean]
    def ignore_geometry!(ignore: true)
      FFI::OGR::API.OGR_FD_SetGeometryIgnored(@c_pointer, ignore)
    end

    # @return [Boolean]
    def style_ignored?
      FFI::OGR::API.OGR_FD_IsStyleIgnored(@c_pointer)
    end

    # @param ignore [Boolean]
    def ignore_style!(ignore: true)
      FFI::OGR::API.OGR_FD_SetStyleIgnored(@c_pointer, ignore)
    end

    # @return [Integer]
    def geometry_field_count
      FFI::OGR::API.OGR_FD_GetGeomFieldCount(@c_pointer)
    end

    # @param index [Integer]
    # @return [OGR::GeometryFieldDefinition]
    def geometry_field_definition(index)
      OGR::GeometryFieldDefinition.new_borrowed(FFI::OGR::API.OGR_FD_GetGeomFieldDefn(@c_pointer, index))
    end

    # @param name [String]
    # @return [Integer]
    def geometry_field_index(name)
      result = FFI::OGR::API.OGR_FD_GetGeomFieldIndex(@c_pointer, name)

      result.negative? ? nil : result
    end

    # @param geometry_field_definition [OGR::GeometryFieldDefinition, FFI::Pointer]
    # @raise [FFI::GDAL::InvalidPointer]
    def add_geometry_field_definition(geometry_field_definition)
      geometry_field_definition_ptr = GDAL._pointer(geometry_field_definition)
      FFI::OGR::API.OGR_FD_AddGeomFieldDefn(@c_pointer, geometry_field_definition_ptr)
    end

    # @param index [Integer]
    # @raise [OGR::Failure]
    def delete_geometry_field_definition(index)
      OGR::ErrorHandling.handle_ogr_err("Unable to delete geometry field definition at index #{index}") do
        FFI::OGR::API.OGR_FD_DeleteGeomFieldDefn(@c_pointer, index)
      end
    end

    # @param other_feature_definition [OGR::Feature, FFI::Pointer]
    # @return [Boolean]
    # @raise [FFI::GDAL::InvalidPointer]
    def same?(other_feature_definition)
      fd_ptr = GDAL._pointer(other_feature_definition)

      FFI::OGR::API.OGR_FD_IsSame(@c_pointer, fd_ptr)
    end
  end
end
