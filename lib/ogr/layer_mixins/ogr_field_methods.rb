# frozen_string_literal: true

module OGR
  module LayerMixins
    module OGRFieldMethods
      CREATE_GEOM_FIELD = 'CreateGeomField'

      # Creates and writes a new field to the layer. This adds the field to the
      # internal FeatureDefinition; C API says not to update the FeatureDefinition
      # directly.
      #
      # @param field_definition [OGR::FieldDefinition]
      # @param approx_ok [Boolean] If +true+ the field may be created in a slightly
      #   different form, depending on the limitations of the format driver.
      # @raise [OGR::Failure]
      # @raise [FFI::GDAL::InvalidPointer]
      def create_field(field_definition, approx_ok: false)
        unless test_capability('CreateField')
          raise OGR::UnsupportedOperation,
                'This layer does not support field creation.'
        end

        field_definition_ptr = GDAL._pointer(field_definition)

        OGR::ErrorHandling.handle_ogr_err('Unable to create field') do
          FFI::OGR::API.OGR_L_CreateField(@c_pointer, field_definition_ptr, approx_ok)
        end
      end

      # Deletes the field definition from the layer.
      #
      # @raise [OGR::Failure]
      def delete_field(field_id)
        unless test_capability('DeleteField')
          raise OGR::UnsupportedOperation,
                'This driver does not support field deletion.'
        end

        OGR::ErrorHandling.handle_ogr_err('Unable to delete field') do
          FFI::OGR::API.OGR_L_DeleteField(@c_pointer, field_id)
        end
      end

      # @param new_order [Array<Integer>] An array that orders field indexes by
      #   which they should be reordered.  I.e. [0, 2, 3, 1, 4].
      # @raise [OGR::Failure]
      def reorder_fields(*new_order)
        unless test_capability('ReorderFields')
          raise OGR::UnsupportedOperation,
                'This driver does not support field reordering.'
        end

        return false if new_order.empty? || new_order.any? { |i| i > feature_definition.field_count }

        map_array_ptr = FFI::MemoryPointer.new(:int, new_order.size).write_array_of_int(new_order)

        OGR::ErrorHandling.handle_ogr_err("Unable to reorder fields using order: #{new_order}") do
          FFI::OGR::API.OGR_L_ReorderFields(@c_pointer, map_array_ptr)
        end
      end

      # Puts the field whose index is +old_position+ into index at +new_position+
      # and shuffles the other indexes accordingly.
      #
      # @param old_position [Integer]
      # @param new_position [Integer]
      # @raise [OGR::Failure]
      def reorder_field(old_position, new_position)
        unless test_capability('ReorderFields')
          raise OGR::UnsupportedOperation,
                'This driver does not support field reordering.'
        end

        OGR::ErrorHandling.handle_ogr_err("Unable to reorder field: #{old_position} to #{new_position}") do
          FFI::OGR::API.OGR_L_ReorderField(@c_pointer, old_position, new_position)
        end
      end

      # @param field_index [Integer]
      # @param new_field_definition [OGR::FieldDefinition] The definition for
      #   which to base the Field at +field_index+ off of.
      # @param flags [Integer] ALTER_NAME_FLAG, ALTER_TYPE_FLAG,
      #   ALTER_WIDTH_PRECISION_FLAG, or ALTER_ALL_FLAG.
      # @raise [OGR::Failure]
      # @raise [FFI::GDAL::InvalidPointer]
      def alter_field_definition(field_index, new_field_definition, flags)
        unless test_capability('AlterFieldDefn')
          raise OGR::UnsupportedOperation, 'This layer does not support field definition altering.'
        end

        new_field_definition_ptr = GDAL._pointer(new_field_definition)

        OGR::ErrorHandling.handle_ogr_err("Unable to alter field definition at field index #{field_index}") do
          FFI::OGR::API.OGR_L_AlterFieldDefn(
            @c_pointer,
            field_index,
            new_field_definition_ptr,
            flags
          )
        end
      end

      # Finds the index of a field in this Layer.
      #
      # @param field_name [String]
      # @param exact_match [Boolean] If +false+ and the field doesn't exist in the
      #   given form, the driver will try to make changes to make a match.
      # @return [Integer] Index of the field or +nil+ if the field doesn't exist.
      def find_field_index(field_name, exact_match: true)
        result = FFI::OGR::API.OGR_L_FindFieldIndex(@c_pointer, field_name, exact_match)

        result.negative? ? nil : result
      end

      # Creates and writes a new geometry to the layer. Note: not all drivers
      # support this.
      #
      # @param geometry_field_def [OGR::GeometryFieldDefinition] The definition
      #   to use for creating the new field.
      # @param approx_ok [Boolean]
      # @raise [OGR::Failure]
      # @raise [FFI::GDAL::InvalidPointer]
      def create_geometry_field(geometry_field_def, approx_ok: false)
        unless test_capability(CREATE_GEOM_FIELD)
          raise OGR::UnsupportedOperation, 'This layer does not support geometry field creation'
        end

        geometry_field_definition = OGR::GeometryFieldDefinition.new_borrowed(geometry_field_def.c_pointer)

        OGR::ErrorHandling.handle_ogr_err('Unable to create geometry field') do
          FFI::OGR::API.OGR_L_CreateGeomField(
            @c_pointer,
            geometry_field_definition.c_pointer,
            approx_ok
          )
        end
      end

      # If the driver supports this functionality, it will not fetch the
      # specified fields in subsequent calls to #feature / #next_feature and
      # thus save some processing time and/or bandwidth.
      #
      # @param field_names [Array<String>]
      # @raise [OGR::Failure]
      def set_ignored_fields(*field_names) # rubocop:disable Naming/AccessorMethodName
        return false if field_names.empty?

        fields_ptr = GDAL._string_array_to_pointer(field_names)

        OGR::ErrorHandling.handle_ogr_err("Unable to ignore fields with names: #{field_names}") do
          FFI::OGR::API.OGR_L_SetIgnoredFields(@c_pointer, fields_ptr)
        end
      end
    end
  end
end
