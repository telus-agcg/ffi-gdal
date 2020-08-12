# frozen_string_literal: true

module GDAL
  module Transformers
    class ReprojectionTransformer
      # @return [FFI::Pointer]
      def self.function
        FFI::GDAL::Alg::ReprojectionTransform
      end

      # @return [FFI::Pointer] C pointer to the C reprojection transformer.
      attr_reader :c_pointer

      # @param source_wkt [String]
      # @param destination_wkt [String]
      def initialize(source_wkt, destination_wkt)
        pointer = FFI::GDAL::Alg.GDALCreateReprojectionTransformer(source_wkt, destination_wkt)

        @c_pointer = FFI::AutoPointer.new(pointer, lambda do |ptr|
          FFI::GDAL::Alg.GDALDestroyReprojectionTransformer(ptr) unless ptr.nil? || ptr.null?
        end)
      end

      def destroy!
        return unless @c_pointer

        FFI::GDAL::Alg.GDALDestroyReprojectionTransformer(@c_pointer)
        @c_pointer = nil
      end

      # @return [FFI::Pointer]
      def function
        self.class.function
      end
    end
  end
end
