module OGR
  module LayerMixins
    module OGRFieldMethods
      # Creates and writes a new field to the layer. This adds the field to the
      # internal FieldDefinition; C API says not to update the FieldDefinition
      # directly.
      #
      # @param name [String]
      # @param type [FFI::GDAL::OGRFieldType]
      # @param approx_ok [Boolean] If +true+ the field may be created in a slightly
      #   different form, depending on the limitations of the format driver.
      # @return [OGR::Field]
      def create_field(name, type, approx_ok = false)
        field = OGR::Field.new(name, type)
        ogr_err = FFI::GDAL.OGR_L_CreateField(@layer_pointer, field.c_pointer, approx_ok)
        ogr_err.handle_result

        field
      end

      # Deletes the field definition from the layer.
      #
      # TODO: Use OGR_L_TestCapability before trying to delete.
      # @return +true+ if successful, otherwise raises an OGR exception.
      def delete_field(field_id)
        ogr_err = FFI::GDAL.OGR_L_DeleteField(@layer_pointer, field_id)

        ogr_err.handle_result
      end

      # @param new_order [Array<Fixnum>] An array that orders field indexes by
      #   which they should be reordered.  I.e. [0, 2, 3, 1, 4].
      # @return [Boolean]
      def reorder_fields(*new_order)
        map_array_ptr = FFI::MemoryPointer.new(:int, new_order.size).write_array_of_int(new_order)
        ogr_err = FFI::GDAL.OGR_L_ReorderFields(@layer_pointer, map_array_ptr)

        ogr_err.handle_result
      end

      # Puts the field whose index is +old_position+ into index at +new_position+
      # and shuffles the other indexes accordingly.
      #
      # @param old_position [Fixnum]
      # @param new_position [Fixnum]
      def reorder_field(old_position, new_position)
        ogr_err = FFI::GDAL.OGR_L_ReorderField(@layer_pointer, old_position, new_position)

        ogr_err.handle_result
      end

      # @param field_index [Fixnum]
      # @param new_field_definition [OGR::FieldDefinition] The definition for
      #   which to base the Field at +field_index+ off of.
      # @param flags [Fixnum] ALTER_NAME_FLAG, ALTER_TYPE_FLAG,
      #   ALTER_WIDTH_PRECISION_FLAG, or ALTER_ALL_FLAG.
      # TODO: Check if the layer supports this with the OLCAlterFieldDefn capability.
      def alter_field_definition(field_index, new_field_definition, flags)
        new_field_definition_ptr = GDAL._pointer(OGR::FieldDefinition, new_field_definition)

        ogr_err = FFI::GDAL.OGR_L_AlterFieldDefn(
          @layer_pointer,
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
        result = FFI::GDAL.OGR_L_FindFieldIndex(@layer_pointer, field_name, exact_match)

        result < 0 ? nil : result
      end

      # Creates and writes a new geometry to the layer. Note: not all drivers
      # support this.
      #
      # @param geometry_field_def [OGR::GeometryFieldDefinition] The definition
      #   to use for creating the new field.
      # @param approx_ok [Boolean]
      # @return [OGR::GeometryField]
      # TODO: Check if the Layer supports this with the OLCCreateField capability
      def create_geometry_field(geometry_field_def, approx_ok = false)
        geometry_field_definition_ptr = GDAL._pointer(OGR::GeometryFieldDefinition, geometry_field_def)

        ogr_err = FFI::GDAL.OGR_L_CreateGeomField(
          @layer_pointer,
          geometry_field_definition_ptr,
          approx_ok)

        ogr_err.handle_result
      end

      # @param field_names [Array<String>]
      def set_ignored_fields(*field_names)
        fields_ptr = GDAL._string_array_to_pointer(field_names)
        ogr_err = FFI::GDAL.OGR_L_SetIgnoredFields(@layer_pointer, fields_ptr)

        ogr_err.handle_result
      end
    end
  end
end
