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

    # @return [GDAL::Driver] The driver to be used for working with this
    #   dataset.
    def driver
      @driver ||= Driver.new(dataset: @gdal_dataset)
    end

    # @return [Fixnum]
    def raster_x_size
      GDALGetRasterXSize(@gdal_dataset)
    end

    # @return [Fixnum]
    def raster_y_size
      GDALGetRasterYSize(@gdal_dataset)
    end

    # @return [Fixnum]
    def raster_count
      GDALGetRasterCount(@gdal_dataset)
    end

    # @param raster_index [Fixnum]
    # @return [GDAL::RasterBand]
    def raster_band(raster_index)
      @raster_bands ||= Array.new(raster_count)

      @raster_bands.fetch(raster_index) do |i|
        GDAL::RasterBand.new(@gdal_dataset, i)
      end
    end

    # @return [String]
    def projection_definition
      GDALGetProjectionRef(@gdal_dataset)
    end

    # @return [Symbol]
    def access_flag
      flag = GDALGetAccess(@gdal_dataset)
      GDALAccess[flag]
    end

    # @return [Array]
    def geo_transform
      GeoTransform.new(@gdal_dataset)
    end

    # @return [Fixnum]
    def open_dataset_count
      FFI::GDAL.GDALDumpOpenDatasets(@gdal_dataset)
    end
  end
end
