module GDAL
  module DatasetMixins
    module AlgorithmMethods

      # Rasterizes the geometric objects +geometries+ into this raster dataset.
      # +transformer+ can be nil as long as the +geometries+ are within the
      # georeferenced coordinates of this raster's dataset.
      #
      # @param band_numbers [Array<Fixnum>, Fixnum]
      # @param geometries [Array<OGR::Geometry>, OGR::Geometry]
      # @param burn_values [Array<Float>, Float]
      # @param transformer [Proc]
      # @param options [Hash]
      # @option options all_touched [Boolean]  If +true+, sets all pixels touched
      #   by the line or polygons, not just those whose center is within the
      #   polygon or that are selected by Brezenham's line algorithm.  Defaults to
      #   +false+.
      # @option options burn_value_from ["Z"] Use the Z values of the geometries.
      # @option @options merge_alg [String] "REPLACE" or "ADD".  REPLACE results
      #   in overwriting of value, while ADD adds the new value to the existing
      #   raster, suitable for heatmaps for instance.
      def rasterize_geometries!(band_numbers, geometries, burn_values,
        transformer: nil, transform_arg: nil, **options, &progress_block)

        if geo_transform.nil? && gcp_count.zero?
          fail "Can't rasterize geometries--no geo_transform or GCPs have been defined on the dataset."
        end

        gdal_options = GDAL::Options.pointer(options)
        band_numbers = band_numbers.is_a?(Array) ? band_numbers : [band_numbers]
        geometries = geometries.is_a?(Array) ? geometries : [geometries]
        burn_values = burn_values.is_a?(Array) ? burn_values : [burn_values]

        band_numbers_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.size)
        band_numbers_ptr.write_array_of_int(band_numbers)

        geometries_ptr = FFI::MemoryPointer.new(:pointer, geometries.size)
        geometries_ptr.write_array_of_pointer(geometries.map(&:c_pointer))

        burn_values_ptr = FFI::MemoryPointer.new(:pointer, burn_values.size)
        burn_values_ptr.write_array_of_double(burn_values)

        !!FFI::GDAL.GDALRasterizeGeometries(@dataset_pointer,
          band_numbers.size,
          band_numbers_ptr,
          geometries.size,
          geometries_ptr,
          transformer,
          transform_arg,
          burn_values_ptr,
          gdal_options,
          progress_block,
          nil)
      end

      # @param band_numbers [Array<Fixnum>, Fixnum]
      # @param layers [Array<OGR::Layer>, OGR::Layer]
      # @param burn_values [Array<Float>, Float]
      # @param transformer [Proc]
      # @param options [Hash]
      # @option options attribute [String] An attribute field on features to be
      #   used for a burn-in value, which will be burned into all output bands.
      # @option options chunkysize [Fixnum] The height in lines of the chunk to
      #   operate on.
      # @option options all_touched [Boolean]  If +true+, sets all pixels touched
      #   by the line or polygons, not just those whose center is within the
      #   polygon or that are selected by Brezenham's line algorithm.  Defaults to
      #   +false+.
      # @option options burn_value_from ["Z"] Use the Z values of the geometries.
      # @option @options merge_alg [String] "REPLACE" or "ADD".  REPLACE results
      #   in overwriting of value, while ADD adds the new value to the existing
      #   raster, suitable for heatmaps for instance.
      def rasterize_layers!(band_numbers, layers, burn_values,
        transformer: nil, transform_arg: nil, **options, &progress_block)
        gdal_options = GDAL::Options.pointer(options)
        band_numbers = band_numbers.is_a?(Array) ? band_numbers : [band_numbers]
        log "band numbers: #{band_numbers}"

        layers = layers.is_a?(Array) ? layers : [layers]
        log "layers: #{layers}"

        burn_values = burn_values.is_a?(Array) ? burn_values : [burn_values]
        log "burn values: #{burn_values}"

        band_numbers_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.size)
        band_numbers_ptr.write_array_of_int(band_numbers)
        log "band numbers ptr null? #{band_numbers_ptr.null?}"

        layers_ptr = FFI::MemoryPointer.new(:pointer, layers.size)
        layers_ptr.write_array_of_pointer(layers.map(&:c_pointer))
        log "layers ptr null? #{layers_ptr.null?}"

        burn_values_ptr = FFI::MemoryPointer.new(:pointer, burn_values.size)
        burn_values_ptr.write_array_of_double(burn_values)
        log "burn value ptr null? #{burn_values_ptr.null?}"

        !!FFI::GDAL.GDALRasterizeLayers(@dataset_pointer,     # hDS
          band_numbers.size,                                # nBandCount
          band_numbers_ptr,                                 # panBandList
          layers.size,                                      # nLayerCount
          layers_ptr,                                       # pahLayers
          transformer,                                      # pfnTransformer
          transform_arg,                                    # pTransformerArg
          burn_values_ptr,                                  # padfLayerBurnValues
          gdal_options,                                     # papszOptions
          progress_block,                                   # pfnProgress
          nil)                                              # pProgressArg
      end

      # @param destination_file [String]
      # @param driver [String] Name of the driver to use for outputing the new
      #   image.
      # @param transformer [Proc]
      # @param trasnformer_arg_ptr [FFI::Pointer]
      # @param band_numbers [Fixnum, Array<Fixnum>] Raster bands to include in the
      #   warping.  0 indicates all bands.
      # @param options [Hash]
      # @option options [String] init Indicates that the output dataset should be
      #   initialized to the given value in any area where valid data isn't
      #   written.  In form: "v[,v...]"
      # @return [GDAL::Dataset, nil] The new dataset or nil if the warping failed.
      def simple_image_warp(destination_file, driver, transformer,
        transformer_arg_ptr, band_numbers = 0, **options, &progress)
        options_ptr = GDAL::Options.pointer(options)
        driver = GDAL::Driver.by_name(driver)
        destination_dataset_ptr = driver.open(destination_file, 'w')

        band_numbers = band_numbers.is_a?(Array) ? band_numbers : [band_numbers]
        log "band numbers: #{band_numbers}"

        bands_ptr = FFI::MemoryPointer.new(:pointer, band_numbers.size)
        bands_ptr.write_array_of_int(band_numbers)
        log "band numbers ptr null? #{bands_ptr.null?}"

        success = FFI::GDAL.GDALSimpleImageWarp(@dataset_pointer,
          destination_dataset_ptr,
          band_numbers.size,
          bands_ptr,
          transformer,
          transformer_arg_ptr,
          progress,
          nil,
          options_ptr)

        success ? GDAL::Dataset.new(destination_dataset_ptr) : nil
      end

      # def suggested_warp_output(transformer, transform_arg)
      def suggested_warp_output(transformer)
        geo_transform = GDAL::GeoTransform.new
        pixels_ptr = FFI::MemoryPointer.new(:int)
        lines_ptr = FFI::MemoryPointer.new(:int)
        FFI::GDAL::Alg.GDALSuggestedWarpOutput(
          @dataset_pointer,
          transformer.function,
          transformer.c_pointer,
          geo_transform.c_pointer,
          pixels_ptr,
          lines_ptr)

        {
          geo_transform: geo_transform,
          lines: lines_ptr.read_int,
          pixels: pixels_ptr.read_int
        }
      end
    end
  end
end
