# frozen_string_literal: true

require_relative "info/options"

module GDAL
  module Utils
    # Wrapper for gdalinfo using GDALInfo C API.
    #
    # @see https://gdal.org/programs/gdalinfo.html gdalinfo utility documentation.
    # @see https://gdal.org/api/gdal_utils.html#_CPPv48GDALInfo12GDALDatasetHPK15GDALInfoOptions GDALInfo C API.
    class Info
      # Perform the gdalinfo (GDALInfo) operation.
      #
      # @example Get info for a dataset.
      #   dataset = GDAL::Dataset.open("my.tif", "r")
      #   info = GDAL::Utils::Info.perform(dataset: dataset)
      #   dataset.close
      #
      # @example Get info for a dataset with options.
      #   dataset = GDAL::Dataset.open("my.tif", "r")
      #   info = GDAL::Utils::Info.perform(
      #     dataset: dataset,
      #     options: GDAL::Utils::Info::Options.new(options: ["-json", "-mdd", "all"])
      #   )
      #   dataset.close
      #
      # @param dataset [GDAL::Dataset] The dataset to get info for.
      # @param options [GDAL::Utils::Info::Options] Options.
      # @return [String] The info string.
      def self.perform(dataset:, options: Options.new)
        string, str_pointer = ::FFI::GDAL::Utils.GDALInfo(dataset.c_pointer, options.c_pointer)

        string
      ensure
        # Returned string pointer must be freed with CPLFree().
        ::FFI::CPL::VSI.VSIFree(str_pointer)
      end
    end
  end
end
