# frozen_string_literal: true

require_relative "translate/options"

module GDAL
  module Utils
    # Wrapper for gdal_translate using GDALTranslate C API.
    #
    # @see https://gdal.org/programs/gdal_translate.html gdal_translate utility documentation.
    # @see https://gdal.org/api/gdal_utils.html#gdal__utils_8h_1a1cf5b30de14ccaf847ae7a77bb546b28 GDALTranslate C API.
    class Translate
      # Perform the gdal_translate (GDALTranslate) operation.
      #
      # @example Translate a dataset.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   dataset = GDAL::Utils::Translate.perform(dst_dataset_path: "destination.tif", src_dataset: src_dataset)
      #
      #   # Do something with the dataset.
      #   puts dataset.raster_x_size
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Translate a dataset with options.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   dataset = GDAL::Utils::Translate.perform(
      #     dst_dataset_path: "destination.tif",
      #     src_dataset: src_dataset,
      #     options: GDAL::Utils::Translate::Options.new(options: ["-of", "GTiff", "-co", "COMPRESS=DEFLATE"])
      #   )
      #
      #   # Do something with the dataset.
      #   puts dataset.raster_x_size
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Translate a dataset using block syntax.
      #   src_dataset = GDAL::Dataset.open("source.tif", "r")
      #   GDAL::Utils::Translate.perform(dst_dataset_path: "destination.tif", src_dataset: src_dataset) do |dataset|
      #     # Do something with the dataset.
      #     puts dataset.raster_x_size
      #
      #     # Dataset will be closed automatically.
      #   end
      #   src_dataset.close
      #
      # @param dst_dataset_path [String] The path to the destination dataset.
      # @param src_dataset [GDAL::Dataset] The source dataset.
      # @param options [GDAL::Utils::Translate::Options] Options.
      # @yield [GDAL::Dataset] The destination dataset.
      # @return [GDAL::Dataset] The destination dataset (only if block is not specified; dataset must be closed).
      # @raise [GDAL::Error] If the operation fails.
      def self.perform(dst_dataset_path:, src_dataset:, options: Options.new, &block)
        result_code_ptr = ::FFI::MemoryPointer.new(:int)
        dst_dataset_ptr = ::FFI::GDAL::Utils.GDALTranslate(
          dst_dataset_path,
          src_dataset.c_pointer,
          options.c_pointer,
          result_code_ptr
        )
        success = result_code_ptr.read_int.zero?

        raise ::GDAL::Error, "GDALTranslate failed." if dst_dataset_ptr.null? || !success

        ::GDAL::Dataset.open(dst_dataset_ptr, "w", &block)
      end
    end
  end
end
