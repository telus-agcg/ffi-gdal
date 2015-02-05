module OGR
  module LayerMixins
    module OGRFeatureMethods
      # The schema information for this layer.
      #
      # @return [OGR::FeatureDefinition,nil]
      def feature_definition
        feature_defn_pointer = FFI::GDAL.OGR_L_GetLayerDefn(@layer_pointer)
        return nil if feature_defn_pointer.null?

        # This object should not be modified.
        OGR::FeatureDefinition.new(feature_defn_pointer)
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
      # @param feature_id [Fixnum] ID of the Feature to delete.
      # @return +true+ if successful, otherwise raises an OGR exception.
      # @raise [OGR::Failure] When trying to delete a feature with an ID that
      #   does not exist.
      # TODO: Use OGR_L_TestCapability before trying to delete.
      def delete_feature(feature_id)
        ogr_err = FFI::GDAL.OGR_L_DeleteFeature(@layer_pointer, feature_id)

        ogr_err.handle_result "Unable to delete feature with ID '#{feature_id}'"
      end

      # The number of features in this layer.  If +force+ is false and it would be
      # expensive to determine the feature count, -1 may be returned.
      #
      # @param force [Boolean] Force the calculation even if it's expensive.
      # @return [Fixnum]
      def feature_count(force = true)
        FFI::GDAL.OGR_L_GetFeatureCount(@layer_pointer, force)
      end

      # @param index [Fixnum] The 0-based index of the feature to get.  It should
      #   be <= +feature_count+, but no checking is done to ensure.
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

      # Rewrites an existing feature using the ID within the given Feature.
      #
      # @param [OGR::Feature, FFI::Pointer]
      # TODO: Use OGR_L_TestCapability(OLCRandomWrite) to establish if this layer supports random access writing
      def feature=(new_feature)
        new_feature_ptr = GDAL._pointer(OGR::Feature, new_feature)
        fail OGR::InvalidFeature if new_feature_ptr.nil? || new_feature_ptr.null?

        ogr_err = FFI::GDAL.OGR_L_SetFeature(@layer_pointer, new_feature_ptr)

        ogr_err.handle_result
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

      # Resets the sequential reading of features for this layer.
      def reset_reading
        FFI::GDAL.OGR_L_ResetReading(@layer_pointer)
      end
    end
  end
end
