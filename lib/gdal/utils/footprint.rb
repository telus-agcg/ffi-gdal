# frozen_string_literal: true

require_relative "footprint/options"

module GDAL
  module Utils
    # Wrapper for gdal_footprint using GDALFootprint C API.
    #
    # @see https://gdal.org/programs/gdal_footprint.html gdal_footprint utility documentation.
    # @see https://gdal.org/api/gdal_utils.html#_CPPv413GDALFootprintPKc12GDALDatasetH12GDALDatasetHPK20GDALFootprintOptionsPi
    #   GDALFootprint C API.
    class Footprint
      # Perform the gdal_footprint (GDALFootprint) operation.
      #
      # @example Footprint a dataset with options (for dst_dataset_path).
      #  src_dataset = GDAL::Dataset.open("source.tif", "r")
      #  options = GDAL::Utils::Footprint::Options.new(options: ["-srcnodata", "0", "-t_srs", "EPSG:4326"])
      #
      #  dataset = GDAL::Utils::Footprint.perform(
      #    dst_dataset_path: "destination.tif",
      #    src_dataset: src_dataset,
      #    options: options
      #  )
      #
      #  # Do something with the dataset.
      #  puts dataset.layer_count
      #
      #  # You must close the dataset when you are done with it.
      #  dataset.close
      #  src_dataset.close
      #
      # @param dst_dataset_path [String] The path to the destination dataset.
      # @param src_dataset [GDAL::Dataset] The source dataset.
      # @param options [GDAL::Utils::Footprint::Options] The options for the operation.
      # @param block [Proc] The block to be executed with the dataset.
      # @yield [GDAL::Dataset] The resulting dataset.
      # @return [GDAL::Dataset] The resulting dataset (only if block is not specified).
      def self.perform(src_dataset:, dst_dataset_path:, options: Options.new, &block)
        dst_dataset_ptr = result_dataset_ptr(
          dst_dataset_path: dst_dataset_path, src_dataset: src_dataset, options: options
        )

        GDAL::Dataset.release(dst_dataset_ptr) # Release the dataset pointer to save Datasource content.

        ::OGR::DataSource.open(dst_dataset_path, "w", &block)
      end

      def self.result_dataset_ptr(src_dataset:, dst_dataset_path:, options: Options.new)
        result_code_ptr = ::FFI::MemoryPointer.new(:int)
        dst_dataset_ptr = ::FFI::GDAL::Utils.GDALFootprint(
          dst_dataset_path,
          nil, # pszDest
          src_dataset.c_pointer,
          options.c_pointer,
          result_code_ptr
        )
        success = result_code_ptr.read_int.zero?

        raise ::GDAL::Error, "GDALFootprint failed." if dst_dataset_ptr.null? || !success

        dst_dataset_ptr
      end
      private_class_method :result_dataset_ptr
    end
  end
end
