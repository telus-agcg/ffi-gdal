# frozen_string_literal: true

require 'bundler/setup'
require 'ffi-gdal'

GDAL::Logger.logging_enabled = true

colors = %w[644d1e 745924 856728 95742b a5812d b69930 c8b22d d8cb3c e8e65a
            f4ee79 e0e457 c8da42 afd135 97b73c 7e993c 657e36 4b612c 314441 23295e
            282973]

floyd_path = File.join(__dir__, '../spec/support/images/Floyd/Floyd_1058_20140612_NRGB.tif')
floyd = GDAL::Dataset.open(floyd_path, 'r')

#---
# Extracting...
#---

# NIR
floyd.extract_nir('nir.tif', 1).close

# Natural Color
floyd.extract_natural_color('nc.tif', band_order: %i[nir red green blue]).close

# NDVI as Float32
floyd.extract_ndvi('ndvi_float.tif', band_order: %i[nir red green blue],
                                     data_type: :GDT_Float32,
                                     remove_negatives: true).close

# NDVI as Byte
floyd.extract_ndvi('ndvi_byte.tif', band_order: %i[nir red green blue],
                                    data_type: :GDT_Byte,
                                    remove_negatives: true,
                                    photometric: 'PALETTE').close

# NDVI as UInt16
floyd.extract_ndvi('ndvi_uint16.tif', band_order: %i[nir red green blue],
                                      data_type: :GDT_UInt16,
                                      remove_negatives: true,
                                      photometric: 'PALETTE').close

#---
# Colorize after extraction...
#---

byte_dataset = GDAL::Dataset.open('ndvi_byte.tif', 'w')
byte_band = byte_dataset.raster_band(1)
byte_band.colorize!(*colors)
byte_dataset.close

uint16_dataset = GDAL::Dataset.open('ndvi_uint16.tif', 'w')
uint16_band = uint16_dataset.raster_band(1)
uint16_band.colorize!(*colors)
uint16_dataset.close

g_byte_dataset = GDAL::Dataset.open('gndvi_byte.tif', 'w')
g_byte_band = g_byte_dataset.raster_band(1)
g_byte_band.colorize!(*colors)
g_byte_dataset.close

g_uint16_dataset = GDAL::Dataset.open('gndvi_uint16.tif', 'w')
g_uint16_band = g_uint16_dataset.raster_band(1)
g_uint16_band.colorize!(*colors)
g_uint16_dataset.close
