require_relative '../ffi/ogr'
require_relative 'feature_extensions'
require_relative 'feature_definition'
require_relative 'field'

module OGR
  class Feature
    include FeatureExtensions

    # @param feature_definition [OGR::FeatureDefinition,FFI::Pointer]
    # @return [OGR::Feature]
    def self.create(feature_definition)
      feature_def_ptr = GDAL._pointer(OGR::FeatureDefinition, feature_definition)
      feature_ptr = FFI::GDAL::OGR_F_Create(feature_def_ptr)
      return nil if feature_ptr.null?

      new(feature_ptr)
    end

    # @param feature [OGR::Feature, FFI::Pointer]
    def initialize(feature)
      @feature_pointer = GDAL._pointer(OGR::Feature, feature)

      close_me = -> { FFI::GDAL.OGR_F_Destroy(@feature_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @feature_pointer
    end

    # @return [Fixnum]
    def field_count
      FFI::GDAL.OGR_F_GetFieldCount(@feature_pointer)
    end

    def add_field(index, value)
      case value.class.name
      when 'String'
        FFI::GDAL.OGR_F_SetFieldString(@feature_pointer, index, value)
      when 'Fixnum'
        FFI::GDAL.OGR_F_SetFieldInteger(@feature_pointer, index, value)
      when 'Float'
        FFI::GDAL.OGR_F_SetFieldDouble(@feature_pointer, index, value)
      when ('Date' or 'Time' or 'DateTime')
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
    end

    # @param index [Fixnum]
    # @return [OGR::Field]
    def field(index)
      field_pointer = FFI::GDAL.OGR_F_GetFieldDefnRef(@feature_pointer, index)
      return nil if field_pointer.null?

      OGR::Field.new(field_pointer)
    end

    # @param name [String]
    # @return [Fixnum]
    def field_index(name)
      FFI::GDAL.OGR_F_GetFieldIndex(@feature_pointer, name)
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

      feature_defn_ptr = FFI::GDAL.OGR_F_GetDefRef(@feature_pointer)
      return nil if feature_defn_ptr.null?

      @definition = OGR::FeatureDefinition.new(feature_defn_ptr)
    end

    # @return [OGR::Geometry]
    def geometry
      return @geometry if @geometry

      geometry_ptr = FFI::GDAL.OGR_F_GetGeometryRef(@feature_pointer)
      return nil if geometry_ptr.null?

      @geometry = OGR::Geometry._to_geometry_type(geometry_ptr)
    end

    # @param new_geometry [OGR::Geometry]
    def geometry=(new_geometry)
      ogr_err = FFI::GDAL.OGR_F_SetGeometryDirectly(@feature_pointer, new_geometry.c_pointer)
      @geometry = new_geometry
    end

    # @return [Fixnum]
    def fid
      FFI::GDAL.OGR_F_GetFID(@feature_pointer)
    end

    # @param new_fid [Fixnum]
    def fid=(new_fid)
      ogr_err = FFI::GDAL.OGR_F_SetFID(@feature_pointer, new_fid)
    end

    # @return [Fixnum]
    def geometry_field_count
      FFI::GDAL.OGR_F_GetGeomFieldCount(@feature_pointer)
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
      count_ptr = FFI::MemoryPointer.new(:int)
      list_ints = FFI::GDAL.OGR_F_GetFieldAsIntegerList(@feature_pointer, index, count_ptr)

      list_inst.read_array_of_int
    end

    # @param index [Fixnum]
    # @return [Float]
    def field_as_double(index)
      FFI::GDAL.OGR_F_GetFieldAsDouble(@feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<Float>]
    def field_as_double_list(index)
      count_ptr = FFI::MemoryPointer.new(:int)
      list_ints = FFI::GDAL.OGR_F_GetFieldAsDoubleList(@feature_pointer, index, count_ptr)

      list_inst.read_array_of_double
    end

    # @param index [Fixnum]
    # @return [String]
    def field_as_string(index)
      FFI::GDAL.OGR_F_GetFieldAsString(@feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<String>]
    def field_as_string_list(index)
      count_ptr = FFI::MemoryPointer.new(:int)
      list_ints = FFI::GDAL.OGR_F_GetFieldAsStringList(@feature_pointer, index, count_ptr)

      list_inst.read_array_of_string
    end

    # @return [String]
    def style_string
      FFI::GDAL.OGR_F_GetStyleString(@feature_pointer)
    end

    # @param new_style [String]
    def style_string=(new_style)
      FFI::GDAL.OGR_F_SetStyleString(@feature_pointer, new_style)
    end

    private

    def feature_pointer_from(feature)
      if feature.is_a? OGR::Feature
        feature.c_pointer
      elsif feature.kind_of? FFI::Pointer
        feature
      end
    end
  end
end
