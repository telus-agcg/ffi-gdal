require './lib/ffi-gdal'


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

dir = './spec/support/osgeo'
name = 'c41078a1.tif'


filename = File.expand_path(name, dir)
dataset = GDAL::Dataset.new(filename, 'r')
histogram = FFI::MemoryPointer.new(:int, 256)

if dataset.raster_count > 0
  (1..dataset.raster_count).each do |i|
    band = dataset.raster_band(i)
    puts "raster #{i} data type: #{band.data_type}"

    block_size = band.block_size
    puts "raster #{i} block size: #{block_size}"

    x_blocks = (band.x_size + block_size[:x] - 1) / block_size[:x]
    puts "raster #{i} X blocks (#{band.x_size} + #{block_size[:x]} - 1): #{x_blocks}"

    y_blocks = (band.y_size + block_size[:y] - 1) / block_size[:y]
    puts "raster #{i} Y blocks (#{band.y_size} + #{block_size[:y]} - 1): #{y_blocks}"

    data_pointer = FFI::MemoryPointer.new(:uchar, block_size[:x] * block_size[:y])

    (0...y_blocks).each do |y_block|
      (0...x_blocks).each do |x_block|
        band.read_block(x_block, y_block, data_pointer)

        x_valid = if x_block + 1 * block_size[:x] > band.x_size
          band.x_size - x_block * block_size[:x]
        else
          block_size[:x]
        end

        y_valid = if y_block + 1 * block_size[:y] > band.y_size
                    band.y_size - y_block * block_size[:y]
                  else
                    block_size[:y]
                  end

        $stdout.sync
        (0...y_valid).each do |y|
          (0...x_valid).each do |x|
            offset = x + y * block_size[:x]

            begin
              value = histogram[offset]
              int = value.read_int
              print "y block: #{y_block}, x block: #{x_block}, offset: #{offset}, value: #{int}, e: #{y_block - int}\r"
              histogram[offset].write_int(value.read_int + 1)
            rescue IndexError
              #puts "MERER"
            end
          end
        end

      end
    end

    p histogram.read_array_of_int(0)
  end
end
