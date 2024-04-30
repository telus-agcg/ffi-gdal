# frozen_string_literal: true

require_relative "grid/options"

module GDAL
  module Utils
    # Wrapper for gdal_grid using GDALGrid C API.
    #
    # @see https://gdal.org/programs/gdal_grid.html gdal_grid utility documentation.
    # @see https://gdal.org/api/gdal_utils.html#_CPPv48GDALGridPKc12GDALDatasetHPK15GDALGridOptionsPi GDALGrid C API.
    class Grid
      # Perform the gdal_grid (GDALGrid) operation.
      #
      # @example Create a raster dataset.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   dataset = GDAL::Utils::Grid.perform(dst_dataset_path: "destination.tif", src_dataset: src_dataset)
      #
      #   # Do something with the dataset.
      #   puts dataset.raster_x_size
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Create a raster dataset with options.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   dataset = GDAL::Utils::Grid.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_dataset: src_dataset,
      #     options: GDAL::Utils::Grid::Options.new(options: ["-of", "GTiff", "-co", "COMPRESS=DEFLATE"])
      #   )
      #
      #   # Do something with the dataset.
      #   puts dataset.raster_x_size
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Create a raster dataset using block syntax.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   GDAL::Utils::Grid.perform(dst_dataset_path: "destination.tif", src_dataset: src_dataset) do |dataset|
      #     # Do something with the dataset.
      #     puts dataset.raster_x_size
      #
      #     # Dataset will be closed automatically.
      #   end
      #   src_dataset.close
      #
      # @param dst_dataset_path [String] The path to the destination dataset.
      # @param src_dataset [OGR::DataSource] The source dataset.
      # @param options [GDAL::Utils::Grid::Options] Options.
      # @yield [GDAL::Dataset] The destination dataset.
      # @return [GDAL::Dataset] The destination dataset (only if block is not specified; dataset must be closed).
      # @raise [GDAL::Error] If the operation fails.
      def self.perform(dst_dataset_path:, src_dataset:, options: Options.new, &block)
        result_code_ptr = ::FFI::MemoryPointer.new(:int)
        dst_dataset_ptr = ::FFI::GDAL::Utils.GDALGrid(
          dst_dataset_path,
          src_dataset.c_pointer,
          options.c_pointer,
          result_code_ptr
        )
        success = result_code_ptr.read_int.zero?

        raise ::GDAL::Error, "GDALGrid failed." if dst_dataset_ptr.null? || !success

        ::GDAL::Dataset.open(dst_dataset_ptr, "w", &block)
      end
    end
  end
end
