# frozen_string_literal: true

require_relative 'base_general_image_projection_transformer'

module GDAL
  module Transformers
    class GeneralImageProjectionTransformer < BaseGeneralImageProjectionTransformer
      # @param source_dataset [GDAL::Dataset, FFI::Pointer]
      # @param destination_dataset [GDAL::Dataset, FFI::Pointer]
      # @param source_wkt [String]
      # @param destination_wkt [String]
      # @param gcp_use_ok [Boolean]
      # @param order [Fixnum]
      def initialize(source_dataset, destination_dataset: nil, source_wkt: nil, destination_wkt: nil,
        gcp_use_ok: false, order: 0)
        source_ptr = GDAL._pointer(GDAL::Dataset, source_dataset)
        dest_ptr = GDAL._pointer(GDAL::Dataset, destination_dataset, false)

        @c_pointer = FFI::GDAL::Alg.GDALCreateGenImgProjTransformer(
          source_ptr,
          source_wkt,
          dest_ptr,
          destination_wkt,
          gcp_use_ok,
          0.0,
          order
        )
        raise if @c_pointer.null?

        super()
      end
    end
  end
end
