# frozen_string_literal: true

require_relative "vector_translate/options"

module GDAL
  module Utils
    # Wrapper for ogr2ogr using GDALVectorTranslate C API.
    #
    # @see https://gdal.org/programs/ogr2ogr.html ogr2ogr utility documentation.
    # @see https://gdal.org/api/gdal_utils.html#_CPPv419GDALVectorTranslatePKc12GDALDatasetHiP12GDALDatasetHPK26GDALVectorTranslateOptionsPi
    #   GDALVectorTranslate C API.
    class VectorTranslate
      # Perform the ogr2ogr (GDALVectorTranslate) operation.
      #
      # @example Translate a vector dataset (for dst_dataset_path).
      #   src_dataset = OGR::DataSource.open("source.shp", "r")
      #   dataset = GDAL::Utils::VectorTranslate.perform(
      #     dst_dataset_path: "destination.geojson",
      #     src_datasets: [src_dataset]
      #   )
      #
      #   # Do something with the dataset.
      #   puts dataset.layer(0).name
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Translate a vector dataset with options (for dst_dataset_path).
      #   src_dataset = OGR::DataSource.open("source.shp", "r")
      #   dataset = GDAL::Utils::VectorTranslate.perform(
      #     dst_dataset_path: "destination.geojson",
      #     src_datasets: [src_dataset],
      #     options: GDAL::Utils::VectorTranslate::Options.new(options: ["-nlt", "MULTIPOLYGON"])
      #   )
      #
      #   # Do something with the dataset.
      #   puts dataset.layer(0).name
      #
      #   # You must close the dataset when you are done with it.
      #   dataset.close
      #   src_dataset.close
      #
      # @example Translate a vector dataset using block syntax (for dst_dataset_path).
      #   src_dataset = OGR::DataSource.open("source.shp", "r")
      #   GDAL::Utils::VectorTranslate.perform(
      #     dst_dataset_path: "destination.geojson",
      #     src_datasets: [src_dataset]
      #   ) do |dataset|
      #     # Do something with the dataset.
      #     puts dataset.layer(0).name
      #
      #     # Dataset will be closed automatically.
      #   end
      #   src_dataset.close
      #
      # @example Translate a vector dataset (for dst_dataset).
      #   src_dataset = OGR::DataSource.open("source.shp", "r")
      #   dst_dataset = OGR::DataSource.open("destination.geojson", "w")
      #
      #   GDAL::Utils::VectorTranslate.perform(dst_dataset: dst_dataset, src_datasets: [src_dataset])
      #
      #   # You must close the dataset when you are done with it.
      #   dst_dataset.close
      #   src_dataset.close
      #
      # @example Translate a vector dataset with options (for dst_dataset).
      #   src_dataset = OGR::DataSource.open("source.shp", "r")
      #   dst_dataset = OGR::DataSource.open("destination.geojson", "w")
      #
      #   GDAL::Utils::VectorTranslate.perform(
      #     dst_dataset: dst_dataset,
      #     src_datasets: [src_dataset],
      #     options: GDAL::Utils::VectorTranslate::Options.new(options: ["-nlt", "MULTIPOLYGON"])
      #   )
      #
      #   # You must close the dataset when you are done with it.
      #   dst_dataset.close
      #   src_dataset.close
      #
      # @param dst_dataset_path [String] The path to the destination dataset.
      # @param dst_dataset [OGR::DataSource] The destination dataset.
      # @param src_datasets [Array<OGR::DataSource>] The source datasets.
      # @param options [GDAL::Utils::VectorTranslate::Options] Options.
      # @yield [OGR::DataSource] The destination dataset.
      # @return [OGR::DataSource] The destination dataset (only if block is not specified; dataset must be closed).
      def self.perform(dst_dataset: nil, dst_dataset_path: nil, src_datasets: [], options: Options.new, &block)
        if dst_dataset
          for_dataset(dst_dataset: dst_dataset, src_datasets: src_datasets, options: options)
        else
          for_dataset_path(dst_dataset_path: dst_dataset_path, src_datasets: src_datasets, options: options, &block)
        end
      end

      def self.for_dataset(dst_dataset:, src_datasets: [], options: Options.new)
        result_dataset_ptr(dst_dataset: dst_dataset, src_datasets: src_datasets, options: options)

        # Return the input dataset as the output dataset (dataset is modified in place).
        dst_dataset
      end
      private_class_method :for_dataset

      def self.for_dataset_path(dst_dataset_path:, src_datasets: [], options: Options.new, &block)
        dst_dataset_ptr = result_dataset_ptr(
          dst_dataset_path: dst_dataset_path, src_datasets: src_datasets, options: options
        )

        ::OGR::DataSource.open(dst_dataset_ptr, "w", &block)
      end
      private_class_method :for_dataset_path

      def self.result_dataset_ptr(dst_dataset_path: nil, dst_dataset: nil, src_datasets: [], options: Options.new)
        src_dataset_list = ::GDAL::Utils::Helpers::DatasetList.new(datasets: src_datasets)
        result_code_ptr = ::FFI::MemoryPointer.new(:int)
        dst_dataset_ptr = ::FFI::GDAL::Utils.GDALVectorTranslate(
          dst_dataset_path,
          dst_dataset&.c_pointer,
          src_dataset_list.count,
          src_dataset_list.c_pointer,
          options.c_pointer,
          result_code_ptr
        )
        success = result_code_ptr.read_int.zero?

        raise ::GDAL::Error, "GDALVectorTranslate failed." if dst_dataset_ptr.null? || !success

        dst_dataset_ptr
      end
      private_class_method :result_dataset_ptr
    end
  end
end
