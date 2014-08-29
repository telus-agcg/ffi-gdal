require './lib/ffi-gdal'
require 'narray'


#dir = '../../agrian/gis_engine/test/test_files'
#name = 'empty_red_image.tif'
#name = 'empty_black_image.tif'

#dir = '~/Desktop/geotiffs'
#name = 'NDVI20000201032.tif'
#name = 'NDVI20000701183.tif'
#name = 'NDVI20000701183.zip'
#name = 'NDVI20000401092.tif'

#dir = './spec/support'
#name = 'google_earth_test.jpg'
#name = 'compassdata_gcparchive_google_earth.kmz'

#dir = './spec/support/aaron/Floyd'
#name = 'Floyd_1058_20140612_NRGB.tif'
#name = 'Floyd_1058_20140612_RGBNRGB.bmp'
#name = 'Floyd_1058_20140612_RGBNRGB.jpg'

dir = './spec/support/images/Harper'
name = 'Harper_1058_20140612_NRGB.tif'

#dir = './spec/support/osgeo'
#name = 'c41078a1.tif'

filename = File.expand_path(name, dir)
dataset = GDAL::Dataset.open(filename, 'r')

abort('No raster bands') if dataset.raster_count == 0
GDAL.log "raster count: #{dataset.raster_count}"

def raster_stuff(band)
  GDAL.log "x size: #{band.x_size}"
  GDAL.log "y size: #{band.y_size}"
  GDAL.log "min: #{band.minimum_value}"
  GDAL.log "max: #{band.maximum_value}"
  GDAL.log "block size: #{band.block_size}"
  GDAL.log "color interp: #{band.color_interpretation}"
  lines = []

  band.readlines do |line|
    lines << line
  end

  GDAL.log "line height: #{lines.size}"
  lines
end

bands = []


1.upto(dataset.raster_count) do |i|
  GDAL.log "Checking band #{i}"
  band = dataset.raster_band(i)
  GDAL.log "* color interp: #{band.color_interpretation}"

  if %i[GCI_RedBand GCI_Undefined].include? band.color_interpretation
    bands << {
      band: band,
      array: NArray.to_na(raster_stuff(dataset.raster_band(i)))
    }
  end
end

red = bands.find { |hash| hash[:band].color_interpretation == :GCI_RedBand }
nir = bands.find { |hash| hash[:band].color_interpretation == :GCI_Undefined }

if nir.nil?
  abort 'No near-infrared band found!'
end
ndvi = (nir[:array] - red[:array]) / (nir[:array] + red[:array])

GDAL.log "NDVI array created"

GDAL.log dataset.driver.long_name
GDAL.log dataset.driver.all_metadata[:DEFAULT]["DCAP_CREATE"]

dataset.driver.create_dataset('testie.tif', ndvi.sizes.first, ndvi.sizes.last) do |out_dataset|
  GDAL.log "raster count: #{out_dataset.raster_count}"
  out_band = out_dataset.raster_band(1)
  out_band.write_array(ndvi)

  # need to add metadata and raster data
  # http://www.gdal.org/gdal_tutorial.html
end

