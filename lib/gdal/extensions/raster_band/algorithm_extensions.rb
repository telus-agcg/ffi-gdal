# frozen_string_literal: true

require 'gdal/raster_band'

module GDAL
  class RasterBand
    # RasterBand methods for doing warp-like things, but not using GDAL's Warp
    # API.
    module AlgorithmExtensions
      # A method that doesn't use GDAL's Warp API for erasing pixels (setting to
      # NODATA) in the method-owning RasterBand. It simply iterates over all of
      # the valued pixels (ones that aren't NODATA pixels) and yields them to a
      # block. The return value of the block tells the method whether to keep
      # the pixel or not: a truthy return value keeps the pixel; a false value
      # sets the pixel value to the band's NODATA value. If there's no NODATA
      # value set, it will raise an exception.
      #
      # A typical clip operation would be from checking to see if the
      # RasterBand's pixel is within some Polygon. Doing so would look like:
      #
      # @example Clipping by polygon
      #
      #   contrived_wkt = 'POLYGON ((0 0, 0 20, 20 20, 20 0, 0 0))'
      #   polygon = OGR::Geometry.create_from_wkt(contrived_wkt)
      #
      #   # Note the 'w' to open for writing!
      #   dataset = GDAL::Dataset.open('my.tif', 'w')
      #   geo_transform = dataset.geo_transform
      #   test_point = OGR::Point.new
      #
      #   dataset.raster_band(1).simple_erase! do |pixel_num, line_num|
      #     # Project the pixel using the dataset's GeoTransform
      #     projected_point_values = geo_transform.apply_geo_transform(pixel_num, line_num)
      #     test_point.set_point(projected_point_values[:x_geo], projected_point_values[:y_geo])
      #
      #     test_point.within? polygon
      #   end
      #
      #   # Make sure to close the dataset so the changes get flushed to disk.
      #   dataset.close
      #
      # You could, however use any other criteria in the block for erasing
      # points away. The method also the pixel value in case you can use it for
      # erasing. Perhaps, for example, you want to remove all pixels in the
      # upper left quadrant of your raster that have a value less than 0. That
      # would look like:
      #
      # @example Erasing using pixel location and values
      #
      #   dataset = GDAL::Dataset.open('my.tif', 'w')
      #   raster_band = dataset.raster_band(1)
      #
      #   raster_band.simple_erase! do |x, y, value|
      #     if x < (raster_band.x_size / 2) && y < (raster_band.y_size / 2) && value.negative?
      #       false
      #     else
      #       true
      #     end
      #   end
      #
      # @return [Integer] The number of pixels that were erased.
      def simple_erase!
        erase_value = no_data_value[:value]
        write_buffer = GDAL._buffer_from_data_type(data_type, x_size)
        erased_pixel_count = 0

        unless erase_value
          raise GDAL::NoRasterEraseValue,
                'Cannot erase values, RasterBand does not have a NODATA value set'
        end

        y_size.times do |line_num|
          pixel_row = raster_io('r', x_size: x_size, y_size: 1, x_offset: 0, y_offset: line_num)
          pixel_values = GDAL._read_pointer(pixel_row, data_type, x_size)
          row_changed = false
          pixel_num = 0

          while pixel_num < pixel_values.length
            pixel_value = pixel_values[pixel_num]
            next if pixel_value == no_data_value[:value]

            keep_in_raster = yield(pixel_num, line_num, pixel_value)
            next if keep_in_raster

            erased_pixel_count += 1
            pixel_values[pixel_num] = erase_value
            row_changed = true
            pixel_num += 1
          end

          rewrite_pixel_row(write_buffer, pixel_values, line_num) if row_changed
        end

        erased_pixel_count
      end

      private

      # @param write_buffer [FFI::Buffer]
      # @param pixel_values [Array<Number>]
      # @param line_number [Integer]
      def rewrite_pixel_row(write_buffer, pixel_values, line_number)
        GDAL._write_pointer(write_buffer, data_type, pixel_values)
        raster_io('w', write_buffer, x_size: x_size, y_size: 1, y_offset: line_number)
        write_buffer.clear
      end
    end
  end
end

GDAL::RasterBand.include(GDAL::RasterBand::AlgorithmExtensions)
