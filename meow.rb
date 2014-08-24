# http://www.gdal.org/gdal_tutorial.html


require './lib/ffi/gdal'

#file = File.expand_path('soil_test_grid_kriging.sdat', '../../agrian/gis_engine/test/test_files')
file_name = File.expand_path('empty_red_image.tif', '../../agrian/gis_engine/test/test_files')
puts "file name: #{file_name}"

FFI::GDAL.GDALAllRegister
dataset = FFI::GDAL.GDALOpen(file_name, :read_only)

if dataset.nil?
  abort 'file was not compatible'
end

puts "dataset: #{dataset}"

driver = FFI::GDAL.GDALGetDatasetDriver(dataset)
puts "driver: #{driver}"
puts "driver short name: #{FFI::GDAL.GDALGetDriverShortName(driver)}"
puts "driver long name: #{FFI::GDAL.GDALGetDriverLongName(driver)}"

puts "size, x: #{FFI::GDAL.GDALGetRasterXSize(dataset)}"
puts "size, y: #{FFI::GDAL.GDALGetRasterYSize(dataset)}"
puts "size, count: #{FFI::GDAL.GDALGetRasterCount(dataset)}"

puts "Projection is #{FFI::GDAL.GDALGetProjectionRef(dataset)}"

#geo_transform = FFI::ArrayType.new(:double, 6)
#geo_transform = []
geo_transform = FFI::MemoryPointer.new(:double, 6)

FFI::GDAL.GDALGetGeoTransform(dataset, geo_transform)
p geo_transform
puts "origin: #{geo_transform[0].read_double}, #{geo_transform[3].read_double}"
puts "pixel size: #{geo_transform[1].read_double}, #{geo_transform[5].read_double}"


