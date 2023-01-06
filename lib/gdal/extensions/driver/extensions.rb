# frozen_string_literal: true

require 'gdal/driver'

module GDAL
  class Driver
    module Extensions
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        # @return [Array<String>]
        def short_names
          names = Array.new(count) { |i| at_index(i).short_name }

          names.compact.sort
        end

        # @return [Array<String>]
        def long_names
          names = Array.new(count) { |i| at_index(i).long_name }

          names.compact.sort
        end

        # @return [Hash{String => String}] Keys are driver short names, values are
        #   driver long names.
        def self.names
          names = count.times.each_with_object({}) do |i, obj|
            driver = at_index(i)
            obj[driver.short_name] = driver.long_name
          end

          names.sort.to_h
        end
      end

      # The things that this driver can do, as reported by its metadata.
      # Possibilities include:
      #   * :open
      #   * :create
      #   * :copy
      #   * :virtual_io
      #   * :rasters
      #   * :vectors
      #
      # @return [Array<Symbol>]
      def capabilities
        caps = []
        caps << :open if can_open_datasets?
        caps << :create if can_create_datasets?
        caps << :copy if can_copy_datasets?
        caps << :virtual_io if can_do_virtual_io?
        caps << :rasters if can_do_rasters?
        caps << :vectors if can_do_vectors?

        caps
      end

      # @return [Boolean]
      def can_open_datasets?
        metadata_item('DCAP_OPEN') == 'YES'
      end

      # @return [Boolean]
      def can_create_datasets?
        metadata_item('DCAP_CREATE') == 'YES'
      end

      # @return [Boolean]
      def can_copy_datasets?
        metadata_item('DCAP_CREATECOPY') == 'YES'
      end

      # @return [Boolean]
      def can_do_virtual_io?
        metadata_item('DCAP_VIRTUALIO') == 'YES'
      end

      # @return [Boolean]
      def can_do_rasters?
        metadata_item('DCAP_RASTER') == 'YES'
      end

      # @return [Boolean]
      def can_do_vectors?
        metadata_item('DCAP_VECTOR') == 'YES'
      end
    end
  end
end

GDAL::Driver.include(GDAL::Driver::Extensions)
