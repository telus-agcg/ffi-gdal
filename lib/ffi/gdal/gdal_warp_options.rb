require 'ffi'

module FFI
  module GDAL
    class GDALWarpOptions < FFI::Struct
      layout :warp_options, :pointer,
        :warp_memory_limit, :double,
        :resample_alg, FFI::GDAL::GDALResampleAlg,
        :working_data_type, FFI::GDAL::GDALDataType,
        :source_dataset, :GDALDatasetH,
        :destination_dataset, :GDALDatasetH,
        :band_count, :int,
        :source_bands, :pointer,
        :destination_bands, :pointer,
        :source_alpha_band, :int,
        :destination_alpha_band, :int,
        :source_no_data_real, :pointer,
        :source_no_data_imaginary, :pointer,
        :destination_no_data_real, :pointer,
        :destination_no_data_imaginary, :pointer,
        :progress, :GDALProgressFunc,
        :progress_arg, :pointer,
        :transformer, :GDALTransformerFunc,
        :transformer_arg, :pointer,
        :source_per_band_validity_mask_function, :pointer,
        :source_per_band_validity_mask_function_arg, :pointer,
        :source_validity_mask_function, :pointer,
        :source_validity_mask_function_arg, :pointer,
        :source_density_mask_function, :pointer,
        :source_density_mask_function_arg, :pointer,
        :destination_density_mask_function, :pointer,
        :destination_density_mask_function_arg, :pointer,
        :destination_validity_mask_function, :pointer,
        :destination_validity_mask_function_arg, :pointer,
        :pre_warp_chunk_processor, :pointer,
        :pre_warp_processor_arg, :pointer,
        :post_warp_chunk_processor, :pointer,
        :post_warp_processor_arg, :pointer,
        :cutline, :pointer,
        :cutline_blend_distance, :double
    end
  end
end
