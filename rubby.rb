require './lib/gdal/dataset'

#name = 'empty_red_image.tif'
#name = 'empty_black_image.tif'
name = 'NDVI20000201032.tif'

#dir = '../../agrian/gis_engine/test/test_files'
dir = '~/Desktop/geotiffs'
filename = File.expand_path(name, dir)
dataset = GDAL::Dataset.new(filename, 'r')

puts '#------------------------------------------------------------------------'
puts '#  Dataset Info'
puts '#------------------------------------------------------------------------'
puts "* Raster x size:\t\t#{dataset.raster_x_size}"
puts "* Raster y size:\t\t#{dataset.raster_y_size}"
puts "* Raster count:\t\t\t#{dataset.raster_count}"
puts "* Projection definition:\t#{dataset.projection_definition}"
puts "* Access flag:\t\t\t#{dataset.access_flag}"
puts "* Open dataset count:\t\t#{dataset.open_dataset_count}"
puts
puts '* Driver Info'
puts "  - Short name:\t\t\t#{dataset.driver.short_name}"
puts "  - Long name:\t\t\t#{dataset.driver.long_name}"
puts "  - Creation option list:\t#{dataset.driver.creation_option_list}"
puts "  - Help topic:\t\t\t#{dataset.driver.help_topic}"
puts
puts '* Raster Band Info'
puts "  - x size:\t\t\t#{dataset.raster_band(1).x_size}"
puts "  - y size:\t\t\t#{dataset.raster_band(1).y_size}"
puts "  - access flag:\t\t#{dataset.raster_band(1).access_flag}"
puts "  - number:\t\t\t#{dataset.raster_band(1).band_number}"
puts "  - color interp:\t\t#{dataset.raster_band(1).color_interpretation}"
puts "  - type:\t\t\t#{dataset.raster_band(1).raster_data_type}"
puts "  - block size:\t\t\t#{dataset.raster_band(1).block_size}"
puts "  - minimum value:\t\t#{dataset.raster_band(1).minimum_value}"
puts "  - maximum value:\t\t#{dataset.raster_band(1).maximum_value}"
puts "  - overview count:\t\t#{dataset.raster_band(1).overview_count}"
puts "  - read:\t\t#{dataset.raster_band(1).read}"
puts
puts '  * Color Table Info'
puts "    - palette interp:\t\t\t#{dataset.raster_band(1).color_table.palette_interpretation}"
puts "    - color entry count:\t\t#{dataset.raster_band(1).color_table.color_entry_count}"
puts "    - color entry 0:\t\t\t#{dataset.raster_band(1).color_table.color_entry(0)}"
puts "    - color entry as RGB 0:\t\t#{dataset.raster_band(1).color_table.color_entry_as_rgb(0)}"
puts
puts '* Geo-transform Info'
puts "  - pixel width (A):\t\t#{dataset.geo_transform.pixel_width}"
puts "  - x rotation (B):\t\t#{dataset.geo_transform.x_rotation}"
puts "  - x origin (C):\t\t#{dataset.geo_transform.x_origin}"
puts "  - y rotation (D):\t\t#{dataset.geo_transform.y_rotation}"
puts "  - pixel height (E):\t\t#{dataset.geo_transform.pixel_height}"
puts "  - y origin (F):\t\t#{dataset.geo_transform.y_origin}"
puts "  - x projection:\t\t#{dataset.geo_transform.x_projection(0.1, 0.2)}"
puts "  - y projection:\t\t#{dataset.geo_transform.y_projection(0.2, 0.1)}"
puts '#----------------------------------------------------'
