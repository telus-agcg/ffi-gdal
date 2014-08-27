require_relative '../ffi/gdal'
require_relative 'driver'
require_relative 'geo_transform'
require_relative 'raster_band'


module GDAL
  # A set of associated raster bands and info common to them all.  It's also
  # responsible for the georeferencing transform and coordinate system
  # definition of all bands.
  class Dataset
    include FFI::GDAL

    ACCESS_FLAGS = {
      'r' => :GA_ReadOnly,
      'w' => :GA_Update
    }

    # @param path [String] Path to the file that contains the dataset.
    # @param access_flag [String] 'r' or 'w'.
    def initialize(path, access_flag)
      FFI::GDAL.GDALAllRegister
      @path = ::File.expand_path(path)
      @gdal_dataset = GDALOpen(@path, ACCESS_FLAGS[access_flag])
    end

    def null?
      @gdal_dataset.null?
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
        GDAL::RasterBand.new(@gdal_dataset, raster_index)
    end

    # @return [String]
    def projection_definition
      return '' if null?

      GDALGetProjectionRef(@gdal_dataset)
    end

    # @return [Symbol]
    def access_flag
      return nil if null?

      flag = GDALGetAccess(@gdal_dataset)

      GDALAccess[flag]
    end

    # @return [Array]
    def geo_transform
      @geo_transform ||= GeoTransform.new(@gdal_dataset)
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

    # @return [Fixnum]
    def open_dataset_count
      return 0 if null?

      FFI::GDAL.GDALDumpOpenDatasets(@gdal_dataset)
    end
  end
end
