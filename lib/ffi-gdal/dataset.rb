require_relative '../ffi/gdal'
require_relative '../ffi-gdal'
require_relative 'driver'
require_relative 'geo_transform'
require_relative 'raster_band'
require_relative 'exceptions'
require_relative 'major_object'


module GDAL

  # A set of associated raster bands and info common to them all.  It's also
  # responsible for the georeferencing transform and coordinate system
  # definition of all bands.
  class Dataset
    include FFI::GDAL
    include MajorObject

    ACCESS_FLAGS = {
      'r' => :GA_ReadOnly,
      'w' => :GA_Update
    }

    # @param path [String] Path to the file that contains the dataset.
    # @param access_flag [String] 'r' or 'w'.
    def self.open(path, access_flag)
      file_path = ::File.expand_path(path)
      pointer = FFI::GDAL.GDALOpen(file_path, ACCESS_FLAGS[access_flag])
      raise OpenFailure.new(file_path) if pointer.null?

      new(pointer)
    end

    # @param dataset_pointer [FFI::Pointer] Pointer to the dataset in memory.
    def initialize(dataset_pointer)
      @gdal_dataset = dataset_pointer
      @last_known_file_list = []
      @open = true
      close_me = -> { self.close }
      ObjectSpace.define_finalizer self, close_me
    end

    # @return [FFI::Pointer] Pointer to the GDALDatasetH that's represented by
    # this Ruby object.
    def c_pointer
      @gdal_dataset
    end

    # Close the dataset.
    def close
      @last_known_file_list = file_list
      GDALClose(@gdal_dataset)
      @open = false
    end

    # Tries to reopen the dataset using the first item from #file_list before
    # the dataset was closed.
    #
    # @param access_flag [String]
    # @return [Boolean]
    def reopen(access_flag)
      @gdal_dataset = GDALOpen(@last_known_file_list.first, access_flag)

      @open = true unless @gdal_dataset.null?
    end

    # @return [Boolean]
    def open?
      @open
    end

    # @return [GDAL::Driver] The driver to be used for working with this
    #   dataset.
    def driver
      return @driver if @driver

      @driver = if @gdal_dataset && !null?
        Driver.new(dataset: @gdal_dataset)
      else
        Driver.new
      end
    end

    # Fetches all files that form the dataset.
    # @return [Array<String>]
    def file_list
      list_pointer = GDALGetFileList(c_pointer)
      file_list = list_pointer.get_array_of_string(0)
      CSLDestroy(list_pointer)

      file_list
    end

    # @return [Fixnum]
    def raster_x_size
      return nil if null?

      GDALGetRasterXSize(@gdal_dataset)
    end

    # @return [Fixnum]
    def raster_y_size
      return nil if null?

      GDALGetRasterYSize(@gdal_dataset)
    end

    # @return [Fixnum]
    def raster_count
      return 0 if null?

      GDALGetRasterCount(@gdal_dataset)
    end

    # @param raster_index [Fixnum]
    # @return [GDAL::RasterBand]
    def raster_band(raster_index)
      @raster_bands ||= Array.new(raster_count)

      if @raster_bands[raster_index] && !@raster_bands[raster_index].null?
        return @raster_bands[raster_index]
      end

      @raster_bands[raster_index] =
        GDAL::RasterBand.new(@gdal_dataset, band_id: raster_index)
    end

    # @return [String]
    def projection
      return '' if null?

      GDALGetProjectionRef(@gdal_dataset)
    end

    # @param new_projection [String]
    # @return [Boolean]
    def projection=(new_projection)
      cpl_err = GDALSetProjection(@gdal_dataset, new_projection)

      cpl_err.to_bool
    end

    # @return [Symbol]
    def access_flag
      return nil if null?

      flag = GDALGetAccess(@gdal_dataset)

      GDALAccess[flag]
    end

    # @return [GDAL::GeoTransform]
    def geo_transform
      @geo_transform ||= GeoTransform.new(@gdal_dataset)
    end

    # @param new_transform [GDAL::GeoTransform]
    def geo_transform=(new_transform)
      new_pointer = new_transform.c_pointer.dup
      cpl_err = GDALSetGeoTransform(@gdal_dataset, new_pointer)
      cpl_err.to_bool

      @geo_transform = GeoTransform.new(@gdal_dataset, geo_transform_pointer: new_pointer)
    end

    # @return [Fixnum]
    def gcp_count
      return 0 if null?

      GDALGetGCPCount(@gdal_dataset)
    end

    # @return [String]
    def gcp_projection
      return '' if null?

      GDALGetGCPProjection(@gdal_dataset)
    end

    # @return [FFI::GDAL::GDALGCP]
    def gcps
      return GDALGCP.new if null?

      gcp_array_pointer = GDALGetGCPs(@gdal_dataset)

      if gcp_array_pointer.null?
        GDALGCP.new
      else
        GDALGCP.new(gcp_array_pointer)
      end
    end

    # Iterates raster bands from 1 to #raster_count and yields them to the given
    # block.
    def each_band
      1.upto(raster_count) do |i|
        yield(raster_band(i))
      end
    end

    # Returns the first raster band for which the block returns true.  Ex.
    #
    #   dataset.find_band do |band|
    #     band.color_interpretation == :GCI_RedBand
    #   end
    #
    # @return [GDAL::RasterBand]
    def find_band
      each_band do |band|
        result = yield(band)
        return band if result
      end
    end
  end
end
