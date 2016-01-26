module GDAL
  module DatasetMixins
    # Methods used for warping; most taken from gdalwarper.h.
    module WarpMethods
      # @param destination_dataset [GDAL::Dataset]
      # @param resample_algorithm [Symbol] One from FFI::GDAL::Warper::GDALResampleAlg.
      # @param destination_spatial_reference [OGR::SpatialReference]
      # @param warp_memory_limit [Float] The amount of memory (in bytes) the API
      #   is allowed to use for caching. This is in addition to the amount of
      #   memory already allocated for caching (using GDALSetCacheMax). 0.0 uses
      #   default settings.
      # @param max_error [Float] Maximum error, measured in input pixels that is
      #   allowed in approximating the transformation. Defaults to 0.0.
      # @param progress_function [Proc, FFI::GDAL::GDAL::GDALProgressFunc] A
      #   callback for reporting progress.
      # @param progress_arg [FFI::Pointer] Argument to be passed to
      #   +progress_function+.
      # @param options [Hash] Warp options, normally empty.
      def reproject_image(destination_dataset, resample_algorithm, destination_spatial_reference: nil,
        warp_memory_limit: 0.0,
        max_error: 0.0,
        progress_function: nil,
        progress_arg: nil,
        **options)
        destination_spatial_reference_wkt = if destination_spatial_reference
                                              destination_spatial_reference.to_wkt
                                            end

        options_ptr = GDAL::Options.pointer(options)

        FFI::GDAL::Warper.GDALReprojectImage(
          @c_pointer,                           # hSrcDS
          nil,                                  # pszSrcWKT
          destination_dataset.c_pointer,        # hDstDS
          destination_spatial_reference_wkt,    # pszDstWKT
          resample_algorithm,                   # eResampleAlg
          warp_memory_limit,                    # dfWarpMemoryLimit
          max_error,                            # dfMaxError
          progress_function,                    # pfnProgress
          progress_arg,                         # pProgressArg
          options_ptr                           # psOptions
        )
      end
    end
  end
end
