# frozen_string_literal: true

require "gdal/raster_band"

module GDAL
  class RasterBand
    # Methods for reading & writing RasterBands that didn't come from GDAL.
    module IOExtensions
      # Reads the raster line-by-line and returns as an NArray.  Will yield each
      # line and the line number if a block is given.
      #
      # @yieldparam pixel_line [Array]
      def readlines
        return enum_for(:readlines) unless block_given?

        y_size.times do |row_number|
          scan_line = raster_io("r", x_size: x_size, y_size: 1, y_offset: row_number)
          line_array = GDAL._read_pointer(scan_line, data_type, x_size)

          yield line_array
        end
      end

      # Writes a 2-dimensional NArray of (x, y) pixels to the raster band block-by-block.
      # Expects the input array to have the same shape as the raster band.
      # @param pixel_array [NArray] The 2d list of pixels.
      def write_xy_narray(pixel_array)
        data_pointer = FFI::MemoryPointer.new(:buffer_out, block_buffer_size)
        nnarray = GDAL._gdal_data_type_to_numo_narray_type_constant(data_type)

        pixel_array = nnarray[*pixel_array.to_a]

        block_count[:y].times do |y_block_number|
          block_count[:x].times do |x_block_number|
            # Create a block-sized NArray of zeros. This represents the block of pixels that will be written.
            block_pixels = nnarray.zeros(block_size[:y], block_size[:x])

            y_block_size = calculate_y_block_size(y_block_number)
            x_block_size = calculate_x_block_size(x_block_number)

            # Map the range of pixels corresponding to the current block.
            source_x_range = x_block_number * block_size[:x]...(x_block_number * block_size[:x]) + x_block_size
            source_y_range = y_block_number * block_size[:y]...(y_block_number * block_size[:y]) + y_block_size

            # Copy the corresponding pixels from the input array to the block pixels.
            block_pixels[0...y_block_size, 0...x_block_size] = pixel_array[source_y_range, source_x_range]

            GDAL._write_pointer(data_pointer, data_type, block_pixels.to_a.flatten)

            write_block(x_block_number, y_block_number, data_pointer)

            data_pointer.clear
          end
        end
      end

      # Convenience method for directly setting a single pixel value.
      #
      # @param x [Integer] Pixel number in the row to set.
      # @param y [Integer] Row number of the pixel to set.
      # @param new_value [Number] The value to set the pixel to.
      def set_pixel_value(x, y, new_value)
        data_pointer = GDAL._pointer_from_data_type(data_type)
        GDAL._write_pointer(data_pointer, data_type, new_value)

        raster_io("w", data_pointer, x_size: 1, y_size: 1, x_offset: x, y_offset: y, buffer_x_size: 1, buffer_y_size: 1)
      end

      # Convenience method for directly getting a single pixel value.
      #
      # @param x [Integer] Pixel number in the row to get.
      # @param y [Integer] Row number of the pixel to get.
      # @return [Number]
      def pixel_value(x, y)
        output = raster_io("r", x_size: 1, y_size: 1, x_offset: x, y_offset: y, buffer_x_size: 1, buffer_y_size: 1)

        GDAL._read_pointer(output, data_type)
      end

      # Determines not only x and y block counts (how many blocks there are in
      # the raster band when using GDAL's suggested block size), but remainder
      # x and y counts for when the total number of pixels and lines does not
      # divide evenly using GDAL's block count.
      #
      # @return [Hash{x => Integer, x_remainder => Integer, y => Integer,
      #   y_remainder => Integer}]
      # @see http://www.gdal.org/classGDALRasterBand.html#a09e1d83971ddff0b43deffd54ef25eef
      def block_count
        x_size_plus_block_size = x_size + block_size[:x]
        y_size_plus_block_size = y_size + block_size[:y]

        {
          x: ((x_size_plus_block_size - 1) / block_size[:x]).to_i,
          x_remainder: x_size_plus_block_size.modulo(block_size[:x]),
          y: ((y_size_plus_block_size - 1) / block_size[:y]).to_i,
          y_remainder: y_size_plus_block_size.modulo(block_size[:y])
        }
      end

      # The buffer size to use for block-based IO, based on #block_size.
      #
      # @return [Integer]
      def block_buffer_size
        block_size[:x] * block_size[:y]
      end

      # Reads through the raster, block-by-block then line-by-line and yields
      # the pixel data that it gathered.
      #
      # @yieldparam row [Array<Number>] The Array of pixels for the current
      #   line.
      # @return [Enumerator, nil] Returns an Enumerable if no block is given,
      #   allowing to chain with other Enumerable methods.  Returns nil if a
      #   block is given.
      def read_lines_by_block
        return enum_for(:read_lines_by_block) unless block_given?

        read_blocks_by_block do |pixels, x_block_size, y_block_size|
          pixels.each_slice(block_size[:x]).with_index do |row, block_row_number|
            yield row.take(x_block_size)
            break if block_row_number == y_block_size - 1
          end
        end
      end

      # Reads through the raster block-by-block and yields all pixel values for
      # the block.
      #
      # @yieldparam pixels [Array<Number>] An Array the same size as
      #   {#block_buffer_size} containing all pixel values in the current block.
      # @yieldparam x_block_size [Integer] Instead of using only #{RasterBand#block_size},
      #   it will tell you the size of each block--handy for when the last block
      #   is smaller than the rest.
      # @yieldparam y_block_size [Integer] Same as +x_block_siz+ but for y.
      # @return [Enumerator, nil]
      def read_blocks_by_block
        return enum_for(:read_blocks_by_block) unless block_given?

        data_pointer = FFI::MemoryPointer.new(:buffer_in, block_buffer_size)

        block_count[:y].times do |y_block_number|
          block_count[:x].times do |x_block_number|
            y_block_size = calculate_y_block_size(y_block_number)
            x_block_size = calculate_x_block_size(x_block_number)

            read_block(x_block_number, y_block_number, data_pointer)
            pixels = GDAL._read_pointer(data_pointer, data_type, block_buffer_size)

            yield(Array(pixels), x_block_size, y_block_size)
          end
        end
      end

      private

      # Determines how many lines to read for the block, considering that not
      # all blocks can be of equal size. For example, if there are 125 lines and
      # GDAL reports that the block size to read is 60, we still need to know
      # to read those last 5 lines when using block-related methods.
      #
      # @param block_number [Integer] The number of the y block when iterating
      #   through y blocks.
      # @return [Integer] The number of lines to read as part of the block.
      def calculate_y_block_size(block_number)
        # If it's the last block...
        if block_number == (block_count[:y] - 1)
          block_count[:y_remainder].zero? ? block_size[:y] : block_count[:y_remainder]
        else
          block_size[:y]
        end
      end

      # Determines how many pixels to read for the block, considering that not
      # all blocks can be of equal size. For example, if there are 125 pixels
      # and GDAL reports that the block size to read is 60, we still need to
      # know to read those last 5 pixels when using block-related methods.
      #
      # @param block_number [Integer] The number of the x block when iterating
      #   through x blocks.
      # @return [Integer] The number of pixels to read as part of the block.
      def calculate_x_block_size(block_number)
        # If it's the last block...
        if block_number == (block_count[:x] - 1)
          block_count[:x_remainder].zero? ? block_size[:x] : block_count[:x_remainder]
        else
          block_size[:x]
        end
      end
    end
  end
end

GDAL::RasterBand.include(GDAL::RasterBand::IOExtensions)
