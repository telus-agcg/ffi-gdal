require_relative 'base_general_image_projection_transformer'

module GDAL
  module Transformers
    class GeneralImageProjectionTransformer < BaseGeneralImageProjectionTransformer
      # @param source_dataset [GDAL::Dataset, FFI::Pointer]
      # @param source_wkt [String]
      # @param destination_dataset [GDAL::Dataset, FFI::Pointer]
      # @param destination_wkt [String]
      # @return [FFI::Pointer]
      def initialize(source_dataset, source_wkt, destination_dataset, destination_wkt,
        gcp_use_ok: false, gcp_error_threshold: 0, order: 1)
        source_ptr = GDAL._pointer(GDAL::Dataset, source_dataset)
        dest_ptr = GDAL._pointer(GDAL::Dataset, destination_dataset)

        @c_pointer = FFI::GDAL::Alg.GDALCreateGenImgProjTransformer(
          source_ptr,
          source_wkt,
          dest_ptr,
          destination_wkt,
          gcp_use_ok,
          gcp_error_threshold,
          order
        )
        fail if @c_pointer.null?

        super()
      end
    end
  end
end
