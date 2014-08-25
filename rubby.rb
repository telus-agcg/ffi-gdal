require './lib/gdal/dataset'

#name = 'empty_red_image.tif'
#name = 'empty_black_image.tif'
name = 'NDVI20000201032.tif'

#dir = '../../agrian/gis_engine/test/test_files'
dir = '~/Desktop/geotiffs'
filename = File.expand_path(name, dir)
dataset = GDAL::Dataset.new(filename, 'r')

puts '#----------------------------------------------------'
puts '#  Dataset info'
puts "Driver short name:\t\t#{dataset.driver.short_name}"
puts "Driver long name:\t\t#{dataset.driver.long_name}"
puts "Driver creation option list:\t#{dataset.driver.creation_option_list}"
puts "Driver help topic:\t\t#{dataset.driver.help_topic}"
puts "Raster x size:\t\t\t#{dataset.raster_x_size}"
puts "Raster y size:\t\t\t#{dataset.raster_y_size}"
puts "Raster count:\t\t\t#{dataset.raster_count}"
puts "Projection definition:\t\t#{dataset.projection_definition}"
puts "Access flag:\t\t\t#{dataset.access_flag}"
puts "Geo-transform pixel width (A):\t#{dataset.geo_transform.pixel_width}"
puts "Geo-transform x rotation (B):\t#{dataset.geo_transform.x_rotation}"
puts "Geo-transform x origin (C):\t#{dataset.geo_transform.x_origin}"
puts "Geo-transform y rotation (D):\t#{dataset.geo_transform.y_rotation}"
puts "Geo-transform pixel height (E):\t#{dataset.geo_transform.pixel_height}"
puts "Geo-transform y origin (F):\t#{dataset.geo_transform.y_origin}"
puts "Geo-transform x projection:\t#{dataset.geo_transform.x_projection(0.1, 0.2)}"
puts "Geo-transform y projection:\t#{dataset.geo_transform.y_projection(0.2, 0.1)}"
puts "Open dataset count:\t\t#{dataset.open_dataset_count}"
puts '#----------------------------------------------------'
