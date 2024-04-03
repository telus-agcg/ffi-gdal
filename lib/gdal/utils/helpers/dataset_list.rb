# frozen_string_literal: true

module GDAL
  module Utils
    module Helpers
      # A basic wrapper for C Array of dataset handlers (e.g. GDALDatasetH *pahSrcDS).
      #
      # @private
      # @note This class is intended only to be used internally in ffi-gdal. It's API may change.
      #   Do not use this class directly.
      class DatasetList
        # @return [FFI::Pointer] C pointer to the Array of dataset handlers (e.g. GDALDatasetH *pahSrcDS).
        attr_reader :c_pointer

        # @return [Array<GDAL::Dataset>] List of datasets.
        attr_reader :datasets

        # @param datasets [Array<GDAL::Dataset>] List of datasets.
        def initialize(datasets: [])
          @datasets = datasets
          @c_pointer = datasets_pointer
        end

        # @return [Integer] The number of datasets in the list.
        def count
          dataset_pointers.count
        end

        private

        def dataset_pointers
          @dataset_pointers ||= datasets.map(&:c_pointer)
        end

        def datasets_pointer
          ::FFI::MemoryPointer
            .new(:pointer, count)
            .write_array_of_pointer(dataset_pointers)
        end
      end
    end
  end
end
