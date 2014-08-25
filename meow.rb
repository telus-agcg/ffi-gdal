# http://www.gdal.org/gdal_tutorial.html


require './lib/ffi/gdal'
require 'ruby-progressbar'
include FFI::GDAL

progressbar = ProgressBar.create
#name = 'empty_red_image.tif'
#name = 'empty_black_image.tif'
name = 'NDVI20000201032.tif'

#dir = '../../agrian/gis_engine/test/test_files'
dir = '~/Desktop/geotiffs'

psz_src_filename = File.expand_path(name, dir)
progressbar.log "file name: #{psz_src_filename}"

FFI::GDAL.GDALAllRegister
dataset = GDALOpen(psz_src_filename, :GA_ReadOnly)

abort 'file was not compatible' if dataset.null?
progressbar.log "dataset: #{dataset}"

#-------------------
# Getting dataset information
#-------------------

dataset_driver = GDALGetDatasetDriver(dataset)
progressbar.log "driver: #{dataset_driver}"
progressbar.log "driver short name: #{GDALGetDriverShortName(dataset_driver)}"
progressbar.log "driver long name: #{GDALGetDriverLongName(dataset_driver)}"

progressbar.log "size, x: #{GDALGetRasterXSize(dataset)}"
progressbar.log "size, y: #{GDALGetRasterYSize(dataset)}"
progressbar.log "size, count: #{GDALGetRasterCount(dataset)}"

progressbar.log "Projection is #{GDALGetProjectionRef(dataset)}"

geo_transform = FFI::MemoryPointer.new(:double, 6)

GDALGetGeoTransform(dataset, geo_transform)
progressbar.log "origin: #{geo_transform[0].read_double}, #{geo_transform[3].read_double}"
progressbar.log "pixel size: #{geo_transform[1].read_double}, #{geo_transform[5].read_double}"


#-------------------
# Fetching a raster band
#-------------------
block_x_size = FFI::MemoryPointer.new(:int)
block_y_size = FFI::MemoryPointer.new(:int)
raster_band = GDALGetRasterBand(dataset, 1)
GDALGetBlockSize(raster_band, block_x_size, block_y_size)

progressbar.log "Block: #{block_x_size.read_int}x#{block_y_size.read_int}"
progressbar.log "Type: #{GDALGetDataTypeName(GDALGetRasterDataType(raster_band))}"
progressbar.log "ColorInterp: #{GDALGetColorInterpretationName(GDALGetRasterColorInterpretation(raster_band))}"

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

progressbar.log "Min: #{adf_min_max[0].read_double}"
progressbar.log "Max: #{adf_min_max[1].read_double}"

overview_count = GDALGetOverviewCount(raster_band)
progressbar.log "Band has #{overview_count} overviews."

raster_color_table = GDALGetRasterColorTable(raster_band)
unless raster_color_table.null?
  progressbar.log "Band has a color table with #{raster_color_table} entries."
end


#-------------------
# Reading Raster Data
#-------------------
x_size = GDALGetRasterBandXSize(raster_band)
paf_scanline = FFI::MemoryPointer.new(:float, x_size)
GDALRasterIO(raster_band,
  :GF_Read,
  0,
  0,
  x_size,
  1,
  paf_scanline,
  x_size,
  1,
  :GDT_Float32,
  0,
  0)

progressbar.log "scanline: #{paf_scanline.read_float}"

#-------------------
# Techniques for creating files
#-------------------
psz_format = 'GTiff'
geotiff_driver = GDALGetDriverByName(psz_format)
abort "No such driver #{psz_format}" if geotiff_driver.null?
papsz_metadata = GDALGetMetadata(geotiff_driver, nil)

if CSLFetchBoolean(papsz_metadata, GDAL_DCAP_CREATE, 0)
  progressbar.log "Driver #{psz_format} supports Create() method."
end

if CSLFetchBoolean(papsz_metadata, GDAL_DCAP_CREATECOPY, 0)
  progressbar.log "Driver #{psz_format} supports CreateCopy() method."
end

psz_dst_filename = File.expand_path('gdal_createcopy_test.tif', dir)
src_dataset = GDALOpen(psz_src_filename, :GA_ReadOnly)
dest_dataset = GDALCreateCopy(geotiff_driver, psz_dst_filename, src_dataset, 0, nil, nil, nil)
GDALClose(dest_dataset) unless dest_dataset.null?

# Don't close this yet--we use it later.
# GDALClose(src_dataset)


papsz_options = CSLSetNameValue(FFI::MemoryPointer.new(:pointer, 2), 'TILED', 'YES')
papsz_options = CSLSetNameValue(papsz_options, 'COMPRESS', 'PACKBITS')
progressbar.log "First option key/value pair: #{papsz_options.read_array_of_pointer(2).first.read_string}"
progressbar.log "Second option key/value pair: #{papsz_options.read_array_of_pointer(2).last.read_string}"


callback = Proc.new do |double, _, _|
  progress = double * 100
  progressbar.progress = progress unless progressbar.progress == 100
end
dest_dataset2 = GDALCreateCopy(geotiff_driver, psz_dst_filename, src_dataset, 0, papsz_options, callback, nil)

GDALClose(dest_dataset2) unless dest_dataset2.null?
CSLDestroy(papsz_options)
GDALClose(src_dataset)

