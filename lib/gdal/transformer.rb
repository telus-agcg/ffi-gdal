require_relative '../ffi/gdal/alg'

module GDAL
  class Transformer
    # @return [FFI::Pointer]
    def self.create_similar_transformer(transformer_arg_ptr, source_ratio_x, source_ratio_y)
      FFI::GDAL::Alg.GDALCreateSimilarTransformer(transformer_arg_ptr, source_ratio_x, source_ratio_y)
    end

    # @param [FFI::Pointer]
    def self.destroy_transformer(transformer_arg)
      FFI::GDAL::Alg.GDALDestroyTransformer(transformer_arg)
    end
  end
end
