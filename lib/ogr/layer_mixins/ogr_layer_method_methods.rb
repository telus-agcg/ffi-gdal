module OGR
  module LayerMixins
    # OGR::Layer methods: Ruby methods that operate on a OGR::Layer using a
    # "method layer". The method layer is combined with the current layer in some
    # fashion, which results in a new OGR::Layer.
    module OGRLayerMethodMethods
      # Clip off areas of this layer that are not covered by the method layer. The
      # result layer contains features whose geometries represent areas that are
      # in the input layer and in the method layer. The features in the result
      # layer have the (possibly clipped) areas of features in the input layer and
      # the attributes from the same features.
      #
      # @param method_layer [OGR::Layer]
      # @param options [Hash]
      # @option options [:yes, :no] skip_failures (:no) Setting to :yes lets
      #   the function continue even when a feature could not be inserted.
      # @option options [:yes, :no] promote_to_multi (:no) Setting to :yes
      #   converts Polygons to MultiPolygons, LineStrings to MultiLineStrings.
      # @option options [String] input_prefix Set a prefix for the field names
      #   that will be created from the fields of the input Layer.
      # @option options [String] method_prefix Set a prefix for the field names
      #   that will be created from the fields of the method Layer.
      def clip(method_layer, **options, &progress)
        run_layer_method(:OGR_L_Clip, method_layer, **options, &progress)
      end

      # Remove areas in this layer that are covered by the method layer.
      #
      # The result layer contains features whose geometries represent areas that
      # are in this layer but not in the method layer. The features in the result
      # layer have attributes from this layer.
      #
      # @param method_layer [OGR::Layer]
      # @param options [Hash]
      # @option options [:yes, :no] skip_failures (:no) Setting to :yes lets
      #   the function continue even when a feature could not be inserted.
      # @option options [:yes, :no] promote_to_multi (:no) Setting to :yes
      #   converts Polygons to MultiPolygons, LineStrings to MultiLineStrings.
      # @option options [String] input_prefix Set a prefix for the field names
      #   that will be created from the fields of the input Layer.
      # @option options [String] method_prefix Set a prefix for the field names
      #   that will be created from the fields of the method Layer.
      def erase(method_layer, **options, &progress)
        run_layer_method(:OGR_L_Erase, method_layer, **options, &progress)
      end

      # The result layer contains features whose geometries represent areas that
      # are in the input layer.  The features in the result layer have attributes
      # from both input and method layers.
      #
      # @param method_layer [OGR::Layer]
      # @param options [Hash]
      # @option options [:yes, :no] skip_failures (:no) Setting to :yes lets
      #   the function continue even when a feature could not be inserted.
      # @option options [:yes, :no] promote_to_multi (:no) Setting to :yes
      #   converts Polygons to MultiPolygons, LineStrings to MultiLineStrings.
      # @option options [String] input_prefix Set a prefix for the field names
      #   that will be created from the fields of the input Layer.
      # @option options [String] method_prefix Set a prefix for the field names
      #   that will be created from the fields of the method Layer.
      def identity(method_layer, **options, &progress)
        run_layer_method(:OGR_L_Identity, method_layer, **options, &progress)
      end

      # Intersection of this layer and +method_layer+.
      #
      # @param method_layer [OGR::Layer]
      # @param options [Hash]
      # @option options [:yes, :no] skip_failures (:no) Setting to :yes lets
      #   the function continue even when a feature could not be inserted.
      # @option options [:yes, :no] promote_to_multi (:no) Setting to :yes
      #   converts Polygons to MultiPolygons, LineStrings to MultiLineStrings.
      # @option options [String] input_prefix Set a prefix for the field names
      #   that will be created from the fields of the input Layer.
      # @option options [String] method_prefix Set a prefix for the field names
      #   that will be created from the fields of the method Layer.
      def intersection(method_layer, **options, &progress)
        run_layer_method(:OGR_L_Intersection, method_layer, **options, &progress)
      end

      # The result layer contains features whose geometries represent areas that
      # are either in this layer or the method layer, but not in both. The
      # features in the result layer have attributes from both this layer and
      # the method layer.  For features which represent areas that are only in
      # this layer or the method layer, the respective attributes have undefined
      # values.
      #
      # @param method_layer [OGR::Layer]
      # @param options [Hash]
      # @option options [:yes, :no] skip_failures (:no) Setting to :yes lets
      #   the function continue even when a feature could not be inserted.
      # @option options [:yes, :no] promote_to_multi (:no) Setting to :yes
      #   converts Polygons to MultiPolygons, LineStrings to MultiLineStrings.
      # @option options [String] input_prefix Set a prefix for the field names
      #   that will be created from the fields of the input Layer.
      # @option options [String] method_prefix Set a prefix for the field names
      #   that will be created from the fields of the method Layer.
      def symmetrical_difference(method_layer, **options, &progress)
        run_layer_method(:OGR_L_SymDifference, method_layer, **options, &progress)
      end

      # The result layer contains features whose geometries represent areas that
      # are either in this layer or the method layer. The features in the result
      # layer have attributes from both this layer and the method layer. For
      # features which represent areas that are only in this or in the method
      # layer, the respective attributes have undefined values.
      #
      # @param method_layer [OGR::Layer]
      # @param options [Hash]
      # @option options [:yes, :no] skip_failures (:no) Setting to :yes lets
      #   the function continue even when a feature could not be inserted.
      # @option options [:yes, :no] promote_to_multi (:no) Setting to :yes
      #   converts Polygons to MultiPolygons, LineStrings to MultiLineStrings.
      # @option options [String] input_prefix Set a prefix for the field names
      #   that will be created from the fields of the input Layer.
      # @option options [String] method_prefix Set a prefix for the field names
      #   that will be created from the fields of the method Layer.
      def union(method_layer, **options, &progress)
        run_layer_method(:OGR_L_Union, method_layer, **options, &progress)
      end

      # Update this layer with features from the update layer. The result layer
      # contains features whose geometries represent areas that are either in this
      # layer or the method layer. The features in the result layer have areas
      # of the features of the method layer or those areas of the features of this
      # layer that are not covered by the method layer. The features of the result
      # layer get their attributes from this layer.
      #
      # @param method_layer [OGR::Layer]
      # @param options [Hash]
      # @option options [:yes, :no] skip_failures (:no) Setting to :yes lets
      #   the function continue even when a feature could not be inserted.
      # @option options [:yes, :no] promote_to_multi (:no) Setting to :yes
      #   converts Polygons to MultiPolygons, LineStrings to MultiLineStrings.
      # @option options [String] input_prefix Set a prefix for the field names
      #   that will be created from the fields of the input Layer.
      # @option options [String] method_prefix Set a prefix for the field names
      #   that will be created from the fields of the method Layer.
      def update(method_layer, **options, &progress)
        run_layer_method(:OGR_L_Update, method_layer, **options, &progress)
      end

      private

      def run_layer_method(method_name, method_layer, **options, &progress)
        method_layer_ptr = GDAL._pointer(OGR::Layer, method_layer)
        options_ptr = GDAL::Options.pointer(options)
        result_layer_ptr = FFI::MemoryPointer.new(:OGRLayerH)

        ogr_err = FFI::GDAL.send(method_name,
          @c_pointer,
          method_layer_ptr,
          result_layer_ptr,
          options_ptr,
          progress,
          nil)
        ogr_err.handle_result

        OGR::Layer.new(result_layer_ptr)
      end
    end
  end
end
