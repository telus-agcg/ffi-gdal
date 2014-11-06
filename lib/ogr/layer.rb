require_relative '../ffi/ogr'
require_relative 'layer_extensions'
require_relative 'envelope'
require_relative 'geometry'
require_relative 'feature'
require_relative 'feature_definition'
require_relative 'spatial_reference'
require_relative 'style_table'

module OGR
  class Layer
    include GDAL::MajorObject
    include LayerExtensions

    def initialize(layer)
      @ogr_layer_pointer = GDAL._pointer(OGR::Layer, layer)
      @features = []
    end

    def c_pointer
      @ogr_layer_pointer
    end

    # @return [String]
    def name
      FFI::GDAL.OGR_L_GetName(@ogr_layer_pointer)
    end

    # @return [Symbol] One of OGRwkbGeometryType.
    def geometry_type
      FFI::GDAL.OGR_L_GetGeomType(@ogr_layer_pointer)
    end

    # TODO: per the gdal docs: "The returned pointer is to an internally owned
    # object, and should not be altered or deleted by the caller."
    #
    # @return [OGR::Geometry]
    def spatial_filter
      return @spatial_filter if @spatial_filter

      filter_pointer = FFI::GDAL.OGR_L_GetSpatialFilter(@ogr_layer_pointer)
      return nil if filter_pointer.null?

      @spatial_filter = OGR::Geometry.new(filter_pointer)
    end

    # The number of features in this layer.  If +force+ is false and it would be
    # expensive to determine the feature count, -1 may be returned.
    #
    # @param force [Boolean] Force the calculation even if it's
    #   expensive.
    # @return [Fixnum]
    def feature_count(force=true)
      FFI::GDAL.OGR_L_GetFeatureCount(@ogr_layer_pointer, force)
    end

    # @param index [Fixnum] The 0-based index of the feature to get.  It should
    #   be <= +feature_count+, but not checking is done to ensure.
    # @return [OGR::Feature, nil]
    def feature(index)
      @features.fetch(index) do
        feature_pointer = FFI::GDAL.OGR_L_GetFeature(@ogr_layer_pointer, index)
        return nil if feature_pointer.null?

        feature = OGR::Feature.new(feature_pointer)
        @features.insert(index, feature)

        feature
      end
    end

    # The next available feature in this layer.  Only features matching the
    # current spatial filter will be returned.  Use +reset_reading+ to start at
    # the beginning again.
    #
    # @return [OGR::Feature, nil]
    def next_feature
      feature_pointer = FFI::GDAL.OGR_L_GetNextFeature(@ogr_layer_pointer)
      return nil if feature_pointer.null?

      OGR::Feature.new(feature_pointer)
    end

    # @return [Fixnum]
    def features_read
      FFI::GDAL.OGR_L_GetFeaturesRead(@ogr_layer_pointer)
    end

    # Uses the already-defined FeatureDefinition to create then write a new feature
    # to the layer.
    #
    # @return [OGR::Feature]
    def create_feature
      feature_def = feature_definition
      feature = OGR::Feature.create(feature_def)
      ogr_err = FFI::GDAL.OGR_L_CreateFeature(@ogr_layer_pointer, feature.c_pointer)
      ogr_err.to_ruby

      feature
    end

    # Deletes the feature from the layer.
    #
    # TODO: Use OGR_L_TestCapability before trying to delete.
    # @return +true+ if successful, otherwise raises an OGR exception.
    def delete_feature(feature_id)
      ogr_err = FFI::GDAL.OGR_L_DeleteFeature(@ogr_layer_pointer, feature_id)

      ogr_err.to_ruby
    end

    # Creates and writes a new field to the layer.
    #
    # @param name [String]
    # @param type [FFI::GDAL::OGRFieldType]
    # @param approx_ok [Boolean] If +true+ the field may be created in a slightly
    #   different form, depending on the limitations of the format driver.
    # @return [OGR::Field]
    def create_field(name, type, approx_ok=false)
      field = OGR::Field.create(name, type)
      ogr_err = FFI::GDAL.OGR_L_CreateField(@ogr_layer_pointer, field.c_pointer, approx_ok)
      ogr_err.to_ruby

      field
    end

    # @param field [OGR::Field, FFI::Pointer]
    # @param approx_ok [Boolean] If +true+ the field may be created in a slightly
    #   different form, depending on the limitations of the format driver.
    # @return +true+ if successful, otherwise raises an OGR exception.
    def add_field(field, approx_ok=false)
      field_ptr = GDAL._pointer(OGR::Field, field)
      ogr_err = FFI::GDAL.OGR_L_CreateField(@ogr_layer_pointer, field_ptr, approx_ok)

      ogr_err.to_ruby
    end

    # Deletes the field definition from the layer.
    #
    # TODO: Use OGR_L_TestCapability before trying to delete.
    # @return +true+ if successful, otherwise raises an OGR exception.
    def delete_field(field_id)
      ogr_err = FFI::GDAL.OGR_L_DeleteField(@ogr_layer_pointer, field_id)

      ogr_err.to_ruby
    end

    # # Creates and writes a new geometry to the layer.
    # #
    # # @return [OGR::GeometryField]
    # def create_geometry_field(approx_ok=false)
    #   geometry_field_definition_ptr = FFI::MemoryPointer.new(:OGRGeomFieldDefnH)
    #   ogr_err = OGR_L_CreateGeomField(@ogr_layer_pointer, geometry_field_definition_ptr)
    #
    #   OGR::GeometryFieldDefinition.new(geometry_field_definition_ptr)
    # end

    # Resets the sequential reading of features for this layer.
    def reset_reading
      FFI::GDAL.OGR_L_ResetReading(@ogr_layer_pointer)
    end

    # The schema information for this layer.
    #
    # @return [OGR::FeatureDefinition,nil]
    def feature_definition
      return @feature_definition if @feature_definition

      feature_defn_pointer = FFI::GDAL.OGR_L_GetLayerDefn(@ogr_layer_pointer)
      return nil if feature_defn_pointer.null?

      @feature_definition = OGR::FeatureDefinition.new(feature_defn_pointer)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      return @spatial_reference if @spatial_reference

      spatial_ref_pointer = FFI::GDAL.OGR_L_GetSpatialRef(@ogr_layer_pointer)
      return nil if spatial_ref_pointer.null?

      @spatial_reference = OGR::SpatialReference.new(spatial_ref_pointer)
    end

    # @return [OGR::Envelope]
    def extent(force=true)
      return @envelope if @envelope

      envelope = FFI::GDAL::OGREnvelope.new
      FFI::GDAL.OGR_L_GetExtent(@ogr_layer_pointer, envelope, force)
      return nil if envelope.null?

      @envelope = OGR::Envelope.new(envelope)
    end

    # @return [OGR::Envelope]
    def extent_by_geometry(geometry_field_index, force=true)
      envelope = FFI::GDAL::OGREnvelope.new
      FFI::GDAL.OGR_L_GetExtentEx(@ogr_layer_pointer, geometry_field_index, envelope, force)
      return nil if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # The name of the underlying database column.  '' if not supported.
    # @return [String]
    def fid_column
      FFI::GDAL.OGR_L_GetFIDColumn(@ogr_layer_pointer)
    end

    # @return [String]
    def geometry_column
      FFI::GDAL.OGR_L_GetGeometryColumn(@ogr_layer_pointer)
    end

    # @return [OGR::StyleTable, nil]
    def style_table
      return @style_table if @style_table

      style_table_pointer = FFI::GDAL.OGR_L_GetStyleTable(@ogr_layer_pointer)
      return nil if style_table_pointer.null?

      @style_table = OGR::StyleTable.new(style_table_pointer)
    end
  end
end
