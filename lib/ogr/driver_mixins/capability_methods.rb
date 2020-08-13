# frozen_string_literal: true

module OGR
  module DriverMixins
    # Helper methods for testing capabilities of the current driver.
    module CapabilityMethods
      # @return [Boolean] +true+ if this driver supports creating data sources.
      def can_create_data_source?
        if GDAL.major_version >= 2
          # This is weird, but it doesn't work with the normal const.
          test_capability('DCAP_CREATE')
        else
          test_capability(FFI::OGR::Core::ODR_C_CREATE_DATA_SOURCE)
        end
      end

      # @return [Boolean] +true+ if this driver supports deleting data sources.
      def can_delete_data_source?
        test_capability(FFI::OGR::Core::ODR_C_DELETE_DATA_SOURCE)
      end
    end
  end
end
