# frozen_string_literal: true

module OGR
  module LayerMixins
    module OGRFeatureMethods
      # The schema information for this layer.
      #
      # @return [OGR::FeatureDefinition,nil]
      def definition
        feature_defn_pointer = FFI::OGR::API.OGR_L_GetLayerDefn(@c_pointer)
        return nil if feature_defn_pointer.null?

        # This object should not be modified.
        OGR::FeatureDefinition.new(feature_defn_pointer)
      end
      alias feature_definition definition

      # Adds the new OGR::Feature to the Layer. The feature should have been
      # created using the Layer's FeatureDefintion.
      #
      #   feature = OGR::Feature.new(layer.feature_definition)
      #   feature.set_field_integer(123)
      #   layer.create_feature(feature)
      #
      # @param feature [OGR::Feature] [description]
      # @return [Boolean]
      def create_feature(feature)
        unless can_sequential_write?
          raise OGR::UnsupportedOperation, 'This layer does not support feature creation.'
        end

        ogr_err = FFI::OGR::API.OGR_L_CreateFeature(@c_pointer, feature.c_pointer)

        ogr_err.handle_result
      end

      # Deletes the feature from the layer.
      #
      # @param feature_id [Fixnum] ID of the Feature to delete.
      # @return +true+ if successful, otherwise raises an OGR exception.
      # @raise [OGR::Failure] When trying to delete a feature with an ID that
      #   does not exist.
      def delete_feature(feature_id)
        unless can_delete_feature?
          raise OGR::UnsupportedOperation, 'This layer does not support feature deletion.'
        end

        ogr_err = FFI::OGR::API.OGR_L_DeleteFeature(@c_pointer, feature_id)

        ogr_err.handle_result "Unable to delete feature with ID '#{feature_id}'"
      end

      # The number of features in this layer.  If +force+ is false and it would be
      # expensive to determine the feature count, -1 may be returned.
      #
      # @param force [Boolean] Force the calculation even if it's expensive.
      # @return [Fixnum]
      def feature_count(force = true)
        FFI::OGR::API.OGR_L_GetFeatureCount(@c_pointer, force)
      end

      # Rewrites an existing feature using the ID within the given Feature.
      #
      # @param new_feature [OGR::Feature, FFI::Pointer]
      def feature=(new_feature)
        unless can_random_write?
          raise OGR::UnsupportedOperation, '#feature= not supported by this Layer'
        end

        new_feature_ptr = GDAL._pointer(OGR::Feature, new_feature)
        raise OGR::InvalidFeature if new_feature_ptr.nil? || new_feature_ptr.null?

        ogr_err = FFI::OGR::API.OGR_L_SetFeature(@c_pointer, new_feature_ptr)

        ogr_err.handle_result
      end

      # @param index [Fixnum] The 0-based index of the feature to get.  It should
      #   be <= +feature_count+, but no checking is done to ensure.
      # @return [OGR::Feature, nil]
      def feature(index)
        unless can_random_read?
          raise OGR::UnsupportedOperation, '#feature(index) not supported by this Layer'
        end

        feature_pointer = FFI::OGR::API.OGR_L_GetFeature(@c_pointer, index)
        return nil if feature_pointer.null?

        OGR::Feature.new(feature_pointer)
      end

      # The next available feature in this layer.  Only features matching the
      # current spatial filter will be returned.  Use +reset_reading+ to start at
      # the beginning again.
      #
      # NOTE: You *must* call {{OGR::Feature#destroy!}} on the returned feature,
      # otherwise expect segfaults.
      #
      # @return [OGR::Feature, nil]
      def next_feature
        feature_pointer = FFI::OGR::API.OGR_L_GetNextFeature(@c_pointer)
        return if feature_pointer.null?

        OGR::Feature.new(feature_pointer)
      end

      # Sets the index for #next_feature.
      #
      # @param feature_index [Fixnum]
      # @return [Boolean]
      def next_feature_index=(feature_index)
        ogr_err = FFI::OGR::API.OGR_L_SetNextByIndex(@c_pointer, feature_index)

        ogr_err.handle_result "Unable to set next feature index to #{feature_index}"
      end
      alias set_next_by_index next_feature_index=

      # @return [Fixnum]
      def features_read
        FFI::OGR::API.OGR_L_GetFeaturesRead(@c_pointer)
      end

      # Resets the sequential reading of features for this layer.
      def reset_reading
        FFI::OGR::API.OGR_L_ResetReading(@c_pointer)
      end
    end
  end
end
