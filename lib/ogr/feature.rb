require_relative '../ffi/ogr'
require_relative 'feature_definition'
require_relative 'field'
require_relative 'field_definition'

module OGR
  class Feature
    include FFI::GDAL

    def initialize(ogr_feature_pointer: nil)
      @ogr_feature_pointer = if ogr_feature_pointer
        ogr_feature_pointer
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

    # @return [OGR::FeatureDefinition,nil]
    def definition
      feature_defn_ptr = OGR_F_GetDefRef(@ogr_feature_pointer)
      return nil if feature_defn_ptr.null?

      OGR::FeatureDefinition.new(ogr_feature_defn_pointer: feature_defn_ptr)
    end

    # @return [OGR::Geometry]
    def geometry
      geometry_ptr = OGR_F_GetGeometryRef(@ogr_feature_pointer)
      return nil if geometry_ptr.null?

      OGR::Geometry.new(ogr_geometry_pointer: geometry_ptr)
    end

    # @return [Boolean]
    def equal?(other_feature)
      OGR_F_Equal(@ogr_feature_pointer, feature_pointer_from(other_feature))
    end
    alias_method :equals?, :equal?

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
