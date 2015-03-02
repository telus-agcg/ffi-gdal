require 'uri'
require_relative '../ffi/gdal'
require_relative '../ffi/cpl/string'
require_relative '../ogr/spatial_reference'
require_relative 'driver'
require_relative 'geo_transform'
require_relative 'raster_band'
require_relative 'exceptions'
require_relative 'major_object'
require_relative 'dataset_mixins/extensions'
require_relative 'dataset_mixins/matching'
require_relative 'options'

module GDAL
  # A set of associated raster bands and info common to them all.  It's also
  # responsible for the georeferencing transform and coordinate system
  # definition of all bands.
  class Dataset
    include MajorObject
    include DatasetMixins::Extensions
    include DatasetMixins::Matching
    include GDAL::Logger

    ACCESS_FLAGS = {
      'r' => :GA_ReadOnly,
      'w' => :GA_Update
    }

    # @param path [String] Path to the file that contains the dataset.  Can be
    #   a local file or a URL.
    # @param access_flag [String] 'r' or 'w'.
    def self.open(path, access_flag)
      new(path, access_flag)
    end

    #---------------------------------------------------------------------------
    # Instance methods
    #---------------------------------------------------------------------------

    # @param path_or_pointer [String, FFI::Pointer] Path to the file that
    #   contains the dataset or a pointer to the dataset. If it's a path, it can
    #   be a local file or a URL.
    # @param access_flag [String] 'r' or 'w'.
    def initialize(path_or_pointer, access_flag)
      @dataset_pointer =
        if path_or_pointer.is_a? String
          file_path = begin
            uri = URI.parse(path_or_pointer)
            uri.scheme.nil? ? ::File.expand_path(path_or_pointer) : path_or_pointer
          rescue URI::InvalidURIError
            path_or_pointer
          end

          FFI::GDAL.GDALOpen(file_path, ACCESS_FLAGS[access_flag])
        else
          path_or_pointer
        end

      fail OpenFailure.new(path_or_pointer) if @dataset_pointer.null?
      ObjectSpace.define_finalizer self, -> { close }
    end

    # @return [FFI::Pointer] Pointer to the GDALDatasetH that's represented by
    # this Ruby object.
    def c_pointer
      @dataset_pointer
    end

    # Close the dataset.
    def close
      return unless @dataset_pointer

      FFI::GDAL.GDALClose(@dataset_pointer)
      @dataset_pointer = nil
    end

    # @return [Symbol]
    def access_flag
      return nil if null?

      flag = FFI::GDAL.GDALGetAccess(@dataset_pointer)

      FFI::GDAL::Access[flag]
    end

    # @return [GDAL::Driver] The driver to be used for working with this
    #   dataset.
    def driver
      driver_ptr = FFI::GDAL.GDALGetDatasetDriver(@dataset_pointer)

      Driver.new(driver_ptr)
    end

    # Fetches all files that form the dataset.
    # @return [Array<String>]
    def file_list
      list_pointer = FFI::GDAL.GDALGetFileList(@dataset_pointer)
      return [] if list_pointer.null?
      file_list = list_pointer.get_array_of_string(0)
      FFI::CPL::String.CSLDestroy(list_pointer)

      file_list
    end

    # Flushes all write-cached data to disk.
    def flush_cache
      FFI::GDAL.GDALFlushCache(@dataset_pointer)
    end

    # @return [Fixnum]
    def raster_x_size
      return nil if null?

      FFI::GDAL.GDALGetRasterXSize(@dataset_pointer)
    end

    # @return [Fixnum]
    def raster_y_size
      return nil if null?

      FFI::GDAL.GDALGetRasterYSize(@dataset_pointer)
    end

    # @return [Fixnum]
    def raster_count
      return 0 if null?

      FFI::GDAL.GDALGetRasterCount(@dataset_pointer)
    end

    # @param raster_index [Fixnum]
    # @return [GDAL::RasterBand]
    def raster_band(raster_index)
      @raster_bands ||= Array.new(raster_count)
      zero_index = raster_index - 1

      if @raster_bands[zero_index] && !@raster_bands[zero_index].null?
        return @raster_bands[zero_index]
      end

      raster_band_ptr = FFI::GDAL.GDALGetRasterBand(@dataset_pointer, raster_index)
      @raster_bands[zero_index] = GDAL::RasterBand.new(raster_band_ptr)
      @raster_bands.compact!

      @raster_bands[zero_index]
    end

    # @param type [FFI::GDAL::DataType]
    # @param options [Hash]
    # @return [GDAL::RasterBand, nil]
    def add_band(type, **options)
      options_ptr = GDAL::Options.pointer(options)
      FFI::GDAL.GDALAddBand(@dataset_pointer, type, options_ptr)

      raster_band(raster_count)
    end

    # Adds a mask band to the dataset.
    #
    # @param flags [Fixnum] Any of of the GDAL::RasterBand flags.
    # @return [Boolean]
    def create_mask_band(flags)
      !!FFI::GDAL.GDALCreateDatasetMaskBand(@dataset_pointer, flags)
    end

    # @return [String]
    def projection
      FFI::GDAL.GDALGetProjectionRef(@dataset_pointer)
    end

    # @param new_projection [String]
    # @return [Boolean]
    def projection=(new_projection)
      !!FFI::GDAL.GDALSetProjection(@dataset_pointer, new_projection)
    end

    # @return [GDAL::GeoTransform]
    def geo_transform
      geo_transform_pointer = FFI::MemoryPointer.new(:double, 6)
      FFI::GDAL.GDALGetGeoTransform(@dataset_pointer, geo_transform_pointer)

      GeoTransform.new(geo_transform_pointer)
    end

    # @param new_transform [GDAL::GeoTransform]
    # @return [GDAL::GeoTransform]
    def geo_transform=(new_transform)
      new_pointer = FFI::Pointer.new(new_transform.c_pointer)
      FFI::GDAL.GDALSetGeoTransform(@dataset_pointer, new_pointer)

      GeoTransform.new(new_pointer)
    end

    # @return [Fixnum]
    def gcp_count
      return 0 if null?

      FFI::GDAL.GDALGetGCPCount(@dataset_pointer)
    end

    # @return [String]
    def gcp_projection
      return '' if null?

      FFI::GDAL.GDALGetGCPProjection(@dataset_pointer)
    end

    # @return [FFI::GDAL::GCP]
    def gcps
      return FFI::GDAL::GCP.new if null?

      gcp_array_pointer = FFI::GDAL.GDALGetGCPs(@dataset_pointer)

      if gcp_array_pointer.null?
        FFI::GDAL::GCP.new
      else
        FFI::GDAL::GCP.new(gcp_array_pointer)
      end
    end

    # @return [Fixnum]
    def layer_count
      if GDAL._supported?(:GDALDatasetGetLayerCount)
        FFI::GDAL.GDALDatasetGetLayerCount(@dataset_pointer)
      end
    end

    # @param resampling [String, Symbol] One of:
    #   * :nearest
    #   * :gauss
    #   * :cubic
    #   * :average
    #   * :mode
    #   * :average_magphase
    #   * :none
    # @param overview_levels [Array<Fixnum>] The list of overview decimation
    #   factors to build.
    # @param band_numbers [Array<Fixnum>] The numbers of the bands to build
    #   overviews from.
    def build_overviews(resampling, overview_levels, band_numbers = nil, &progress)
      resampling_string = if resampling.is_a? String
                            resampling.upcase
                          elsif resampling.is_a? Symbol
                            resampling.to_s.upcase
                          end

      overview_levels_ptr = FFI::MemoryPointer.new(:int, overview_levels.size)
      overview_levels_ptr.write_array_of_int(overview_levels)

      if band_numbers
        band_count = band_numbers.size
        band_numbers_ptr = FFI::MemoryPointer.new(:int, band_count)
        band_numbers_ptr.write_array_of_int(band_numbers)
      else
        band_numbers_ptr = nil
        band_count = nil
      end

      !!FFI::GDAL.GDALBuildOverviews(@dataset_pointer,
        resampling_string,
        overview_levels.size,
        overview_levels_ptr,
        band_count,
        band_numbers_ptr,
        progress,
        nil
      )
    end

    # @param access_flag [String] 'r' or 'w'
    # @param data_ptr [FFI::MemoryPointer] The pointer to the data to write to
    #   the dataset.
    # @param x_size [Fixnum] If not given, uses #raster_x_size.
    # @param y_size [Fixnum] If not given, uses #raster_y_size.
    # @param data_type [FFI::GDAL::DataType]
    # @param band_count [Fixnum] The number of bands to create in the raster.
    # @param pixel_space
    def raster_io(access_flag, data_ptr,
                  x_size: nil,
                  y_size: nil,
                  x_offset: 0,
                  y_offset: 0,
                  data_type: :GDT_Byte,
                  band_count: 1,
                  pixel_space: 0,
                  line_space: 0,
                  band_space: 0
                  )

      x_size ||= raster_x_size
      y_size ||= raster_y_size

      gdal_access_flag =
        case access_flag
        when 'r' then :GF_Read
        when 'w' then :GF_Write
        else fail "Invalid access flag: #{access_flag}"
        end

      x_buffer_size = x_size
      y_buffer_size = y_size

      !!FFI::GDAL::GDALDatasetRasterIO(
        @dataset_pointer,                     # hDS
        gdal_access_flag,                     # eRWFlag
        x_offset,                             # nXOff
        y_offset,                             # nYOff
        x_size,                               # nXSize
        y_size,                               # nYSize
        data_ptr,                             # pData
        x_buffer_size,                        # nBufXSize
        y_buffer_size,                        # nBufYSize
        data_type,                            # eBufType
        band_count,                           # nBandCount
        nil,                                  # panBandMap (WTH is this?)
        pixel_space,                          # nPixelSpace
        line_space,                           # nLineSpace
        band_space                            # nBandSpace
      )
    end

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

    def suggested_warp_output(transformer, transform_arg)
      geo_transform = GDAL::GeoTransform.new
      pixels_ptr = FFI::MemoryPointer.new(:int)
      lines_ptr = FFI::MemoryPointer.new(:int)

      FFI::GDAL::Alg.GDALSuggestedWarpOutput(
        @dataset_pointer,
        transformer,
        transform_arg,
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
