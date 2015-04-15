module OGR
  module SpatialReferenceMixins
    module ParameterGetterSetters
      # @param name [String] The case-insensitive tree node to look for.
      # @param child [Fixnum] The child of the node to fetch.
      # @return [String, nil]
      def attribute_value(name, child = 0)
        FFI::OGR::SRSAPI.OSRGetAttrValue(@c_pointer, name, child)
      end

      # @param path [String] Path to the node to update/set.  If nested, use the
      #   pipe symbol to denote nesting.  i.e. 'GEOCCS|UNIT'.
      # @param value [String] The new value for the node/path.  Should be a String,
      #   but if not, will be converted for you.
      def set_attribute_value(path, value)
        ogr_err = FFI::OGR::SRSAPI.OSRSetAttrValue(@c_pointer, path, value.to_s)

        ogr_err.handle_result
      end

      # @return [Hash{unit_name: String, value: Float}]  +unit_name+ is the name
      #   of the unit type ("degree" or "radian").  +value+ is the number to
      #   multiply angular distances to transform them to radians.
      def angular_units
        name = FFI::MemoryPointer.new(:string)
        name_ptr = FFI::MemoryPointer.new(:pointer)
        name_ptr.write_pointer(name)

        value = FFI::OGR::SRSAPI.OSRGetAngularUnits(@c_pointer, name_ptr)

        { unit_name: name_ptr.read_pointer.read_string, value: value }
      end

      # @param unit_label [String]
      # @param transfor_to_meters [Float] The value to multiply an angle to
      #   transform the value to radians.
      def set_angular_units(unit_label, transform_to_radians)
        ogr_err = FFI::OGR::SRSAPI.OSRSetAngularUnits(@c_pointer, unit_label, transform_to_radians.to_f)

        ogr_err.handle_result
      end

      # @return [Hash{unit_name: String, value: Float}]  +unit_name+ is the name
      #   of the unit type (e.g. "Meters"). +value+ is the number to multiply
      #   linear distances to transform them to meters.
      def linear_units
        name = FFI::MemoryPointer.new(:string)
        name_ptr = FFI::MemoryPointer.new(:pointer)
        name_ptr.write_pointer(name)

        value = FFI::OGR::SRSAPI.OSRGetLinearUnits(@c_pointer, name_ptr)

        { unit_name: name_ptr.read_pointer.read_string, value: value }
      end

      # @param unit_label [String]
      # @param transfor_to_meters [Float] The value to multiply a length to
      #   transform the value to meters.
      def set_linear_units(unit_label, transform_to_meters)
        ogr_err = FFI::OGR::SRSAPI.OSRSetLinearUnits(@c_pointer, unit_label, transform_to_meters.to_f)

        ogr_err.handle_result
      end

      # Does the same as #set_linear_units, but also converts parameters to use
      # the new units.
      #
      # @param unit_label [String]
      # @param transfor_to_meters [Float] The value to multiply a length to
      #   transform the value to meters.
      def set_linear_units_and_update_parameters(unit_label, transform_to_meters)
        ogr_err = FFI::OGR::SRSAPI.OSRSetLinearUnitsAndUpdateParameters(
          @c_pointer,
          unit_label,
          transform_to_meters.to_f)

        ogr_err.handle_result
      end

      # The linear units for the projection.
      #
      # @param target_key [String] I.e. "PROJCS" or "VERT_CS".
      # @return [Hash]
      def target_linear_units(target_key)
        name = FFI::MemoryPointer.new(:string)
        name_ptr = FFI::MemoryPointer.new(:pointer)
        name_ptr.write_pointer(name)

        value = FFI::OGR::SRSAPI.OSRGetTargetLinearUnits(@c_pointer, target_key, name_ptr)

        { unit_name: name_ptr.read_pointer.read_string, value: value }
      end

      # @param target_key [String] The keyword to set linear units for ("PROJCS",
      #   "VERT_CS", etc.).
      # @param unit_label [String] Name of the units to be used.
      # @param transform_to_meters [Float] The value to multiple a length to
      #   transform the value to meters.
      def set_target_linear_units(target_key, unit_label, transform_to_meters)
        ogr_err = FFI::OGR::SRSAPI.OSRSetTargetLinearUnits(
          @c_pointer,
          target_key,
          unit_label,
          transform_to_meters
        )

        ogr_err.handle_result
      end

      # @return [Hash]
      def prime_meridian
        pm = FFI::MemoryPointer.new(:string)
        pm_ptr = FFI::MemoryPointer.new(:pointer)
        pm_ptr.write_pointer(pm)

        value = FFI::OGR::SRSAPI.OSRGetPrimeMeridian(@c_pointer, pm_ptr)

        { name: pm_ptr.read_pointer.read_string, value: value }
      end
    end
  end
end
