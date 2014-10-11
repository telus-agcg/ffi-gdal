require 'uri'
require_relative '../ffi/gdal'
require_relative 'driver'
require_relative 'geo_transform'
require_relative 'raster_band'
require_relative 'exceptions'
require_relative 'major_object'
require_relative 'dataset_extensions'
require_relative '../ogr/spatial_reference'


module GDAL

  # A set of associated raster bands and info common to them all.  It's also
  # responsible for the georeferencing transform and coordinate system
  # definition of all bands.
  class Dataset
    include MajorObject
    include DatasetExtensions
    include GDAL::Logger

    ACCESS_FLAGS = {
      'r' => :GA_ReadOnly,
      'w' => :GA_Update
    }

    # @param path [String] Path to the file that contains the dataset.  Can be
    #   a local file or a URL.
    # @param access_flag [String] 'r' or 'w'.
    def self.open(path, access_flag)
      uri = URI.parse(path)
      file_path = uri.scheme.nil? ? ::File.expand_path(path) : path

      pointer = FFI::GDAL.GDALOpen(file_path, ACCESS_FLAGS[access_flag])
      raise OpenFailure.new(file_path) if pointer.null?

      new(pointer)
    end

    #---------------------------------------------------------------------------
    # Instance methods
    #---------------------------------------------------------------------------

    # @param dataset_pointer [FFI::Pointer] Pointer to the dataset in memory.
    def initialize(dataset_pointer)
      @dataset_pointer = dataset_pointer
      @last_known_file_list = []
      @open = true
      close_me = -> { self.close }
      ObjectSpace.define_finalizer self, close_me
    end

    # @return [FFI::Pointer] Pointer to the GDALDatasetH that's represented by
    # this Ruby object.
    def c_pointer
      @dataset_pointer
    end

    # Close the dataset.
    def close
      @last_known_file_list = file_list
      FFI::GDAL.GDALClose(@dataset_pointer)
      @open = false
    end

    # Tries to reopen the dataset using the first item from #file_list before
    # the dataset was closed.
    #
    # @param access_flag [String]
    # @return [Boolean]
    def reopen(access_flag)
      @dataset_pointer = FFI::GDAL.GDALOpen(@last_known_file_list.first, access_flag)

      @open = true unless @dataset_pointer.null?
    end

    # @return [Boolean]
    def open?
      @open
    end

    # @return [Symbol]
    def access_flag
      return nil if null?

      flag = FFI::GDAL.GDALGetAccess(@dataset_pointer)

      FFI::GDAL.GDALAccess[flag]
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
      list_pointer = FFI::GDAL.GDALGetFileList(c_pointer)
      file_list = list_pointer.get_array_of_string(0)
      FFI::GDAL.CSLDestroy(list_pointer)

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

    # @param type [FFI::GDAL::GDALDataType]
    # @param options [Hash]
    # @return [GDAL::RasterBand, nil]
    def add_band(type, **options)
      cpl_err = FFI::GDAL.GDALAddBand(@dataset_pointer, type, options_ptr)
      cpl_err.to_bool

      raster_band(raster_count)
    end

    # Adds a mask band to the dataset
    def create_mask_band
      FFI::GDAL.GDALCreateDatasetMaskBand(@dataset_pointer, 0)
    end

    # @return [String]
    def projection
      FFI::GDAL.GDALGetProjectionRef(@dataset_pointer)
    end

    # @param new_projection [String]
    # @return [Boolean]
    def projection=(new_projection)
      cpl_err = FFI::GDAL.GDALSetProjection(@dataset_pointer, new_projection)

      cpl_err.to_bool
    end

    # Creates a OGR::SpatialReference object from the dataset's projection.
    #
    # @return [OGR::SpatialReference]
    def spatial_reference
      p = projection
      return nil if p.empty?

      OGR::SpatialReference.new(projection)
    end

    # @return [GDAL::GeoTransform]
    def geo_transform
      return @geo_transform if @geo_transform

      geo_transform_pointer = FFI::MemoryPointer.new(:double, 6)
      cpl_err = FFI::GDAL.GDALGetGeoTransform(@dataset_pointer, geo_transform_pointer)
      cpl_err.to_ruby

      @geo_transform = GeoTransform.new(geo_transform_pointer)
    end

    # @param new_transform [GDAL::GeoTransform]
    # @return [GDAL::GeoTransform]
    def geo_transform=(new_transform)
      new_pointer = new_transform.c_pointer.dup
      cpl_err = FFI::GDAL.GDALSetGeoTransform(@dataset_pointer, new_pointer)
      cpl_err.to_bool

      @geo_transform = GeoTransform.new(new_pointer)
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

    # @return [FFI::GDAL::GDALGCP]
    def gcps
      return FFI::GDAL.GDALGCP.new if null?

      gcp_array_pointer = FFI::GDAL.GDALGetGCPs(@dataset_pointer)

      if gcp_array_pointer.null?
        FFI::GDAL.GDALGCP.new
      else
        FFI::GDAL.GDALGCP.new(gcp_array_pointer)
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
    def build_overviews(resampling, overview_levels, band_numbers=nil, &progress)
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

      cpl_err = FFI::GDAL.GDALBuildOverviews(@dataset_pointer,
        resampling_string,
        overview_levels.size,
        overview_levels_ptr,
        band_count,
        band_numbers_ptr,
        progress,
        nil
      )

      cpl_err.to_bool
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
    def rasterize_geometries(band_numbers, geometries, burn_values,
      transformer: nil, transform_arg: nil, **options, &progress_block)
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

      # not allowing for now
      progress_callback_data = nil

      cpl_err = FFI::GDAL.GDALRasterizeGeometries(@dataset_pointer,
        band_numbers.size,
        band_numbers_ptr,
        geometries.size,
        geometries_ptr,
        transformer,
        transform_arg,
        burn_values_ptr,
        gdal_options,
        progress_block,
        progress_callback_data)

      cpl_err.to_bool
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
    def rasterize_layers(band_numbers, layers, burn_values,
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

      cpl_err = FFI::GDAL.GDALRasterizeLayers(@dataset_pointer,     # hDS
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

      cpl_err.to_bool
    end
  end
end
