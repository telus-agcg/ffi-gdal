# frozen_string_literal: true

require_relative "warp/options"

module GDAL
  module Utils
    # Wrapper for gdalwarp using GDALWarp C API.
    #
    # @see https://gdal.org/programs/gdalwarp.html gdalwarp utility documentation.
    # @see https://gdal.org/api/gdal_utils.html#_CPPv48GDALWarpPKc12GDALDatasetHiP12GDALDatasetHPK18GDALWarpAppOptionsPi
    #   GDALWarp C API.
    class Warp
      # Perform the gdalwarp (GDALWarp) operation.
      #
      # @example Warp a dataset (for dst_dataset_path).
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   options = GDAL::Utils::Warp::Options.new(options: ["-t_srs", "EPSG:3857"])
      #
      #   dataset = GDAL::Utils::Warp.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_datasets: [src_dataset],
      #     options: options
      #   )
      #
      #   # Do something with the dataset.
      #   puts dataset.raster_x_size
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Warp a dataset (for dst_dataset_path) using block syntax.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   options = GDAL::Utils::Warp::Options.new(options: ["-t_srs", "EPSG:3857"])
      #
      #   GDAL::Utils::Warp.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_datasets: src_dataset,
      #     options: options
      #   ) do |dataset|
      #     # Do something with the dataset.
      #     puts dataset.raster_x_size
      #
      #     # Dataset will be closed automatically.
      #   end
      #   src_dataset.close
      #
      # @example Warp a dataset (for dst_dataset).
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   dst_dataset = GDAL::Dataset.open("destination.tif", "w") # Dataset with other projection.
      #
      #   GDAL::Utils::Warp.perform(dst_dataset: dst_dataset, src_datasets: [src_dataset])
      #
      #   # You must close the dataset when you are done with it.
      #   dst_dataset.close
      #   src_dataset.close
      #
      # @param dst_dataset_path [String] The path to the destination dataset.
      # @param dst_dataset [GDAL::Dataset] The destination dataset.
      # @param src_datasets [Array<GDAL::Dataset>] The source datasets.
      # @param options [GDAL::Utils::Warp::Options] Options.
      # @yield [GDAL::Dataset] The destination dataset.
      # @return [GDAL::Dataset] The destination dataset (only if block is not specified; dataset must be closed).
      def self.perform(dst_dataset: nil, dst_dataset_path: nil, src_datasets: [], options: Options.new, &block)
        if dst_dataset
          for_dataset(dst_dataset: dst_dataset, src_datasets: src_datasets, options: options)
        else
          for_dataset_path(dst_dataset_path: dst_dataset_path, src_datasets: src_datasets, options: options, &block)
        end
      end

      # @param dst_dataset [GDAL::Dataset] The destination dataset.
      # @param src_datasets [Array<GDAL::Dataset>] The source datasets.
      # @param options [GDAL::Utils::Warp::Options] Options.
      # @return [GDAL::Dataset] The destination dataset (it's the same object as dst_dataset).
      def self.for_dataset(dst_dataset:, src_datasets: [], options: Options.new)
        result_dataset_ptr(dst_dataset: dst_dataset, src_datasets: src_datasets, options: options)

        # Return the input dataset as the output dataset (dataset is modified in place).
        dst_dataset
      end
      private_class_method :for_dataset

      # @param dst_dataset_path [String] The path to the destination dataset.
      # @param src_datasets [Array<GDAL::Dataset>] The source datasets.
      # @param options [GDAL::Utils::Warp::Options] Options.
      # @yield [GDAL::Dataset] The destination dataset.
      # @return [GDAL::Dataset] The destination dataset (only if block is not specified; dataset must be closed).
      def self.for_dataset_path(dst_dataset_path:, src_datasets: [], options: Options.new, &block)
        dst_dataset_ptr = result_dataset_ptr(
          dst_dataset_path: dst_dataset_path, src_datasets: src_datasets, options: options
        )

        ::GDAL::Dataset.open(dst_dataset_ptr, "w", &block)
      end
      private_class_method :for_dataset_path

      def self.result_dataset_ptr(dst_dataset_path: nil, dst_dataset: nil, src_datasets: [], options: Options.new)
        src_dataset_list = ::GDAL::Utils::Helpers::DatasetList.new(datasets: src_datasets)
        result_code_ptr = ::FFI::MemoryPointer.new(:int)
        dst_dataset_ptr = ::FFI::GDAL::Utils.GDALWarp(
          dst_dataset_path,
          dst_dataset&.c_pointer,
          src_dataset_list.count,
          src_dataset_list.c_pointer,
          options.c_pointer,
          result_code_ptr
        )
        success = result_code_ptr.read_int.zero?

        raise ::GDAL::Error, "GDALWarp failed." if dst_dataset_ptr.null? || !success

        dst_dataset_ptr
      end
      private_class_method :result_dataset_ptr
    end
  end
end
