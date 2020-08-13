# frozen_string_literal: true

module OGR
  module DataSourceMixins
    # Helper methods for determining the current DataSource's capabilities.
    module CapabilityMethods
      # @return [Boolean] +true+ if the DataSource can create existing Layers.
      def can_create_layer?
        test_capability(FFI::OGR::Core::ODS_C_CREATE_LAYER)
      end

      # @return [Boolean] +true+ if the DataSource can delete existing Layers.
      def can_delete_layer?
        test_capability(FFI::OGR::Core::ODS_C_DELETE_LAYER)
      end

      # @return [Boolean] +true+ if the DataSource supports creating a
      #   GeometryField after a Layer has been created.
      def can_create_geometry_field_after_create_layer?
        test_capability(FFI::OGR::Core::ODS_C_CREATE_GEOM_FIELD_AFTER_CREATE_LAYER)
      end

      # @return [Boolean] +true+ if the DataSource supports curve geometries.
      def supports_curve_geometries?
        test_capability(FFI::OGR::Core::ODS_C_CURVE_GEOMETRIES)
      end

      # @return [Boolean]
      def supports_transactions?
        test_capability(FFI::OGR::Core::ODS_C_TRANSACTIONS)
      end

      # @return [Boolean]
      def supports_emulated_transactions?
        test_capability(FFI::OGR::Core::ODS_C_EMULATED_TRANSACTIONS)
      end

      # @return [Boolean]
      def supports_random_layer_read?
        test_capability(FFI::OGR::Core::ODS_C_RANDOM_LAYER_READ)
      end

      # @return [Boolean]
      def supports_random_layer_write?
        test_capability(FFI::OGR::Core::ODS_C_RANDOM_LAYER_WRITE)
      end
    end
  end
end
