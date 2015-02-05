require_relative '../ffi/ogr'
require_relative 'feature_extensions'
require_relative 'feature_definition'
require_relative 'field'
require 'date'

module OGR
  class Feature
    include FeatureExtensions

    # @param feature_definition [OGR::FeatureDefinition,FFI::Pointer]
    # @return [OGR::Feature]
    def self.create(feature_definition)
      feature_def_ptr = GDAL._pointer(OGR::FeatureDefinition, feature_definition)

      if feature_def_ptr.nil?
        fail OGR::InvalidFeatureDefinition,
          "Unable to create Feature.  Feature definition is invalid: #{feature_definition}"
      end

      feature_ptr = FFI::GDAL::OGR_F_Create(feature_def_ptr)
      return nil if feature_ptr.null?

      new(feature_ptr)
    end

    # @param feature [OGR::Feature, FFI::Pointer]
    def initialize(feature)
      @feature_pointer = GDAL._pointer(OGR::Feature, feature)

      close_me = -> { FFI::GDAL.OGR_F_Destroy(@feature_pointer) }
      ObjectSpace.define_finalizer self, close_me

      @geometry = nil
      @definition = nil
    end

    def c_pointer
      @feature_pointer
    end

    # @return [OGR::Feature]
    # @raise [OGR::Failure] If, for some reason, the clone fails.
    def clone
      feature_ptr = FFI::GDAL.OGR_F_Clone(@feature_pointer)
      fail OGR::Failure, 'Unable to clone feature' if feature_ptr.nil?

      OGR::Feature.new(feature_ptr)
    end

    # Dumps the feature out to the file in human-readable form.
    #
    # @param file_name [String]
    def dump_readable(file_name)
      FFI::GDAL.OGR_F_DumpReadable(@feature_pointer, file_name)
    end

    # Overwrites the contents of this feature from the geometry and attributes
    # of the +other_feature+.
    #
    # @param other_feature [OGR::Feature]
    # @param be_forgiving [Boolean] +true+ if the operation should continue
    #   despite lacking output fields matching some of the source fields.
    # @param with_map [Array<Fixnum>]
    # TODO: Implement +with_map+
    def set_from!(other_feature, be_forgiving = false, with_map: nil)
      fail NotImplementedError, 'with_map: is not yet supported' if with_map

      ogr_err = FFI::GDAL.OGR_F_SetFrom(@feature_pointer, other_feature_ptr)

      ogr_err.handle_result
    end

    # This will always be the same as the field count for the feature
    # definition.
    #
    # @return [Fixnum]
    def field_count
      FFI::GDAL.OGR_F_GetFieldCount(@feature_pointer)
    end

    # @param index [Fixnum]
    # @param value [String]
    def set_field_string(index, value)
      FFI::GDAL.OGR_F_SetFieldString(@feature_pointer, index, value)
    end

    # @param index [Fixnum]
    # @param value [Fixnum]
    def set_field_integer(index, value)
      FFI::GDAL.OGR_F_SetFieldInteger(@feature_pointer, index, value)
    end

    # @param index [Fixnum]
    # @param value [Float]
    def set_field_double(index, value)
      FFI::GDAL.OGR_F_SetFieldDouble(@feature_pointer, index, value)
    end

    # @param index [Fixnum]
    # @param values [Array<String>]
    def set_field_string_list(index, values)
      values_ptr = GDAL._string_array_to_pointer(values)

      FFI::GDAL.OGR_F_SetFieldStringList(
        @feature_pointer,
        index,
        values_ptr)
    end

    # @param index [Fixnum]
    # @param values [Array<Fixnum>]
    def set_field_integer_list(index, values)
      values_ptr = FFI::MemoryPointer.new(:int, values.size)
      values_ptr.write_array_of_int(values)

      FFI::GDAL.OGR_F_SetFieldIntegerList(
        @feature_pointer,
        index,
        values.size,
        values_ptr)
    end

    # @param index [Fixnum]
    # @param values [Array<Float>]
    def set_field_double_list(index, values)
      values_ptr = FFI::MemoryPointer.new(:double, values.size)
      values_ptr.write_array_of_double(values)

      FFI::GDAL.OGR_F_SetFieldDoubleList(
        @feature_pointer,
        index,
        values.size,
        values_ptr)
    end

    # @param index [Fixnum]
    # @param value [FFI::GDAL::OGRField]
    def set_field_raw(index, value)
      raw_field_ptr = FFI::MemoryPointer.new(value)
      usable_raw_field = FFI::GDAL::OGRField.new(raw_field_ptr)

      unless valid_raw_field?(index, usable_raw_field)
        fail TypeError,
          "Raw field is not of required field type: #{field_definition(index).type}"
      end

      FFI::GDAL.OGR_F_SetFieldRaw(@feature_pointer, index, value)
    end

    # TODO: this seems really wonky...
    def valid_raw_field?(index, raw_field)
      field_def = field_definition(index)

      case field_def.type
      when :OFTInteger then !raw_field[:integer].nil?
      when :OFTIntegerList then !raw_field[:integer_list].nil?
      when :OFTReal then !raw_field[:real].nil?
      when :OFTString then !raw_field[:string].nil?
      when :OFTString then raw_field[:string]
      when :OFTStringList then !raw_field[:string_list].nil?
      when :OFTBinary then !raw_field[:binary].nil?
      when :OFTDate then !raw_field[:date].nil?
      else
        fail OGR::Failure, "Not sure how to set raw type: #{field_def.type}"
      end
    end

    # @param index [Fixnum]
    # @param value [String]
    def set_field_binary(index, value)
      fail TypeError, 'value must be a binary string' unless value.is_a? String

      value_ptr = FFI::MemoryPointer.new(:uchar, value.length)
      value_ptr.put_bytes(0, value)

      FFI::GDAL.OGR_F_SetFieldBinary(
        @feature_pointer,
        index,
        value.length,
        value_ptr)
    end

    # @param index [Fixnum]
    # @param [Date, Time, DateTime]
    def set_field_date_time(index, value)
      time = value.to_time
      zone = if time.zone =~ /GMT/
               100
             elsif time.zone
               1
             else
               0
      end

      FFI::GDAL.OGR_F_SetFieldDateTime(@feature_pointer, index,
        time.year,
        time.month,
        time.day,
        time.hour,
        time.min,
        time.sec,
        zone)
    end

    # @param index [Fixnum]
    # @return [OGR::Field]
    def field_definition(index)
      field_pointer = FFI::GDAL.OGR_F_GetFieldDefnRef(@feature_pointer, index)
      return nil if field_pointer.null?

      OGR::Field.new(field_pointer)
    end

    # @param name [String]
    # @return [Fixnum, nil]
    def field_index(name)
      result = FFI::GDAL.OGR_F_GetFieldIndex(@feature_pointer, name)

      result < 0 ? nil : result
    end

    # @param index [Fixnum]
    # @return [Boolean]
    def field_set?(index)
      FFI::GDAL.OGR_F_IsFieldSet(@feature_pointer, index)
    end

    # @param index [Fixnum]
    def unset_field(index)
      FFI::GDAL.OGR_F_UnsetField(@feature_pointer, index)
    end

    # @return [OGR::FeatureDefinition,nil]
    def definition
      return @definition if @definition

      feature_defn_ptr = FFI::GDAL.OGR_F_GetDefnRef(@feature_pointer)
      return nil if feature_defn_ptr.null?

      @definition = OGR::FeatureDefinition.new(feature_defn_ptr)
    end

    # @return [OGR::Geometry]
    def geometry
      return @geometry if @geometry

      geometry_ptr = FFI::GDAL.OGR_F_GetGeometryRef(@feature_pointer)
      return nil if geometry_ptr.null?

      @geometry = OGR::Geometry.factory(geometry_ptr)
    end

    # @param new_geometry [OGR::Geometry]
    # @return +true+ if successful, otherwise raises an OGR exception.
    def geometry=(new_geometry)
      ogr_err = FFI::GDAL.OGR_F_SetGeometryDirectly(@feature_pointer, new_geometry.c_pointer)
      @geometry = new_geometry

      ogr_err.handle_result
    end

    # @return [OGR::Geometry]
    def steal_geometry
      geometry_ptr = FFI::GDAL.OGR_F_StealGeometry(@feature_pointer)
      fail OGR::Failure, "Unable to steal geometry." if geometry_ptr.nil?

      OGR::Geometry.factory(geometry_ptr)
    end

    # @return [Fixnum]
    def fid
      FFI::GDAL.OGR_F_GetFID(@feature_pointer)
    end

    # @param new_fid [Fixnum]
    # @return +true+ if successful, otherwise raises an OGR exception.
    def fid=(new_fid)
      ogr_err = FFI::GDAL.OGR_F_SetFID(@feature_pointer, new_fid)

      ogr_err.handle_result
    end

    # The number of Geometries in this feature.
    #
    # @return [Fixnum]
    def geometry_field_count
      FFI::GDAL.OGR_F_GetGeomFieldCount(@feature_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::GeometryFieldDefinition] A read-only
    #   OGR::GeometryFieldDefinition.
    # @raise [OGR::InvalidGeometryFieldDefinition] If there isn't one at
    #   +index+.
    def geometry_field_definition(index)
      gfd_ptr = FFI::GDAL.OGR_F_GetGeomFieldDefnRef(@feature_pointer, index)
      return nil if gfd_ptr.nil?

      gfd = OGR::GeometryFieldDefinition.new(gfd_ptr)
      gfd.read_only = true

      gfd
    end

    # @param name [String]
    # @return index [Fixnum]
    def geometry_field_index(name)
      FFI::GDAL.OGR_F_GetGeomFieldIndex(@feature_pointer, name)
    end

    # @param index [Fixnum]
    # @return [OGR::Geometry, nil] A read-only OGR::Geometry.
    def geometry_field(index)
      geometry_ptr = FFI::GDAL.OGR_F_GetGeomFieldRef(@feature_pointer, index)
      return nil if geometry_ptr.nil? || geometry_ptr.null?

      geometry = OGR::Geometry.new(geometry_ptr)
      geometry.read_only = true

      geometry
    end

    # @param index [Fixnum]
    # @param [OGR::Geometry]
    def set_geometry_field(index, geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      fail OGR::InvalidGeometry if geometry_ptr.nil?

      ogr_err =
        FFI::GDAL.OGR_F_SetGeomFieldDirectly(@feature_pointer, index, geometry_ptr)

      ogr_err.handle_result
    end

    # @return [Boolean]
    def equal?(other_feature)
      FFI::GDAL.OGR_F_Equal(@feature_pointer, feature_pointer_from(other_feature))
    end
    alias_method :equals?, :equal?

    # @param index [Fixnum]
    # @return [Fixnum]
    def field_as_integer(index)
      FFI::GDAL.OGR_F_GetFieldAsInteger(@feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<Fixnum>]
    def field_as_integer_list(index)
      list_size_ptr = FFI::MemoryPointer.new(:int)
      list_ptr =
        FFI::GDAL.OGR_F_GetFieldAsIntegerList(@feature_pointer, index, list_size_ptr)
      return [] if list_ptr.null?

      list_ptr.read_array_of_int(list_size_ptr.read_int)
    end

    # @param index [Fixnum]
    # @return [Float]
    def field_as_double(index)
      FFI::GDAL.OGR_F_GetFieldAsDouble(@feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<Float>]
    def field_as_double_list(index)
      list_size_ptr = FFI::MemoryPointer.new(:int)
      list_ptr =
        FFI::GDAL.OGR_F_GetFieldAsDoubleList(@feature_pointer, index, list_size_ptr)
      return [] if list_ptr.null?

      list_ptr.read_array_of_double(list_size_ptr.read_int)
    end

    # @param index [Fixnum]
    # @return [String]
    def field_as_string(index)
      FFI::GDAL.OGR_F_GetFieldAsString(@feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<String>]
    def field_as_string_list(index)
      list_ptr =
        FFI::GDAL.OGR_F_GetFieldAsStringList(@feature_pointer, index)
      return [] if list_ptr.null?

      list_ptr.get_array_of_string(0)
    end

    # @param index [Fixnum]
    # @return [String]
    def field_as_binary(index)
      byte_count_ptr = FFI::MemoryPointer.new(:int)
      binary_data = FFI::GDAL.OGR_F_GetFieldAsBinary(
        @feature_pointer,
        index,
        byte_count_ptr
      )

      byte_count = byte_count_ptr.read_int
      string = byte_count > 0 ? binary_data.read_bytes(byte_count) : ''

      string.unpack('C*')
    end

    def field_as_date_time(index)
      year_ptr = FFI::MemoryPointer.new(:int)
      month_ptr = FFI::MemoryPointer.new(:int)
      day_ptr = FFI::MemoryPointer.new(:int)
      hour_ptr = FFI::MemoryPointer.new(:int)
      minute_ptr = FFI::MemoryPointer.new(:int)
      second_ptr = FFI::MemoryPointer.new(:int)
      time_zone_flag_ptr = FFI::MemoryPointer.new(:int)

      result = FFI::GDAL.OGR_F_GetFieldAsDateTime(
        @feature_pointer,
        index,
        year_ptr,
        month_ptr,
        day_ptr,
        hour_ptr,
        minute_ptr,
        second_ptr,
        time_zone_flag_ptr
      )
      return nil unless result

      formatted_tz = case time_zone_flag_ptr.read_int
                     when 0 then nil
                     when 1 then (Time.now.getlocal.utc_offset / 3600).to_s
                     when 100 then '+0'
                     end

      DateTime.new(
        year_ptr.read_int,
        month_ptr.read_int,
        day_ptr.read_int,
        hour_ptr.read_int,
        minute_ptr.read_int,
        second_ptr.read_int,
        formatted_tz
        )
    end

    # @return [String]
    def style_string
      FFI::GDAL.OGR_F_GetStyleString(@feature_pointer)
    end

    # @param new_style [String]
    def style_string=(new_style)
      FFI::GDAL.OGR_F_SetStyleString(@feature_pointer, new_style)
    end

    # @return [OGR::StyleTable]
    def style_table
      style_table_ptr = FFI::GDAL.OGR_F_GetStyleTable(@feature_pointer)
      return nil if style_table_ptr.nil? || style_table_ptr.null?

      OGR::StyleTable.new(style_table_ptr)
    end

    # @param new_style_table [OGR::StyleTable]
    def style_table=(new_style_table)
      new_style_table_ptr = GDAL._pointer(OGR::StyleTable, new_style_table)
      fail OGR::InvalidStyleTable unless new_style_table_ptr

      FFI::GDAL.OGR_F_SetStyleTableDirectly(@field_pointer, new_style_table_ptr)
    end

    private

    def feature_pointer_from(feature)
      if feature.is_a? OGR::Feature
        feature.c_pointer
      elsif feature.is_a? FFI::Pointer
        feature
      end
    end
  end
end
