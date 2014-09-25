require 'narray'
require_relative 'dataset'

module GDAL
  class Utils
    def initialize(file_path)
      @dataset = GDAL::Dataset.open(file_path, 'r')
    end

    def extract_ndvi(new_file_name)
      red = red_band
      nir = undefined_band
      return nil if red.nil? or nir.nil?

      the_array = calculate_ndvi(red.to_a, nir.to_a)

      geo_transform = @dataset.geo_transform
      projection = @dataset.projection
      rows = @dataset.raster_y_size
      columns = @dataset.raster_x_size

      driver = GDAL::Driver.by_name 'GTiff'
      driver.create_dataset(new_file_name, columns, rows) do |dataset|
        dataset.geo_transform = geo_transform
        dataset.projection = projection

        ndvi_band = dataset.raster_band(1)
        ndvi_band.write_array(the_array)
      end
    end

    def calculate_ndvi(red_band_array, nir_band_array)
      (nir_band_array - red_band_array) / (nir_band_array + red_band_array)
    end

    def red_band
      @dataset.find_band do |band|
        band.color_interpretation == :GCI_RedBand
      end
    end

    def undefined_band
      @dataset.find_band do |band|
        band.color_interpretation == :GCI_Undefined
      end
    end
  end
end

if $0 == __FILE__
  file_path = File.expand_path('spec/support/images/Harper/Harper_1058_20140612_NRGB.tif')
  abort "File not found: #{file_path}" unless File.exist?(file_path)
  puts "File: #{File.expand_path(file_path, __dir__)}"

  #util = GDAL::Utils.new(file_path)
  #util.extract_ndvi('ndvi.tif')
  GDAL::Dataset.extract_ndvi(file_path, 'ndvi.tif')
end
