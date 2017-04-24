# frozen_string_literal: true

module GDAL
  module Transformers
    class BaseGeneralImageProjectionTransformer
      # @return [FFI::Function]
      def self.function
        FFI::GDAL::Alg::GenImgProjTransform
      end

      attr_reader :c_pointer

      def destroy!
        return unless @c_pointer

        FFI::GDAL::Alg.GDALDestroyGenImgProjTransformer(@c_pointer)
        @c_pointer = nil
      end

      # @return [FFI::Function]
      def function
        self.class.function
      end

      # Normally the destination geotransform is extracted from the destination
      # file by the transformer and stored in internal private info. However,
      # sometimes it is inconvenient to have an output file handle with
      # appropriate geotransform information when creating the transformation.
      # For these cases, this function can be used to apply the destination
      # geotransform.
      #
      # @param [FFI::Pointer, GDAL::GeoTransform] geo_transform
      def destination_geo_transform=(geo_transform)
        geo_transform_ptr = GDAL._pointer(GDAL::GeoTransform, geo_transform)

        FFI::GDAL::Alg.GDALSetGenImgProjTransformerDstGeoTransform(
          @c_pointer, geo_transform_ptr
        )
      end
    end
  end
end
