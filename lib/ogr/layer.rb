require_relative '../ffi/ogr'
require_relative 'layer_mixins/extensions'
require_relative 'layer_mixins/ogr_feature_methods'
require_relative 'layer_mixins/ogr_field_methods'
require_relative 'layer_mixins/ogr_layer_method_methods'
require_relative 'layer_mixins/ogr_query_filter_methods'
require_relative 'layer_mixins/ogr_sql_methods'

module OGR
  class Layer
    include GDAL::MajorObject
    include LayerMixins::Extensions
    include LayerMixins::OGRFeatureMethods
    include LayerMixins::OGRFieldMethods
    include LayerMixins::OGRLayerMethodMethods
    include LayerMixins::OGRQueryFilterMethods
    include LayerMixins::OGRSQLMethods

    eval FFI::GDAL::OGR_ALTER.to_ruby

    # @param layer_ptr [FFI::Pointer]
    def initialize(layer_ptr)
      @layer_pointer = layer_ptr
      @features = []
    end

    def c_pointer
      @layer_pointer
    end

    # @return [String]
    def name
      FFI::GDAL.OGR_L_GetName(@layer_pointer)
    end

    # @return [Boolean]
    # TODO: This seems to occasionally lead to: 28352 illegal hardware
    #   instruction, and sometimes full crashes.
    def sync_to_disk
      ogr_err = FFI::GDAL.OGR_L_SyncToDisk(@layer_pointer)

      ogr_err.handle_result
    end

    # Tests if this layer supports the given capability.  Must be in the list
    # of available capabilities.  See http://www.gdal.org/ogr__api_8h.html#a480adc8b839b04597f49583371d366fd.
    #
    # @param capability [String]
    # @return [Boolean]
    # @see http://www.gdal.org/ogr__api_8h.html#a480adc8b839b04597f49583371d366fd
    def test_capability(capability)
      FFI::GDAL.OGR_L_TestCapability(@layer_pointer, capability.to_s)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_pointer = FFI::GDAL.OGR_L_GetSpatialRef(@layer_pointer)
      return nil if spatial_ref_pointer.null?

      OGR::SpatialReference.new(spatial_ref_pointer)
    end

    # @return [OGR::Envelope]
    def extent(force = true)
      envelope = FFI::GDAL::OGREnvelope.new
      FFI::GDAL.OGR_L_GetExtent(@layer_pointer, envelope, force)
      return nil if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # @return [OGR::Envelope]
    def extent_by_geometry(geometry_field_index, force = true)
      envelope = FFI::GDAL::OGREnvelope.new
      FFI::GDAL.OGR_L_GetExtentEx(@layer_pointer, geometry_field_index, envelope, force)
      return nil if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # @return [Symbol] One of OGRwkbGeometryType.
    def geometry_type
      FFI::GDAL.OGR_L_GetGeomType(@layer_pointer)
    end

    # @return [OGR::StyleTable, nil]
    def style_table
      style_table_pointer = FFI::GDAL.OGR_L_GetStyleTable(@layer_pointer)
      return nil if style_table_pointer.null?

      OGR::StyleTable.new(style_table_pointer)
    end

    # @param [OGR::StyleTable, FFI::pointer]
    def style_table=(new_style_table)
      style_table_ptr = GDAL._pointer(OGR::StyleTable, new_style_table)
      fail OGR::Failure if style_table_ptr.nil? || style_table_ptr.null?

      FFI::GDAL.OGR_L_SetStyleTable(@layer_pointer, style_table_ptr)
    end
  end
end
