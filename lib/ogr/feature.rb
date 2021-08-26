# frozen_string_literal: true

require 'date'
require_relative '../ogr'
require_relative '../gdal'

module OGR
  class Feature
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
    # of the +other_feature+.
    #
    # @param other_feature [OGR::Feature]
    # @param be_forgiving [Boolean] +true+ if the operation should continue
    #   despite lacking output fields matching some of the source fields.
    # @raise [OGR::Failure]
    def set_from!(other_feature, be_forgiving: false)
      OGR::ErrorHandling.handle_ogr_err('Unable to set from other feature') do
        FFI::OGR::API.OGR_F_SetFrom(@c_pointer, other_feature.c_pointer, be_forgiving)
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
      field, ptr = FFI::OGR::API.OGR_F_GetFieldAsString(@c_pointer, field_index)
      ptr.autorelease = false

      field.force_encoding(Encoding::UTF_8)
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

    def field_as_date_time(field_index)
      year_ptr = FFI::MemoryPointer.new(:int)
      month_ptr = FFI::MemoryPointer.new(:int)
      day_ptr = FFI::MemoryPointer.new(:int)
      hour_ptr = FFI::MemoryPointer.new(:int)
      minute_ptr = FFI::MemoryPointer.new(:int)
      second_ptr = FFI::MemoryPointer.new(:int)
      time_zone_flag_ptr = FFI::MemoryPointer.new(:int)

      success = FFI::OGR::API.OGR_F_GetFieldAsDateTime(
        @c_pointer,
        field_index,
        year_ptr,
        month_ptr,
        day_ptr,
        hour_ptr,
        minute_ptr,
        second_ptr,
        time_zone_flag_ptr
      )
      return nil unless success

      formatted_tz = OGR._format_time_zone_for_ruby(time_zone_flag_ptr.read_int)

      if formatted_tz
        DateTime.new(
          year_ptr.read_int,
          month_ptr.read_int,
          day_ptr.read_int,
          hour_ptr.read_int,
          minute_ptr.read_int,
          second_ptr.read_int,
          formatted_tz
        )
      else
        DateTime.new(
          year_ptr.read_int,
          month_ptr.read_int,
          day_ptr.read_int,
          hour_ptr.read_int,
          minute_ptr.read_int,
          second_ptr.read_int
        )
      end
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
  end
end
