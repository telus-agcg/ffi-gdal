# frozen_string_literal: true

require_relative 'base_general_image_projection_transformer'

module GDAL
  module Transformers
    class GeneralImageProjectionTransformer < BaseGeneralImageProjectionTransformer
      # @param source_dataset [GDAL::Dataset, FFI::Pointer, nil]
      # @param destination_dataset [GDAL::Dataset, FFI::Pointer, nil]
      # @param source_wkt [String, nil]
      # @param destination_wkt [String, nil]
      # @param gcp_use_ok [Boolean]
      # @param order [Integer]
      def initialize(source_dataset, destination_dataset: nil, source_wkt: nil, destination_wkt: nil,
        gcp_use_ok: false, order: 0)
        super()

        source_ptr = GDAL::Dataset.new_pointer(source_dataset)
        dest_ptr = GDAL::Dataset.new_pointer(destination_dataset)

        pointer = FFI::GDAL::Alg.GDALCreateGenImgProjTransformer(
          source_ptr,
          source_wkt,
          dest_ptr,
          destination_wkt,
          gcp_use_ok,
          nil,
          order
        )
        raise 'Unable to create transformer' if pointer.null?

        init_pointer(pointer)
      end
    end
  end
end
