require './lib/ffi-gdal'
require 'pp'
require 'pathname'

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

#dir = './spec/support/aaron/Floyd'
#name = 'Floyd_1058_20140612_NRGB.tif'

dir = './spec/support/images/Harper'
name = 'Harper_1058_20140612_NRGB.tif'

#dir = './spec/support/osgeo'
#name = 'c41078a1.tif'

#dir = './spec/support/ShapeDailyCurrent'
#name = '851449507.dbf'
#name = '851449507.prj'

filename = File.expand_path(name, dir)
dataset = GDAL::Dataset.open(filename, 'r')

current_directory = Pathname.new(Dir.pwd)

puts '#------------------------------------------------------------------------'
puts '#'
puts "# #{GDAL.long_version}"
puts '#'
puts '# Build info:'
GDAL.build_info.each do |k, v|
  puts "#  - #{k} -> #{v}"
end
puts '#'
puts '#------------------------------------------------------------------------'
puts '#------------------------------------------------------------------------'
puts '#  Dataset Info'
puts '#------------------------------------------------------------------------'
puts "* Description:\t\t\t#{dataset.description}"
puts "* Raster size (x, y):\t\t#{dataset.raster_x_size}, #{dataset.raster_y_size}"
puts "* Raster count:\t\t\t#{dataset.raster_count}"
puts "* Access flag:\t\t\t#{dataset.access_flag}"
puts "* Projection definition:\t#{dataset.projection_definition}"
puts '* File list:'
dataset.file_list.each do |path|
  p = Pathname.new(path)
  puts "\t\t\t\t- #{p.relative_path_from(current_directory)}"
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



puts '#------------------------------------------------------------------------'
puts '#  Driver Info'
puts '#------------------------------------------------------------------------'
puts "* Description:\t\t#{dataset.driver.description}"
puts "* Short name:\t\t#{dataset.driver.short_name}"
puts "* Long name:\t\t#{dataset.driver.long_name}"
puts "* Help topic:\t\t#{dataset.driver.help_topic}"
puts '* Metadata:'
dataset.driver.all_metadata.each do |domain, data|
  puts "\t\t\t+ Domain: #{domain}"
  if data.empty?
    puts "\t\t\t\t- No values"
  else
    data.each do |k, v|
      print "\t\t\t\t- #{k} => "
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
    puts "  - description:\t\t\t#{band.description}"
    puts "  - size (x,y):\t\t\t#{band.x_size},#{band.y_size}"
    puts "  - no-data value:\t\t#{band.no_data_value}"
    puts "  - access flag:\t\t#{band.access_flag}"
    puts "  - number:\t\t\t#{band.number}"
    puts "  - color interp:\t\t#{band.color_interpretation}"
    puts "  - type:\t\t\t#{band.data_type}"
    puts "  - block size:\t\t\t#{band.block_size}"
    puts "  - category names:\t\t#{band.category_names}"
    band.category_names = 'meow'
    puts "  - category names:\t\t#{band.category_names}"
    puts "  - value range:\t\t#{band.minimum_value}..#{band.maximum_value}"
    #puts "  + read:\t\t\t#{band.read}"
    puts "  - unit type:\t\t\t#{band.unit_type}"
    puts "  - statistics:\t\t\t#{band.statistics}"
    puts "  - scale:\t\t\t#{band.scale}"
    puts "  - offset:\t\t\t#{band.offset}"
    puts "  - mask flags:\t\t\t#{band.mask_flags}"
    #puts "  + default histogram:\t\t\t#{band.default_histogram}"
    #puts "  + histogram:\t\t\t#{band.histogram(-0.5, 255.5, 256)}"

    if band.mask_band
      puts '  + Mask band:'
      puts "    - number:\t\t\t\t#{band.mask_band.number}"
      puts "    - size (x,y):\t\t\t#{band.mask_band.x_size},#{band.mask_band.y_size}"
      puts "    - color interp:\t\t\t#{band.mask_band.color_interpretation}"
      puts "    - type:\t\t\t\t#{band.mask_band.data_type}"
      puts "    - block size:\t\t\t#{band.mask_band.block_size}"
      puts "    - value range:\t\t\t#{band.mask_band.minimum_value}..#{band.mask_band.maximum_value}"
    end
    puts "  - has arbitrary overviews?\t#{band.arbitrary_overviews?}"
    puts "  - raster sample overview:\t#{band.raster_sample_overview}"
    puts "  - overview count:\t\t#{band.overview_count}"
    if band.overview_count > 0
      (0...band.overview_count).each do |j|
        overview = band.overview(j)
        puts "  # Overview #{j} Info:"
        puts "    - size (x, y):\t\t#{overview.x_size}, #{overview.y_size}"
        puts "    - color interp:\t\t#{overview.color_interpretation}"
        puts "    - type:\t\t\t#{overview.data_type}"
        puts "    - block size:\t\t#{overview.block_size}"
        puts "    - value range:\t\t#{overview.minimum_value}..#{overview.maximum_value}"
        puts "    - overview count:\t\t#{overview.overview_count}"
      end
    end
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
    if band.color_table
      puts '  + Color Table Info'
      puts "    - palette interp:\t\t#{band.color_table.palette_interpretation}"
      puts "    - color entry count:\t#{band.color_table.color_entry_count}"
      if band.color_table.color_entry_count > 0
        puts "    - #{band.color_table.color_entry_count} color entries:"

        (0...band.color_table.color_entry_count).each do |j|
          ce = band.color_table.color_entry(j)
          ce_string = "(#{ce[:c1]},#{ce[:c2]},#{ce[:c3]},#{ce[:c4]})"

          rgb = band.color_table.color_entry_as_rgb(j)
          rgb_string = "(#{rgb[:c1]},#{rgb[:c2]},#{rgb[:c3]},#{rgb[:c4]})"

          if band.color_table.palette_interpretation == :GPI_RGB
            puts "\t\t\t\t~ #{j}:\t#{ce_string}"
          else
            puts "\t\t\t\t~ #{j}:\t#{ce_string}, RGB: #{rgb_string}"
          end
        end
      else
        puts '    - No Color Entry Info.'
      end
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
  puts "\t\t\t- ID:\t\t\t\t'#{dataset.gcps[:id]}'"
  puts "\t\t\t- Info:\t\t\t'#{dataset.gcps[:info]}'"
  puts "\t\t\t- Pixel:\t\t\t#{dataset.gcps[:pixel]}"
  puts "\t\t\t- Line:\t\t\t#{dataset.gcps[:line]}"
  puts "\t\t\t- X:\t\t\t\t#{dataset.gcps[:x]}"
  puts "\t\t\t- Y:\t\t\t\t#{dataset.gcps[:y]}"
  puts "\t\t\t- Z:\t\t\t\t#{dataset.gcps[:z]}"
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
