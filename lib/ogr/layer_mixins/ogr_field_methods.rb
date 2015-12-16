module OGR
  module LayerMixins
    module OGRFieldMethods
      # Creates and writes a new field to the layer. This adds the field to the
      # internal FeatureDefinition; C API says not to update the FeatureDefinition
      # directly.
      #
      # @param field_definition [OGR::FieldDefinition]
      # @param approx_ok [Boolean] If +true+ the field may be created in a slightly
      #   different form, depending on the limitations of the format driver.
      # @return [Boolean]
      def create_field(field_definition, approx_ok = false)
        unless can_create_field?
          fail OGR::UnsupportedOperation, 'This layer does not support field creation.'
        end

        field_definition_ptr = GDAL._pointer(OGR::FieldDefinition, field_definition)
        ogr_err = FFI::OGR::API.OGR_L_CreateField(@c_pointer, field_definition_ptr, approx_ok)

        ogr_err.handle_result
      end

      # Deletes the field definition from the layer.
      #
      # @return +true+ if successful, otherwise raises an OGR exception.
      def delete_field(field_id)
        unless can_delete_field?
          fail OGR::UnsupportedOperation, 'This driver does not support field deletion.'
        end

        ogr_err = FFI::OGR::API.OGR_L_DeleteField(@c_pointer, field_id)

        ogr_err.handle_result
      end

      # @param new_order [Array<Fixnum>] An array that orders field indexes by
      #   which they should be reordered.  I.e. [0, 2, 3, 1, 4].
      # @return [Boolean]
      def reorder_fields(*new_order)
        unless can_reorder_fields?
          fail OGR::UnsupportedOperation, 'This driver does not support field reordering.'
        end

        return false if new_order.empty?
        return false if new_order.any? { |i| i > feature_definition.field_count }

        map_array_ptr = FFI::MemoryPointer.new(:int, new_order.size).write_array_of_int(new_order)
        ogr_err = FFI::OGR::API.OGR_L_ReorderFields(@c_pointer, map_array_ptr)

        ogr_err.handle_result
      end

      # Puts the field whose index is +old_position+ into index at +new_position+
      # and shuffles the other indexes accordingly.
      #
      # @param old_position [Fixnum]
      # @param new_position [Fixnum]
      def reorder_field(old_position, new_position)
        unless can_reorder_fields?
          fail OGR::UnsupportedOperation, 'This driver does not support field reordering.'
        end

        ogr_err = FFI::OGR::API.OGR_L_ReorderField(@c_pointer, old_position, new_position)

        ogr_err.handle_result
      end

      # @param field_index [Fixnum]
      # @param new_field_definition [OGR::FieldDefinition] The definition for
      #   which to base the Field at +field_index+ off of.
      # @param flags [Fixnum] ALTER_NAME_FLAG, ALTER_TYPE_FLAG,
      #   ALTER_WIDTH_PRECISION_FLAG, or ALTER_ALL_FLAG.
      def alter_field_definition(field_index, new_field_definition, flags)
        unless can_alter_field_definition?
          fail OGR::UnsupportedOperation, 'This layer does not support field definition altering.'
        end

        new_field_definition_ptr = GDAL._pointer(OGR::FieldDefinition, new_field_definition)

        ogr_err = FFI::OGR::API.OGR_L_AlterFieldDefn(
          @c_pointer,
          field_index,
          new_field_definition_ptr,
          flags)

        ogr_err.handle_result
      end

      # Finds the index of a field in this Layer.
      #
      # @param field_name [String]
      # @param exact_match [Boolean] If +false+ and the field doesn't exist in the
      #   given form, the driver will try to make changes to make a match.
      # @return [Fixnum] Index of the field or +nil+ if the field doesn't exist.
      def find_field_index(field_name, exact_match = true)
        result = FFI::OGR::API.OGR_L_FindFieldIndex(@c_pointer, field_name, exact_match)

        result < 0 ? nil : result
      end

      # Creates and writes a new geometry to the layer. Note: not all drivers
      # support this.
      #
      # @param geometry_field_def [OGR::GeometryFieldDefinition] The definition
      #   to use for creating the new field.
      # @param approx_ok [Boolean]
      # @return [Boolean]
      def create_geometry_field(geometry_field_def, approx_ok = false)
        unless can_create_geometry_field?
          fail OGR::UnsupportedOperation, 'This layer does not support geometry field creation'
        end

        geometry_field_definition_ptr = GDAL._pointer(OGR::GeometryFieldDefinition, geometry_field_def)

        ogr_err = FFI::OGR::API.OGR_L_CreateGeomField(
          @c_pointer,
          geometry_field_definition_ptr,
          approx_ok)

        ogr_err.handle_result
      end

      # If the driver supports this functionality, it will not fetch the
      # specified fields in subsequent calls to #feature / #next_feature and
      # thus save some processing time and/or bandwidth.
      #
      # @param field_names [Array<String>]
      # @return [Boolean]
      def set_ignored_fields(*field_names)
        return false if field_names.empty?

        fields_ptr = GDAL._string_array_to_pointer(field_names)
        ogr_err = FFI::OGR::API.OGR_L_SetIgnoredFields(@c_pointer, fields_ptr)

        ogr_err.handle_result "Unable to ignore fields with names: #{field_names}"
      end
    end
  end
end
