require 'bundler/setup'
require 'pry'
require 'ffi-gdal'


harper_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/Harper/Harper_1058_20140612_NRGB.tif'
harper = GDAL::Dataset.open(harper_path, 'r')

floyd_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/Floyd/Floyd_1058_20140612_NRGB.tif'
floyd = GDAL::Dataset.open(floyd_path, 'r')

usg_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/osgeo/geotiff/usgs/c41078a1.tif'
usg = GDAL::Dataset.open(usg_path, 'r')

peter_path = '~/Downloads/ABCTURF_NEWFARM_15-5_2014-09-14.tif'
peter = GDAL::Dataset.open(peter_path, 'r')


binding.pry
