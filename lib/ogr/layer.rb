require_relative '../ffi/ogr'
require_relative 'envelope'
require_relative 'geometry'
require_relative 'feature'
require_relative 'feature_definition'
require_relative 'spatial_reference'
require_relative 'style_table'

module OGR
  class Layer
    include FFI::GDAL
    include GDAL::MajorObject

    def initialize(layer)
      @ogr_layer_pointer = if layer.is_a? OGR::Layer
        layer.c_pointer
      else
        layer
      end
    end

    def c_pointer
      @ogr_layer_pointer
    end

    # @return [String]
    def name
      OGR_L_GetName(@ogr_layer_pointer)
    end

    # @return [Symbol] One of OGRwkbGeometryType.
    def geometry_type
      OGR_L_GetGeomType(@ogr_layer_pointer)
    end

    # TODO: per the gdal docs: "The returned pointer is to an internally owned object, and should not be altered or deleted by the caller."
    #
    # @return [OGR::Geometry]
    def spatial_filter
      filter_pointer = OGR_L_GetSpatialFilter(@ogr_layer_pointer)
      return nil if filter_pointer.null?

      OGR::Geometry.new(ogr_geometry_pointer: filter_pointer)
    end

    # The number of features in this layer.  If +force+ is false and it would be
    # expensive to determine the feature count, -1 may be returned.
    #
    # @param force [Boolean] Force the calculation even if it's
    #   expensive.
    # @return [Fixnum]
    def feature_count(force=true)
      OGR_L_GetFeatureCount(@ogr_layer_pointer, force)
    end

    # @param index [Fixnum] The 0-based index of the feature to get.  It should
    #   be <= +feature_count+, but not checking is done to ensure.
    # @return [OGR::Feature, nil]
    def feature(index)
      feature_pointer = OGR_L_GetFeature(@ogr_layer_pointer, index)
      return nil if feature_pointer.null?

      OGR::Feature.new(feature_pointer)
    end

    # The next available feature in this layer.  Only features matching the
    # current spatial filter will be returned.  Use +reset_reading+ to start at
    # the beginning again.
    #
    # @return [OGR::Feature, nil]
    def next_feature
      feature_pointer = OGR_L_GetNextFeature(@ogr_layer_pointer)
      return nil if feature_pointer.null?

      OGR::Feature.new(ogr_feature_pointer: feature_pointer)
    end

    # @return [Fixnum]
    def features_read
      OGR_L_GetFeaturesRead(@ogr_layer_pointer)
    end

    # Creates and writes a new feature to the layer.
    #
    # @return [OGR::Feature]
    def create_feature
      feature_ptr = FFI::MemoryPointer.new(:OGRFeatureH)
      ogr_err = OGR_L_CreateFeature(@ogr_layer_pointer, feature_ptr)

      OGR::Feature.new(feature_ptr)
    end

    # Deletes the feature from the layer.
    #
    # TODO: Use OGR_L_TestCapability before trying to delete.
    def delete_feature(feature_id)
      ogr_err = OGR_L_DeleteFeature(@ogr_layer_pointer, feature_id)
    end

    # Creates and writes a new field to the layer.
    #
    # @return [OGR::Field]
    def create_field(approx_ok=false)
      field_ptr = FFI::MemoryPointer.new(:OGRFieldDefnH)
      ogr_err = OGR_L_CreateField(@ogr_layer_pointer, field_ptr)

      OGR::Field.new(field_ptr)
    end

    # Deletes the field definition from the layer.
    #
    # TODO: Use OGR_L_TestCapability before trying to delete.
    def delete_field(field_id)
      ogr_err = OGR_L_DeleteField(@ogr_layer_pointer, field_id)
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
      OGR_L_ResetReading(@ogr_layer_pointer)
    end

    # The schema information for this layer.
    #
    # @return [OGR::FeatureDefinition,nil]
    def definition
      feature_defn_pointer = OGR_L_GetLayerDefn(@ogr_layer_pointer)
      return nil if feature_defn_pointer.null?

      OGR::FeatureDefinition.new(feature_defn_pointer)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_pointer = OGR_L_GetSpatialRef(@ogr_layer_pointer)
      return nil if spatial_ref_pointer.null?

      OGR::SpatialReference.new(spatial_ref_pointer)
    end

    # @return [OGR::Envelope]
    def extent(force=true)
      envelope = FFI::GDAL::OGREnvelope.new
      OGR_L_GetExtent(@ogr_layer_pointer, envelope, force)
      return nil if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # @return [OGR::Envelope]
    def extent_by_geometry(geometry_field_index, force=true)
      envelope = FFI::GDAL::OGREnvelope.new
      OGR_L_GetExtentEx(@ogr_layer_pointer, geometry_field_index, envelope, force)
      return nil if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # The name of the underlying database column.  '' if not supported.
    # @return [String]
    def fid_column
      OGR_L_GetFIDColumn(@ogr_layer_pointer)
    end

    # @return [String]
    def geometry_column
      OGR_L_GetGeometryColumn(@ogr_layer_pointer)
    end

    # @return [OGR::StyleTable, nil]
    def style_table
      style_table_pointer = OGR_L_GetStyleTable(@ogr_layer_pointer)
      return nil if style_table_pointer.null?

      OGR::StyleTable.new(ogr_style_table_pointer: style_table_pointer)
    end
  end
end
