require './lib/ffi-gdal'


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

dir = './spec/support/aaron/Floyd'
name = 'Floyd_1058_20140612_NRGB.tif'

#dir = './spec/support/osgeo'
#name = 'c41078a1.tif'

filename = File.expand_path(name, dir)
dataset = GDAL::Dataset.new(filename, 'r')

abort('No raster bands') if dataset.raster_count == 0
puts "raster count: #{dataset.raster_count}"

def raster_stuff(band)
  puts "x size: #{band.x_size}"
  puts "y size: #{band.y_size}"
  puts "min: #{band.minimum_value}"
  puts "max: #{band.maximum_value}"
  puts "block size: #{band.block_size}"
  puts "color interp: #{band.color_interpretation}"
  lines = []
  band.read do |line|
    #print "line length: #{line.size}\r"
    lines << line
  end
  puts "line height: #{lines.size}"
  #p lines.map { |l| l[1]}
  lines
end

bands = []

require 'narray'

1.upto(dataset.raster_count) do |i|
  bands << NArray.to_na(raster_stuff(dataset.raster_band(i)))
end

red = bands[2]
nir = bands[3]

ndvi = (nir - red) / (nir + red)
p nir
p red
p ndvi


