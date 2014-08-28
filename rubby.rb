require './lib/gdal/dataset'
require 'pp'

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

#dir = './spec/support/ShapeDailyCurrent'
#name = '851449507.dbf'
#name = '851449507.prj'


filename = File.expand_path(name, dir)
dataset = GDAL::Dataset.new(filename, 'r')

puts '#------------------------------------------------------------------------'
puts '#  Dataset Info'
puts '#------------------------------------------------------------------------'
puts "* Description:\t\t\t#{dataset.description}"
puts "* Raster size (x, y):\t\t#{dataset.raster_x_size}, #{dataset.raster_y_size}"
puts "* Raster count:\t\t\t#{dataset.raster_count}"
puts "* Access flag:\t\t\t#{dataset.access_flag}"
puts "* Projection definition:\t#{dataset.projection_definition}"
puts '* Files:'
dataset.files.each do |file|
  puts "\t\t\t\t- #{file}"
end
puts '* Metadata'
dataset.all_metadata.each do |domain, data|
  puts "\t\t\t\t+ Domain: #{domain}"
  if data.empty?
    puts "\t\t\t\t\t- No values"
  else
    data.each do |k, v|
      print "\t\t\t\t\t- #{k} => "
      pp v
    end
  end
end
puts


puts '#------------------------------------------------------------------------'
puts '#  Driver Info'
puts '#------------------------------------------------------------------------'
puts "* Description:\t\t#{dataset.driver.description}"
puts "* Short name:\t\t#{dataset.driver.short_name}"
puts "* Long name:\t\t#{dataset.driver.long_name}"
puts "* Help topic:\t\t#{dataset.driver.help_topic}"
puts '* Metadata:'
dataset.driver.all_metadata.each do |domain, data|
  puts "\t\t\t\t+ Domain: #{domain}"
  if data.empty?
    puts "\t\t\t\t\t- No values"
  else
    data.each do |k, v|
      print "\t\t\t\t\t- #{k} => "
      pp v
    end
  end
end

puts '* Creation option list:'
dataset.driver.creation_option_list.each do |option|
  puts "\t\t\t- #{option}" unless option.empty?
end
puts


if dataset.raster_count > 0
  puts '#------------------------------------------------------------------------'
  puts '#  Raster Band Info'
  puts '#------------------------------------------------------------------------'
  (1..dataset.raster_count).each do |i|
    band = dataset.raster_band(i)
    puts "* Band #{i}/#{dataset.raster_count}"
    puts "  + description:\t\t\t#{band.description}"
    puts "  + size (x, y):\t\t#{band.x_size}, #{band.y_size}"
    puts "  + access flag:\t\t#{band.access_flag}"
    puts "  + number:\t\t\t#{band.band_number}"
    puts "  + color interp:\t\t#{band.color_interpretation}"
    puts "  + type:\t\t\t#{band.raster_data_type}"
    puts "  + block size:\t\t\t#{band.block_size}"
    puts "  + value range:\t\t#{band.minimum_value}..#{band.maximum_value}"
    puts "  + overview count:\t\t#{band.overview_count}"
    puts "  + read:\t\t\t#{band.read}"
    puts '  + Metadata:'
    band.all_metadata.each do |domain, data|
      puts "\t\t\t\t+ Domain: #{domain}"
      if data.empty?
        puts "\t\t\t\t\t- No values"
      else
        data.each do |k, v|
          print "\t\t\t\t\t- #{k} => "
          pp v
        end
      end
    end
    puts '  + Color Table Info'
    puts "    - palette interp:\t\t\t#{band.color_table.palette_interpretation}"
    puts "    - color entry count:\t\t#{band.color_table.color_entry_count}"
    if band.color_table.color_entry_count > 0
      puts "    - #{band.color_table.color_entry_count} color entries:"

      (0..band.color_table.color_entry_count).each do |i|
        puts "    - #{i}:\t\t\t#{band.color_table.color_entry(0)}"
        puts "    - #{i} as RGB:\t\t#{band.color_table.color_entry_as_rgb(0)}"
      end
    else
    end
  end
end

puts

puts '#------------------------------------------------------------------------'
puts '# Ground Control Point (GCP) Info'
puts '#------------------------------------------------------------------------'
puts "* GCP count:\t\t\t#{dataset.gcp_count}"
if dataset.gcp_count > 0
  puts "* GCP projection:\t\t'#{dataset.gcp_projection}'"
  puts '* GCPs:'
  puts "  + ID:\t\t\t\t'#{dataset.gcps[:id]}'"
  puts "  + Info:\t\t\t'#{dataset.gcps[:info]}'"
  puts "  + Pixel:\t\t\t#{dataset.gcps[:pixel]}"
  puts "  + Line:\t\t\t#{dataset.gcps[:line]}"
  puts "  + X:\t\t\t\t#{dataset.gcps[:x]}"
  puts "  + Y:\t\t\t\t#{dataset.gcps[:y]}"
  puts "  + Z:\t\t\t\t#{dataset.gcps[:z]}"
end

puts
puts '#------------------------------------------------------------------------'
puts '# Geo-transform Info'
puts '#------------------------------------------------------------------------'
puts "* x origin (C):\t\t\t#{dataset.geo_transform.x_origin}"
puts "* y origin (F):\t\t\t#{dataset.geo_transform.y_origin}"
puts "* pixel width (A):\t\t#{dataset.geo_transform.pixel_width}"
puts "* pixel height (E):\t\t#{dataset.geo_transform.pixel_height}"
puts "* x rotation (B):\t\t#{dataset.geo_transform.x_rotation}"
puts "* y rotation (D):\t\t#{dataset.geo_transform.y_rotation}"
puts "* x projection (0.1, 0.2):\t#{dataset.geo_transform.x_projection(0.1, 0.2)}"
puts "* y projection (0.2, 0.1):\t#{dataset.geo_transform.y_projection(0.2, 0.1)}"
puts '#----------------------------------------------------'
