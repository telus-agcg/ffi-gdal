# http://www.gdal.org/gdal_tutorial.html


require './lib/ffi/gdal'
include FFI::GDAL

#name = 'empty_red_image.tif'
#name = 'empty_black_image.tif'
name = 'NDVI20000201032.tif'

#dir = '../../agrian/gis_engine/test/test_files'
dir = '~/Desktop/geotiffs'

file_name = File.expand_path(name, dir)
puts "file name: #{file_name}"

FFI::GDAL.GDALAllRegister
dataset = GDALOpen(file_name, :read_only)

abort 'file was not compatible' if dataset.null?
puts "dataset: #{dataset}"

#-------------------
# Getting dataset information
#-------------------

driver = GDALGetDatasetDriver(dataset)
puts "driver: #{driver}"
puts "driver short name: #{GDALGetDriverShortName(driver)}"
puts "driver long name: #{GDALGetDriverLongName(driver)}"

puts "size, x: #{GDALGetRasterXSize(dataset)}"
puts "size, y: #{GDALGetRasterYSize(dataset)}"
puts "size, count: #{GDALGetRasterCount(dataset)}"

puts "Projection is #{GDALGetProjectionRef(dataset)}"

geo_transform = FFI::MemoryPointer.new(:double, 6)

GDALGetGeoTransform(dataset, geo_transform)
puts "origin: #{geo_transform[0].read_double}, #{geo_transform[3].read_double}"
puts "pixel size: #{geo_transform[1].read_double}, #{geo_transform[5].read_double}"


#-------------------
# Fetching a raster band
#-------------------
block_x_size = FFI::MemoryPointer.new(:int)
block_y_size = FFI::MemoryPointer.new(:int)
raster_band = GDALGetRasterBand(dataset, 1)
GDALGetBlockSize(raster_band, block_x_size, block_y_size)

puts "Block: #{block_x_size.read_int}x#{block_y_size.read_int}"
puts "Type: #{GDALGetDataTypeName(GDALGetRasterDataType(raster_band))}"
puts "ColorInterp: #{GDALGetColorInterpretationName(GDALGetRasterColorInterpretation(raster_band))}"

b_got_min = FFI::MemoryPointer.new(:double)
b_got_max = FFI::MemoryPointer.new(:double)

adf_min_max = FFI::MemoryPointer.new(:double, 2)
adf_min_max.put_array_of_double(0, [
  GDALGetRasterMinimum(raster_band, b_got_min),
  GDALGetRasterMaximum(raster_band, b_got_max)
])

unless b_got_max && b_got_min
  GDALComputeRasterMinMax(raster_band, true, adf_min_max)
end

puts "Min: #{adf_min_max[0].read_double}"
puts "Max: #{adf_min_max[1].read_double}"

overview_count = GDALGetOverviewCount(raster_band)
puts "Band has #{overview_count} overviews."

raster_color_table = GDALGetRasterColorTable(raster_band)
unless raster_color_table.null?
  puts "Band has a color table with #{raster_color_table} entries."
end

