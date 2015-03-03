require_relative '../../ffi/gdal/alg'

module GDAL
  module Transformers
    class ApproximateTransformer
      # @return [FFI::Function]
      def self.function
        FFI::GDAL::Alg.ApproxTransform
      end

      attr_reader :c_pointer

      # @param base_transformer_function [FFI::Function, Proc]
      # @param transformer_arg_ptr [FFI::Pointer]
      # @param max_error [Float] The maximum cartesian error in the "output" space
      #   that will be accepted in the linear approximation.
      def initialize(base_transformer_function, transformer_arg_ptr, max_error)
        @c_pointer = FFI::GDAL::Alg.GDALCreateApproxTransformer(
          base_transformer_function,
          transformer_arg_ptr,
          max_error)

        ObjectSpace.define_finalizer self, -> { destroy! }
      end

      def destroy!
        return unless @c_pointer

        FFI::GDAL::Alg.GDALDestroyApproxTransformer(@c_pointer)
        @c_pointer = nil
      end

      # @return [FFI::Function]
      def function
        self.class.function
      end

      # @param data [FFI::Pointer] Pointer to the data that is passed to
      #   #function.
      # @param own_flag [Boolean]
      def owns_subtransformer(data, own_flag)
        FFI::GDAL::Alg.GDALApproxTransformerOwnsSubtransformer(data, own_flag)
      end
    end
  end
end
