# frozen_string_literal: true

require 'ogr/driver'

module OGR
  module DriverMixins
    # Helper methods for testing capabilities of the current driver.
    module CapabilityMethods
      # @return [Boolean] +true+ if this driver supports creating data sources.
      def can_create_data_source?
        test_capability('CreateDataSource')
      end

      # @return [Boolean] +true+ if this driver supports deleting data sources.
      def can_delete_data_source?
        test_capability('DeleteDataSource')
      end
    end
  end
end

OGR::Driver.include(OGR::DriverMixins::CapabilityMethods)
