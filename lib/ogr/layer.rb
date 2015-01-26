require_relative '../ffi/ogr'
require_relative 'layer_extensions'

module OGR
  class Layer
    include GDAL::MajorObject
    include LayerExtensions

    def initialize(layer)
      @layer_pointer = GDAL._pointer(OGR::Layer, layer)
      @features = []
      @spatial_reference = nil
      @spatial_filter = nil
      @envelope = nil
      @feature_definition = nil
      @style_table = nil
    end

    def c_pointer
      @layer_pointer
    end

    # @return [String]
    def name
      FFI::GDAL.OGR_L_GetName(@layer_pointer)
    end

    # @return [Symbol] One of OGRwkbGeometryType.
    def geometry_type
      FFI::GDAL.OGR_L_GetGeomType(@layer_pointer)
    end

    # TODO: per the gdal docs: "The returned pointer is to an internally owned
    # object, and should not be altered or deleted by the caller."
    #
    # @return [OGR::Geometry]
    def spatial_filter
      return @spatial_filter if @spatial_filter

      filter_pointer = FFI::GDAL.OGR_L_GetSpatialFilter(@layer_pointer)
      return nil if filter_pointer.null?

      @spatial_filter = OGR::Geometry.factory(filter_pointer)
    end

    # @param new_spatial_filter [OGR::Geometry, FFI::Pointer]
    def spatial_filter=(new_spatial_filter)
      spatial_filter_ptr = GDAL._pointer(OGR::Geometry, new_spatial_filter)
      FFI::GDAL.OGR_L_SetSpatialFilter(@layer_pointer, spatial_filter_ptr)

      @spatial_filter =
        if new_spatial_filter.instance_of? OGR::Geometry
          new_spatial_filter
        else
          OGR::Geometry.factory(new_spatial_filter)
        end
    end

    # Only feature which intersect the filter geometry will be returned.
    #
    # @param geometry_field_index [Fixnum] The spatial filter operates on this
    #   geometry field.
    # @param geometry [OGR::Geometry] Use this geometry as the filtering
    #   region.
    def set_spatial_filter_ex(geometry_field_index, geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)

      FFI::GDAL.OGR_L_SetSpatialFilterEx(
        @layer_pointer, geometry_field_index, geometry_ptr)
    end

    # Only features that geometrically intersect the given rectangle will be
    # returned.  X/Y values should be in the same coordinate system as the
    # layer as a whole (different from #set_spatial_filter_rectangle_ex).  To
    # clear the filter, set #spatial_filter = nil.
    #
    # @param min_x [Float]
    # @param min_y [Float]
    # @param max_x [Float]
    # @param max_x [Float]
    def set_spatial_filter_rectangle(min_x, min_y, max_x, max_y)
      FFI::GDAL.OGR_L_SetSpatialFilterRect(
        @layer_pointer,
        min_x,
        min_y,
        max_x,
        max_y)
    end

    # Only features that geometrically intersect the given rectangle will be
    # returned.  X/Y values should be in the same coordinate system as the
    # layer as the given  GeometryFieldDefinition at the given index (different
    # from #set_spatial_filter_rectangle).  To clear the filter, set
    # #spatial_filter = nil.
    #
    # @param geometry_field_index [Fixnum]
    # @param min_x [Float]
    # @param min_y [Float]
    # @param max_x [Float]
    # @param max_x [Float]
    def set_spatial_filter_rectangle_ex(geometry_field_index, min_x, min_y, max_x, max_y)
      FFI::GDAL.OGR_L_SetSpatialFilterRectEx(
        @layer_pointer,
        geometry_field_index,
        min_x,
        min_y,
        max_x,
        max_y)
    end

    # @return [Boolean]
    def start_transaction
      ogr_err = FFI::GDAL.OGR_L_StartTransaction(@layer_pointer)

      ogr_err.handle_result
    end

    # @param layer_method [OGR::Layer, FFI::Pointer]
    # @return [OGR::Layer] Contains features whose geometries are in one or the
    #   other layer, but not in both.
    def symmetrical_difference(other_layer, **options, &progress)
      other_layer_ptr = GDAL._pointer(OGR::Layer, other_layer)
      # TODO: Should this be allocated by LibC?
      # result_layer_ptr = FFI::Pointer.new(32)
      result_layer_ptr = FFI::MemoryPointer.new(:void)
      # result_layer_ptr = FFI::MemoryPointer.new(:pointer)
      # result_layer_ptr.autorelease = true
      # result_layer_ptr = FFI::LibC.malloc(1)
      puts "other layer inspect: #{other_layer_ptr.size}"
      puts "other layer inspect: #{other_layer_ptr.type_size}"
      puts "other layer inspect: #{other_layer_ptr.address}"
      # result_layer_ptr = other_layer_ptr.dup
      options_ptr = GDAL::Options.pointer(options)

      ogr_err = FFI::GDAL.OGR_L_SymDifference(
        @layer_pointer,
        other_layer_ptr,
        result_layer_ptr,
        options_ptr,
        progress,
        nil
        )

      ogr_err.handle_result
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
      FFI::GDAL.OGR_L_TestCapability(@layer_pointer, capability)
    end

    def union(other_layer, **options, &progress)
      raise NotImplementedError

      other_layer_ptr = GDAL._pointer(OGR::Layer, other_layer)
      # TODO: Should this be allocated by LibC?
      # result_layer_ptr = FFI::Pointer.new(32)
      result_layer_ptr = FFI::MemoryPointer.new(:void)
      # result_layer_ptr = FFI::MemoryPointer.new(:pointer)
      # result_layer_ptr.autorelease = true
      # result_layer_ptr = FFI::LibC.malloc(1)
      puts "other layer inspect: #{other_layer_ptr.size}"
      puts "other layer inspect: #{other_layer_ptr.type_size}"
      puts "other layer inspect: #{other_layer_ptr.address}"
      # result_layer_ptr = other_layer_ptr.dup
      options_ptr = GDAL::Options.pointer(options)

      ogr_err = FFI::GDAL.OGR_L_Union(
        @layer_pointer,
        other_layer_ptr,
        result_layer_ptr,
        options_ptr,
        progress,
        nil
        )

      ogr_err.handle_result
    end

    def update(other_layer, **options, &progress)
      raise NotImplementedError

      other_layer_ptr = GDAL._pointer(OGR::Layer, other_layer)
      # TODO: Should this be allocated by LibC?
      # result_layer_ptr = FFI::Pointer.new(32)
      result_layer_ptr = FFI::MemoryPointer.new(:void)
      # result_layer_ptr = FFI::MemoryPointer.new(:pointer)
      # result_layer_ptr.autorelease = true
      # result_layer_ptr = FFI::LibC.malloc(1)
      puts "other layer inspect: #{other_layer_ptr.size}"
      puts "other layer inspect: #{other_layer_ptr.type_size}"
      puts "other layer inspect: #{other_layer_ptr.address}"
      # result_layer_ptr = other_layer_ptr.dup
      options_ptr = GDAL::Options.pointer(options)

      ogr_err = FFI::GDAL.OGR_L_Union(
        @layer_pointer,
        other_layer_ptr,
        result_layer_ptr,
        options_ptr,
        progress,
        nil
        )

      ogr_err.handle_result
    end

    # The number of features in this layer.  If +force+ is false and it would be
    # expensive to determine the feature count, -1 may be returned.
    #
    # @param force [Boolean] Force the calculation even if it's
    #   expensive.
    # @return [Fixnum]
    def feature_count(force = true)
      FFI::GDAL.OGR_L_GetFeatureCount(@layer_pointer, force)
    end

    # @param index [Fixnum] The 0-based index of the feature to get.  It should
    #   be <= +feature_count+, but not checking is done to ensure.
    # @return [OGR::Feature, nil]
    def feature(index)
      @features.fetch(index) do
        feature_pointer = FFI::GDAL.OGR_L_GetFeature(@layer_pointer, index)
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
      feature_pointer = FFI::GDAL.OGR_L_GetNextFeature(@layer_pointer)
      return nil if feature_pointer.null?

      OGR::Feature.new(feature_pointer)
    end

    # Sets the index for #next_feature.
    #
    # @param feature_index [Fixnum]
    # @return [Boolean]
    def next_feature_index=(feature_index)
      ogr_err = FFI::GDAL.OGR_L_SetNextByIndex(@layer_pointer, feature_index)

      ogr_err.handle_result "Unable to set next feature index to #{feature_index}"
    end

    # @return [Fixnum]
    def features_read
      FFI::GDAL.OGR_L_GetFeaturesRead(@layer_pointer)
    end

    # Uses the already-defined FeatureDefinition to create then write a new feature
    # to the layer.
    #
    # @return [OGR::Feature]
    def create_feature
      feature_def = feature_definition
      feature = OGR::Feature.create(feature_def)
      ogr_err = FFI::GDAL.OGR_L_CreateFeature(@layer_pointer, feature.c_pointer)
      ogr_err.handle_result

      feature
    end

    # Deletes the feature from the layer.
    #
    # TODO: Use OGR_L_TestCapability before trying to delete.
    # @return +true+ if successful, otherwise raises an OGR exception.
    def delete_feature(feature_id)
      ogr_err = FFI::GDAL.OGR_L_DeleteFeature(@layer_pointer, feature_id)

      ogr_err.handle_result
    end

    # Creates and writes a new field to the layer.
    #
    # @param name [String]
    # @param type [FFI::GDAL::OGRFieldType]
    # @param approx_ok [Boolean] If +true+ the field may be created in a slightly
    #   different form, depending on the limitations of the format driver.
    # @return [OGR::Field]
    def create_field(name, type, approx_ok = false)
      field = OGR::Field.create(name, type)
      ogr_err = FFI::GDAL.OGR_L_CreateField(@layer_pointer, field.c_pointer, approx_ok)
      ogr_err.handle_result

      field
    end

    # Deletes the field definition from the layer.
    #
    # TODO: Use OGR_L_TestCapability before trying to delete.
    # @return +true+ if successful, otherwise raises an OGR exception.
    def delete_field(field_id)
      ogr_err = FFI::GDAL.OGR_L_DeleteField(@layer_pointer, field_id)

      ogr_err.handle_result
    end

    # # Creates and writes a new geometry to the layer.
    # #
    # # @return [OGR::GeometryField]
    # def create_geometry_field(approx_ok=false)
    #   geometry_field_definition_ptr = FFI::MemoryPointer.new(:OGRGeomFieldDefnH)
    #   ogr_err = OGR_L_CreateGeomField(@layer_pointer, geometry_field_definition_ptr)
    #
    #   OGR::GeometryFieldDefinition.new(geometry_field_definition_ptr)
    # end

    # Resets the sequential reading of features for this layer.
    def reset_reading
      FFI::GDAL.OGR_L_ResetReading(@layer_pointer)
    end

    # The schema information for this layer.
    #
    # @return [OGR::FeatureDefinition,nil]
    def feature_definition
      return @feature_definition if @feature_definition

      feature_defn_pointer = FFI::GDAL.OGR_L_GetLayerDefn(@layer_pointer)
      return nil if feature_defn_pointer.null?

      @feature_definition = OGR::FeatureDefinition.new(feature_defn_pointer)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      return @spatial_reference if @spatial_reference

      spatial_ref_pointer = FFI::GDAL.OGR_L_GetSpatialRef(@layer_pointer)
      return nil if spatial_ref_pointer.null?

      @spatial_reference = OGR::SpatialReference.new(spatial_ref_pointer)
    end

    # @return [OGR::Envelope]
    def extent(force = true)
      return @envelope if @envelope

      envelope = FFI::GDAL::OGREnvelope.new
      FFI::GDAL.OGR_L_GetExtent(@layer_pointer, envelope, force)
      return nil if envelope.null?

      @envelope = OGR::Envelope.new(envelope)
    end

    # @return [OGR::Envelope]
    def extent_by_geometry(geometry_field_index, force = true)
      envelope = FFI::GDAL::OGREnvelope.new
      FFI::GDAL.OGR_L_GetExtentEx(@layer_pointer, geometry_field_index, envelope, force)
      return nil if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # The name of the underlying database column.  '' if not supported.
    # @return [String]
    def fid_column
      FFI::GDAL.OGR_L_GetFIDColumn(@layer_pointer)
    end

    # @return [String]
    def geometry_column
      FFI::GDAL.OGR_L_GetGeometryColumn(@layer_pointer)
    end

    # @return [OGR::StyleTable, nil]
    def style_table
      return @style_table if @style_table

      style_table_pointer = FFI::GDAL.OGR_L_GetStyleTable(@layer_pointer)
      return nil if style_table_pointer.null?

      @style_table = OGR::StyleTable.new(style_table_pointer)
    end
  end
end
