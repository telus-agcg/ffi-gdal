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
        warp_memory_limit: 0.0, max_error: 0.0, progress_function: nil, progress_arg: nil, **options)
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

      # @param destination_file_name [String] Path to the output dataset.
      # @param resample_algorithm [Symbol] One from FFI::GDAL::Warper::GDALResampleAlg.
      # @param destination_spatial_reference [String] WKT of the projection to
      #   be used for the destination dataset.
      # @param destination_driver [GDAL::Driver] Driver to use for the
      #   destination dataset.
      # @param creation_options [Hash] Driver-specific options to use during
      #   creation.
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
      def create_and_reproject_image(destination_file_name, resample_algorithm, destination_spatial_reference,
        destination_driver, creation_options: {},
                            warp_memory_limit: 0.0,
                            max_error: 0.0,
                            progress_function: nil,
                            progress_arg: nil,
                            **warp_options)
        creation_options_ptr = GDAL::Options.pointer(creation_options)
        warp_options_ptr = GDAL::Options.pointer(warp_options)

        FFI::GDAL::Warper.GDALCreateAndReprojectImage(
          @c_pointer,                           # hSrcDS
          nil,                                  # pszSrcWKT
          destination_file_name,                # pszDstFilename
          destination_spatial_reference,        # pszDstWKT
          destination_driver.c_pointer,         # hDstDriver
          creation_options_ptr,                 # papszCreateOptions
          resample_algorithm,                   # eResampleAlg
          warp_memory_limit,                    # dfWarpMemoryLimit
          max_error,                            # dfMaxError
          progress_function,                    # pfnProgress
          progress_arg,                         # pProgressArg
          warp_options_ptr                      # psOptions
        )
      end
    end
  end
end
