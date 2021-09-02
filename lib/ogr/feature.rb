# frozen_string_literal: true

require_relative '../ogr'
require_relative '../gdal'

module OGR
  class Feature
    autoload :DateTimeConv, File.expand_path('feature/date_time_conv', __dir__ || '')

    # @param feature_definition [OGR::FeatureDefinition]
    # @return [OGR::FeatureDefinition]
    def self.create(feature_definition)
      pointer = FFI::OGR::API.OGR_F_Create(feature_definition.c_pointer)

      raise OGR::InvalidFeature, "Unable to create #{name} from #{feature_definition.name}" if pointer.null?

      new(pointer)
    end

    # @return [FFI::Pointer] C pointer of the C Feature.
    attr_reader :c_pointer

    # @param c_pointer [FFI::Pointer]
    def initialize(c_pointer)
      @c_pointer = c_pointer
    end

    # @param flags [Array<FFI::OGR::API::ValidationFlag>, FFI::OGR::API::ValidationFlag]
    #   Any of the :OGR_F_VAL_ symbols.
    # @param emit_error [Boolean] Tell the call if it should emit a CPLErr.
    def validate(flags, emit_error: true)
      FFI::OGR::API.OGR_F_Validate(@c_pointer, flags, emit_error)
    end

    def destroy!
      FFI::OGR::API.OGR_F_Destroy(@c_pointer)
    end

    # @return [OGR::Feature]
    # @raise [OGR::InvalidFeature] If, for some reason, the clone fails.
    def clone
      # This new feature is owned by the caller and must be released accordingly.
      feature_ptr = FFI::OGR::API.OGR_F_Clone(@c_pointer)
      raise OGR::InvalidFeature, 'Unable to clone feature' if feature_ptr.null?

      feature_ptr.autorelease = false

      OGR::Feature.new(feature_ptr)
    end

    # Dumps the feature out to the file in human-readable form.
    #
    # @param file_path [String]
    def dump_readable(file_path = nil)
      file_ptr = file_path ? FFI::CPL::Conv.CPLOpenShared(file_path, 'w', false) : nil
      FFI::OGR::API.OGR_F_DumpReadable(@c_pointer, file_ptr)
      FFI::CPL::Conv.CPLCloseShared(file_ptr) if file_ptr
    end

    # Overwrites the contents of this feature from the geometry and attributes
    # of the +source_feature+.
    #
    # @param source_feature [OGR::Feature]
    # @param be_forgiving [Boolean] +true+ if the operation should continue
    #   despite lacking output fields matching some of the source fields.
    # @raise [OGR::Failure]
    def set_from!(source_feature, be_forgiving: false)
      OGR::ErrorHandling.handle_ogr_err('Unable to set from other feature') do
        FFI::OGR::API.OGR_F_SetFrom(@c_pointer, source_feature.c_pointer, be_forgiving)
      end
    end

    # @param source_feature [OGR::Feature]
    # @param map [Array<Integer>] Array of the indices of self's feature's
    #   fields stored at the corresponding index of the source feature's fields. A
    #   value of -1 should be used to ignore the source's field. The array should
    #   not be NULL and be as long as the number of fields in the source feature.
    # @param be_forgiving [Boolean] +true+ if the operation should continue
    #   despite lacking output fields matching some of the source fields.
    # @raise [OGR::Failure]
    def set_from_with_map!(source_feature, map, be_forgiving: false)
      map_ptr = FFI::MemoryPointer.new(:pointer, map.length + 1)

      map.each do |index|
        map_ptr.write_int(index)
      end

      OGR::ErrorHandling.handle_ogr_err('Unable to set from other feature') do
        FFI::OGR::API.OGR_F_SetFromWithMap(@c_pointer, source_feature.c_pointer, be_forgiving, map_ptr)
      end
    end

    # This will always be the same as the field count for the feature
    # definition.
    #
    # @return [Integer]
    def field_count
      FFI::OGR::API.OGR_F_GetFieldCount(@c_pointer)
    end

    # @param field_index [Integer]
    # @param value [String]
    def set_field_string(field_index, value)
      FFI::OGR::API.OGR_F_SetFieldString(@c_pointer, field_index, value)
    end

    # @param field_index [Integer]
    # @param value [Integer]
    def set_field_integer(field_index, value)
      FFI::OGR::API.OGR_F_SetFieldInteger(@c_pointer, field_index, value)
    end

    # @param field_index [Integer]
    # @param value [Integer]
    def set_field_integer64(field_index, value)
      FFI::OGR::API.OGR_F_SetFieldInteger64(@c_pointer, field_index, value)
    end

    # @param field_index [Integer]
    # @param value [Float]
    def set_field_double(field_index, value)
      FFI::OGR::API.OGR_F_SetFieldDouble(@c_pointer, field_index, value)
    end

    # @param field_index [Integer]
    # @param values [Array<String>]
    # @raise [GDAL::Error] If field_index isn't valid
    def set_field_string_list(field_index, values)
      values_ptr = GDAL._string_array_to_pointer(values)

      FFI::OGR::API.OGR_F_SetFieldStringList(
        @c_pointer,
        field_index,
        values_ptr
      )
    end

    # @param field_index [Integer]
    # @param values [Array<Integer>]
    def set_field_integer_list(field_index, values)
      values_ptr = FFI::MemoryPointer.new(:int, values.size)
      values_ptr.write_array_of_int(values)

      FFI::OGR::API.OGR_F_SetFieldIntegerList(
        @c_pointer,
        field_index,
        values.size,
        values_ptr
      )
    end

    # @param field_index [Integer]
    # @param values [Array<Integer>]
    def set_field_integer64_list(field_index, values)
      values_ptr = FFI::MemoryPointer.new(:int64, values.size)
      values_ptr.write_array_of_int64(values)

      FFI::OGR::API.OGR_F_SetFieldInteger64List(
        @c_pointer,
        field_index,
        values.size,
        values_ptr
      )
    end

    # @param field_index [Integer]
    # @param values [Array<Float>]
    def set_field_double_list(field_index, values)
      values_ptr = FFI::MemoryPointer.new(:double, values.size)
      values_ptr.write_array_of_double(values)

      FFI::OGR::API.OGR_F_SetFieldDoubleList(
        @c_pointer,
        field_index,
        values.size,
        values_ptr
      )
    end

    # @param field_index [Integer]
    # @param field [OGR::Field]
    def set_field_raw(field_index, field)
      usable_raw_field = field.c_struct

      FFI::OGR::API.OGR_F_SetFieldRaw(@c_pointer, field_index, usable_raw_field)
    end

    # @param field_index [Integer]
    # @param value [String]
    def set_field_binary(field_index, value)
      raise TypeError, 'value must be a binary string' unless value.is_a? String

      value_ptr = FFI::MemoryPointer.new(:uchar, value.length)
      value_ptr.put_bytes(0, value)

      FFI::OGR::API.OGR_F_SetFieldBinary(
        @c_pointer,
        field_index,
        value.length,
        value_ptr
      )
    end

    # @param field_index [Integer]
    # @param value [Date, Time, DateTime]
    def set_field_date_time(field_index, value)
      time = value.to_time
      zone = OGR._format_time_zone_for_ogr(value.zone)

      FFI::OGR::API.OGR_F_SetFieldDateTime(@c_pointer, field_index,
                                           time.year,
                                           time.month,
                                           time.day,
                                           time.hour,
                                           time.min,
                                           time.sec,
                                           zone)
    end

    # @param field_index [Integer]
    # @param value [Date, Time, DateTime]
    def set_field_date_time_ex(field_index, value)
      time = value.to_time
      zone = OGR._format_time_zone_for_ogr(value.zone)

      FFI::OGR::API.OGR_F_SetFieldDateTimeEx(@c_pointer, field_index,
                                             time.year,
                                             time.month,
                                             time.day,
                                             time.hour,
                                             time.min,
                                             time.sec.to_f + time.subsec,
                                             zone)
    end

    # NOTE: The FieldDefinition that's returned here is frozen and cannot be
    # modified.
    #
    # @param field_index [Integer]
    # @return [OGR::FieldDefinition]
    def field_definition(field_index)
      # This returns an internal reference and should not be deleted or modified
      OGR::FieldDefinition.new_borrowed(FFI::OGR::API.OGR_F_GetFieldDefnRef(@c_pointer, field_index))
    end

    # @param field_name [String]
    # @return [Integer, nil]
    def field_index(field_name)
      result = FFI::OGR::API.OGR_F_GetFieldIndex(@c_pointer, field_name)

      result.negative? ? nil : result
    end

    # @param field_index [Integer]
    # @return [Boolean]
    def field_set?(field_index)
      FFI::OGR::API.OGR_F_IsFieldSet(@c_pointer, field_index)
    end

    # @param field_index [Integer]
    def unset_field(field_index)
      FFI::OGR::API.OGR_F_UnsetField(@c_pointer, field_index)
    end

    # @return [OGR::FeatureDefinition]
    # @raise [OGR::InvalidPointer]
    def definition
      feature_defn_ptr = FFI::OGR::API.OGR_F_GetDefnRef(@c_pointer)

      OGR::FeatureDefinition.new_borrowed(feature_defn_ptr)
    end

    # NOTE: Do not modify the Geometry that's returned here.
    #
    # @return [OGR::Geometry]
    def geometry
      # This returns an internal reference and should not be deleted or modified
      OGR::Geometry.new_borrowed(FFI::OGR::API.OGR_F_GetGeometryRef(@c_pointer))
    end

    # Sets the geometry of the feature by making a copy of +new_geometry+.
    #
    # @param new_geometry [OGR::Geometry]
    # @raise [OGR::Failure]
    def set_geometry(new_geometry) # rubocop:disable Naming/AccessorMethodName
      OGR::ErrorHandling.handle_ogr_err('Unable to set geometry on feature') do
        FFI::OGR::API.OGR_F_SetGeometry(@c_pointer, new_geometry.c_pointer)
      end
    end
    alias geometry= set_geometry

    # Takes away ownership of the Feature's Geometry and returns it to the caller.
    #
    # @return [OGR::Geometry]
    def steal_geometry
      OGR::Geometry.new_owned(FFI::OGR::API.OGR_F_StealGeometry(@c_pointer))
    end

    # @return [Integer]
    def fid
      FFI::OGR::API.OGR_F_GetFID(@c_pointer)
    end

    # @param new_fid [Integer]
    # @raise [OGR::Failure]
    def fid=(new_fid)
      OGR::ErrorHandling.handle_ogr_err('Unable to set FID') do
        FFI::OGR::API.OGR_F_SetFID(@c_pointer, new_fid)
      end
    end

    # The number of Geometries in this feature.
    #
    # @return [Integer]
    def geometry_field_count
      FFI::OGR::API.OGR_F_GetGeomFieldCount(@c_pointer)
    end

    # NOTE: The GeometryFieldDefinition that's returned here is frozen and cannot
    # be modified.
    #
    # @param geometry_field_index [Integer]
    # @return [OGR::GeometryFieldDefinition] A read-only
    #   OGR::GeometryFieldDefinition.
    # @raise [OGR::InvalidGeometryFieldDefinition] If there isn't one at
    #   +geometry_field_index+.
    def geometry_field_definition(geometry_field_index)
      # This returns an internal reference and should not be deleted or modified
      OGR::GeometryFieldDefinition.new_borrowed(FFI::OGR::API.OGR_F_GetGeomFieldDefnRef(@c_pointer,
                                                                                        geometry_field_index))
    end

    # @param geometry_field_name [String]
    # @return [Integer]
    def geometry_field_index(geometry_field_name)
      FFI::OGR::API.OGR_F_GetGeomFieldIndex(@c_pointer, geometry_field_name)
    end

    # NOTE: Do not modify the Geometry that's returned here.
    #
    # @param geometry_field_index [Integer]
    # @return [OGR::Geometry, nil] A read-only OGR::Geometry.
    def geometry_field(geometry_field_index)
      # This returns an internal reference and should not be deleted or modified
      OGR::Geometry.new_borrowed(FFI::OGR::API.OGR_F_GetGeomFieldRef(@c_pointer, geometry_field_index))
    end

    # Sets the feature geometry of a specified geometry field by making a copy
    # of +geometry+.
    #
    # @param geometry_field_index [Integer]
    # @param geometry [OGR::Geometry]
    # @raise [FFI::GDAL::InvalidPointer]
    # @raise [OGR::Failure]
    def set_geometry_field(geometry_field_index, geometry)
      geometry_ptr = geometry.c_pointer

      OGR::ErrorHandling.handle_ogr_err("Unable to set geometry field at index #{geometry_field_index}") do
        FFI::OGR::API.OGR_F_SetGeomField(@c_pointer, geometry_field_index, geometry_ptr)
      end
    end

    # @param other [OGR::Feature]
    # @return [Boolean]
    def equal?(other)
      FFI::OGR::API.OGR_F_Equal(@c_pointer, other.c_pointer)
    end
    alias equals? equal?

    # @param field_index [Integer]
    # @return [Integer]
    def field_as_integer(field_index)
      FFI::OGR::API.OGR_F_GetFieldAsInteger(@c_pointer, field_index)
    end

    # @param field_index [Integer]
    # @return [Integer]
    def field_as_integer64(field_index)
      FFI::OGR::API.OGR_F_GetFieldAsInteger64(@c_pointer, field_index)
    end

    # @param field_index [Integer]
    # @return [Array<Integer>]
    def field_as_integer_list(field_index)
      list_size_ptr = FFI::MemoryPointer.new(:int)
      #  This list is internal, and should not be modified, or freed. Its lifetime may be very brief.
      list_ptr = FFI::OGR::API.OGR_F_GetFieldAsIntegerList(@c_pointer, field_index, list_size_ptr)
      list_ptr.autorelease = false

      return [] if list_ptr.null?

      list_ptr.read_array_of_int(list_size_ptr.read_int)
    end

    # @param field_index [Integer]
    # @return [Array<Integer>]
    def field_as_integer64_list(field_index)
      list_size_ptr = FFI::MemoryPointer.new(:int)
      #  This list is internal, and should not be modified, or freed. Its lifetime may be very brief.
      list_ptr = FFI::OGR::API.OGR_F_GetFieldAsInteger64List(@c_pointer, field_index, list_size_ptr)
      list_ptr.autorelease = false

      return [] if list_ptr.null?

      list_ptr.read_array_of_int64(list_size_ptr.read_int)
    end

    # @param field_index [Integer]
    # @return [Float]
    def field_as_double(field_index)
      FFI::OGR::API.OGR_F_GetFieldAsDouble(@c_pointer, field_index)
    end

    # @param field_index [Integer]
    # @return [Array<Float>]
    def field_as_double_list(field_index)
      list_size_ptr = FFI::MemoryPointer.new(:int)
      # This list is internal, and should not be modified, or freed. Its lifetime may be very brief.
      list_ptr = FFI::OGR::API.OGR_F_GetFieldAsDoubleList(@c_pointer, field_index, list_size_ptr)
      list_ptr.autorelease = false

      return [] if list_ptr.null?

      list_ptr.read_array_of_double(list_size_ptr.read_int)
    end

    # @param field_index [Integer]
    # @return [String]
    def field_as_string(field_index)
      field_string = FFI::OGR::API.OGR_F_GetFieldAsString(@c_pointer, field_index)

      field_string.force_encoding(Encoding::UTF_8).freeze
    end

    # @param field_index [Integer]
    # @return [Array<String>]
    def field_as_string_list(field_index)
      # This list is internal, and should not be modified, or freed. Its lifetime may be very brief.
      list_ptr = FFI::OGR::API.OGR_F_GetFieldAsStringList(@c_pointer, field_index)
      list_ptr.autorelease = false

      return [] if list_ptr.null?

      list_ptr.get_array_of_string(0)
    end

    # @param field_index [Integer]
    # @return [String]
    def field_as_binary(field_index)
      byte_count_ptr = FFI::MemoryPointer.new(:int)

      # This list is internal, and should not be modified, or freed. Its lifetime may be very brief.
      binary_data_ptr = FFI::OGR::API.OGR_F_GetFieldAsBinary(@c_pointer, field_index, byte_count_ptr)
      binary_data_ptr.autorelease = false

      byte_count = byte_count_ptr.read_int
      string = byte_count.positive? ? binary_data_ptr.read_bytes(byte_count) : ''

      string.unpack('C*')
    end

    # @param field_index [Integer]
    # @return [DateTime]
    # @raise [OGR::Error] if unable to convert the field to a DateTime.
    def field_as_date_time(field_index)
      common_dt_pointers = DateTimeConv::Pointers.new
      second_ptr = FFI::MemoryPointer.new(:int)

      success = FFI::OGR::API.OGR_F_GetFieldAsDateTime(
        @c_pointer,
        field_index,
        common_dt_pointers.year,
        common_dt_pointers.month,
        common_dt_pointers.day,
        common_dt_pointers.hour,
        common_dt_pointers.minute,
        second_ptr,
        common_dt_pointers.time_zone
      )
      raise OGR::Error, 'Unable to coerce Field to DateTime' unless success

      DateTimeConv::Values
        .new
        .from_pointers(common_dt_pointers)
        .to_date_time(second_ptr.read_int)
    end

    # Similar to #field_as_date_time, but with millisecond accuracy.
    #
    # @param field_index [Integer]
    # @return [DateTime]
    def field_as_date_time_ex(field_index)
      common_dt_pointers = DateTimeConv::Pointers.new
      second_ptr = FFI::MemoryPointer.new(:float)

      success = FFI::OGR::API.OGR_F_GetFieldAsDateTime(
        @c_pointer,
        field_index,
        common_dt_pointers.year,
        common_dt_pointers.month,
        common_dt_pointers.day,
        common_dt_pointers.hour,
        common_dt_pointers.minute,
        second_ptr,
        common_dt_pointers.time_zone
      )
      raise OGR::Error, 'Unable to coerce Field to DateTime' unless success

      DateTimeConv::Values
        .new
        .from_pointers(common_dt_pointers)
        .to_date_time(second_ptr.read_float)
    end

    # @return [String]
    def style_string
      FFI::OGR::API.OGR_F_GetStyleString(@c_pointer).freeze
    end

    # @param new_style [String]
    def style_string=(new_style)
      FFI::OGR::API.OGR_F_SetStyleString(@c_pointer, new_style)
    end

    # @return [OGR::StyleTable]
    def style_table
      OGR::StyleTable.new_borrowed(FFI::OGR::API.OGR_F_GetStyleTable(@c_pointer))
    end

    # @param new_style_table [OGR::StyleTable]
    # @raise [FFI::GDAL::InvalidPointer]
    def style_table=(new_style_table)
      new_style_table_ptr = new_style_table.c_pointer
      new_style_table_ptr.autorelease = false

      FFI::OGR::API.OGR_F_SetStyleTable(@c_pointer, new_style_table_ptr)
    end

    # @param field_index [Integer]
    # rubocop: disable Naming/AccessorMethodName
    def set_field_null(field_index)
      FFI::OGR::API.OGR_F_SetFieldNull(@c_pointer, field_index)
    end
    # rubocop: enable Naming/AccessorMethodName

    # @param field_index [Integer]
    # @return [Boolean]
    def field_null?(field_index)
      FFI::OGR::API.OGR_F_IsFieldNull(@c_pointer, field_index)
    end

    # @param field_index [Integer]
    # @return [Boolean]
    def field_set_and_not_null?(field_index)
      FFI::OGR::API.OGR_F_IsFieldSetAndNotNull(@c_pointer, field_index)
    end

    # @return [String]
    def native_data
      FFI::OGR::API.OGR_F_GetNativeData(@c_pointer)
    end

    # @param data [String]
    def native_data=(data)
      FFI::OGR::API.OGR_F_SetNativeData(@c_pointer, data)
    end

    # @return [String]
    def native_media_type
      FFI::OGR::API.OGR_F_GetNativeMediaType(@c_pointer)
    end

    # The native media type is the identifier for the format of the native data.
    # It follows the IANA RFC 2045 (see https://en.wikipedia.org/wiki/Media_type),
    # e.g. 'application/vnd.geo+json' for JSON.
    #
    # @param mime_type [String]
    def native_media_type=(mime_type)
      FFI::OGR::API.OGR_F_SetNativeMediaType(@c_pointer, mime_type)
    end

    # Fill unset fields with default values that might be defined.
    #
    # @param non_nullable_only [Boolean] if we should fill only unset fields with a not-null constraint.
    def fill_unset_with_default(non_nullable_only: false)
      FFI::OGR::API.OGR_F_FillUnsetWithDefault(@c_pointer, non_nullable_only, FFI::Pointer::NULL)
    end

    private

    # Lets you pass in :OGR_F_VAL_ symbols that represent mask band flags and bitwise
    # ors them.
    #
    # @param flags [Array<FFI::OGR::API::ValidationFlag>]
    # @return [Integer]
    def parse_validation_flag_symbols(*flags)
      flags.reduce(0) do |result, flag|
        if FFI::OGR::API::ValidationFlag.symbols.include?(flag)
          result | FFI::OGR::API::ValidationFlag[flag]
        else
          result
        end
      end
    end
  end
end
