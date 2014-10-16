require 'bundler/setup'
require 'pry'
require 'ffi-gdal'

GDAL::Logger.logging_enabled = true

floyd_path = '/Users/sloveless/Development/projects/ffi-gdal/spec/support/images/Floyd/Floyd_1058_20140612_NRGB.tif'
floyd = GDAL::Dataset.open(floyd_path, 'r')

floyd.extract_nir('nir.tif', 1)
floyd.extract_ndvi('ndvi.tif', band_order: %i[nir red green blue])
floyd.extract_gndvi('gndvi.tif', band_order: %i[nir red green blue])
floyd.extract_natural_color('nc.tif', band_order: %i[nir red green blue])
