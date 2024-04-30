# frozen_string_literal: true

require_relative "dem/options"

module GDAL
  module Utils
    # Wrapper for gdaldem using GDALDEMProcessing C API.
    #
    # @see https://gdal.org/programs/gdaldem.html gdaldem utility documentation.
    # @see https://gdal.org/api/gdal_utils.html#_CPPv417GDALDEMProcessingPKc12GDALDatasetHPKcPKcPK24GDALDEMProcessingOptionsPi
    #   GDALDEMProcessing C API.
    class DEM
      # Perform the gdaldem (GDALDEMProcessing) operation.
      #
      # @example Create a raster dataset.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #
      #   dataset = GDAL::Utils::DEM.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_dataset: src_dataset,
      #     processing: "hillshade"
      #   )
      #
      #   # Do something with the dataset.
      #   puts dataset.raster_x_size
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Create a raster dataset for color-relief.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #
      #   dataset = GDAL::Utils::DEM.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_dataset: src_dataset,
      #     processing: "color-relief",
      #     color_filename: "color.txt"
      #   )
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
      #   options = GDAL::Utils::DEM::Options.new(options: ["-of", "GTiff", "-co", "TILED=YES"])
      #
      #   dataset = GDAL::Utils::DEM.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_dataset: src_dataset,
      #     processing: "hillshade",
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
      # @example Create a raster dataset using block syntax.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #
      #   GDAL::Utils::DEM.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_dataset: src_dataset,
      #     processing: "hillshade"
      #   ) do |dataset|
      #     # Do something with the dataset.
      #     puts dataset.raster_x_size
      #
      #     # Dataset will be closed automatically.
      #   end
      #   src_dataset.close
      #
      # @param dst_dataset_path [String] The path to the destination dataset.
      # @param src_dataset [OGR::DataSource] The source dataset.
      # @param processing [String] The processing type
      #   (one of "hillshade", "slope", "aspect", "color-relief", "TRI", "TPI", "Roughness").
      # @param color_filename [String] color file (mandatory for "color-relief" processing, should be NULL otherwise).
      # @param options [GDAL::Utils::DEM::Options] Options.
      # @yield [GDAL::Dataset] The destination dataset.
      # @return [GDAL::Dataset] The destination dataset (only if block is not specified; dataset must be closed).
      # @raise [GDAL::Error] If the operation fails.
      def self.perform(dst_dataset_path:, src_dataset:, processing:, color_filename: nil, options: Options.new, &block)
        result_code_ptr = ::FFI::MemoryPointer.new(:int)
        dst_dataset_ptr = ::FFI::GDAL::Utils.GDALDEMProcessing(
          dst_dataset_path,
          src_dataset.c_pointer,
          processing,
          color_filename,
          options.c_pointer,
          result_code_ptr
        )
        success = result_code_ptr.read_int.zero?

        raise ::GDAL::Error, "GDALDEMProcessing failed." if dst_dataset_ptr.null? || !success

        ::GDAL::Dataset.open(dst_dataset_ptr, "w", &block)
      end
    end
  end
end
