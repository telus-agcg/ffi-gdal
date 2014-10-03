require_relative '../ffi/ogr'
require_relative 'feature_definition'
require_relative 'field_definition'

module OGR
  class Feature
    include FFI::GDAL

    # @param feature_definition [OGR::FeatureDefinition]
    def initialize(feature_def, ogr_feature_pointer: nil)
      @ogr_feature_pointer = if ogr_feature_pointer
        ogr_feature_pointer
      else
        OGR_F_Create(feature_def.c_pointer)
      end

      close_me = -> { FFI::GDAL.OGR_F_Destroy(@ogr_feature_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @ogr_feature_pointer
    end

    # @return [Fixnum]
    def field_count
      OGR_F_FieldCount(@ogr_feature_pointer)
    end

    # @param index [Fixnum]
    # @return [OGR::FieldDefinition]
    def field_definition(index)
      field_defn_pointer = OGR_F_GetFieldDefnRef(@ogr_feature_pointer, index)
      return nil if field_defn_pointer.null?

      OGR::FieldDefinition.new(ogr_field_defn_pointer: field_defn_pointer)
    end

    # @param name [String]
    # @return [Fixnum]
    def field_index(name)
      OGR_F_GetFieldIndex(@ogr_feature_pointer, name)
    end

    # @param index [Fixnum]
    # @return [Boolean]
    def field_set?(index)
      OGR_F_IsFieldSet(@ogr_feature_pointer, index)
    end

    # @return [FFI::GDAL::OGRField]
    def field(index)
      OGR_F_GetRawFieldRef(@ogr_feature_pointer, index)
    end

    # @param index [Fixnum]
    def unset_field(index)
      OGR_F_UnsetField(@ogr_feature_pointer, index)
    end

    # @return [OGR::FeatureDefinition,nil]
    def definition
      feature_defn_ptr = OGR_F_GetDefRef(@ogr_feature_pointer)
      return nil if feature_defn_ptr.null?

      OGR::FeatureDefinition.new('', ogr_feature_defn_pointer: feature_defn_ptr)
    end

    # @return [OGR::Geometry]
    def geometry
      geometry_ptr = OGR_F_GetGeometryRef(@ogr_feature_pointer)
      return nil if geometry_ptr.null?

      OGR::Geometry.new(ogr_geometry_pointer: geometry_ptr)
    end

    # @param new_geometry [OGR::Geometry]
    def geometry=(new_geometry)
      ogr_err = OGR_F_SetGeometry(@ogr_feature_pointer, new_geometry.c_pointer)
    end

    # @return [Fixnum]
    def geometry_field_count
      OGR_F_GetGeomFieldCount(@ogr_feature_pointer)
    end

    # @return [Boolean]
    def equal?(other_feature)
      OGR_F_Equal(@ogr_feature_pointer, feature_pointer_from(other_feature))
    end
    alias_method :equals?, :equal?

    # @param index [Fixnum]
    # @return [Fixnum]
    def field_as_integer(index)
      OGR_F_GetFieldAsInteger(@ogr_feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<Fixnum>]
    def field_as_integer_list(index)
      count_ptr = FFI::MemoryPointer.new(:int)
      list_ints = OGR_F_GetFieldAsIntegerList(@ogr_feature_pointer, index, count_ptr)

      list_inst.read_array_of_int
    end

    # @param index [Fixnum]
    # @return [Float]
    def field_as_double(index)
      OGR_F_GetFieldAsDouble(@ogr_feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<Float>]
    def field_as_double_list(index)
      count_ptr = FFI::MemoryPointer.new(:int)
      list_ints = OGR_F_GetFieldAsDoubleList(@ogr_feature_pointer, index, count_ptr)

      list_inst.read_array_of_double
    end

    # @param index [Fixnum]
    # @return [String]
    def field_as_string(index)
      OGR_F_GetFieldAsString(@ogr_feature_pointer, index)
    end

    # @param index [Fixnum]
    # @return [Array<String>]
    def field_as_string_list(index)
      count_ptr = FFI::MemoryPointer.new(:int)
      list_ints = OGR_F_GetFieldAsStringList(@ogr_feature_pointer, index, count_ptr)

      list_inst.read_array_of_string
    end

    # @return [String]
    def style_string
      OGR_F_GetStyleString(@ogr_feature_pointer)
    end

    # @param new_style [String]
    def style_string=(new_style)
      OGR_F_SetStyleString(@ogr_feature_pointer, new_style)
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
