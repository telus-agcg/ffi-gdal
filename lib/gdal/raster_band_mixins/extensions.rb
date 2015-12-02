require 'json'

module GDAL
  module RasterBandMixins
    module Extensions
      def overviews
        overview_count.times.map do |i|
          overview(i)
        end
      end

      # Reads the raster line-by-line and returns as an NArray.  Will yield each
      # line and the line number if a block is given.
      #
      # @yieldparam pixel_line [Array]
      def readlines
        return enum_for(:readlines) unless block_given?

        y_size.times do |row_number|
          scan_line = raster_io('r', x_size: x_size,
                                     y_size: 1,
                                     y_offset: row_number)

          line_array = case data_type
                       when :GDT_Byte then scan_line.read_array_of_uint8(x_size)
                       when :GDT_UInt16 then scan_line.read_array_of_uint16(x_size)
                       when :GDT_Float32 then scan_line.read_array_of_float32(x_size)
                       else
                         fail "Not sure how to deal with data_type: #{data_type}"
                       end

          yield line_array
        end
      end

      # Writes a 2-dimensional NArray of (x, y) pixels to the raster band using
      # {GDAL::RasterBand#raster_io}. It determines +x_size+ and +y_size+ for
      # the {GDAL::RasterBand#raster_io} call using the dimensions of the array.
      #
      # @param pixel_array [NArray] The 2d list of pixels.
      def write_xy_narray(pixel_array)
        x_size = pixel_array.sizes.first
        y_size = pixel_array.sizes.last
        scan_line = FFI::MemoryPointer.new(:buffer_out, x_size)

        y_size.times do |line_number|
          pixels = pixel_array[true, line_number]
          GDAL._write_pointer(scan_line, data_type, pixels.to_a)

          raster_io('w', scan_line, x_size: x_size, y_size: 1,
                                    y_offset: line_number,
                                    buffer_x_size: x_size, buffer_y_size: line_number)
        end

        flush_cache
      end

      # Convenience method for directly setting a single pixel value.
      #
      # @param x [Fixnum] Pixel number in the row to set.
      # @param y [Fixnum] Row number of the pixel to set.
      # @param new_value [Number] The value to set the pixel to.
      def set_pixel_value(x, y, new_value)
        data_pointer = GDAL._pointer_from_data_type(data_type)
        GDAL._write_pointer(data_pointer, data_type, new_value)
        data_pointer_pointer = FFI::MemoryPointer.new(:buffer_inout, 1)
        data_pointer_pointer.write_pointer(data_pointer)

        raster_io('w', data_pointer, x_size: 1,
                                     y_size: 1,
                                     x_offset: x,
                                     y_offset: y,
                                     buffer_x_size: 1,
                                     buffer_y_size: 1)
      end

      # Convenience method for directly getting a single pixel value.
      #
      # @param x [Fixnum] Pixel number in the row to get.
      # @param y [Fixnum] Row number of the pixel to get.
      # @return [Number]
      def pixel_value(x, y)
        output = raster_io('r', x_size: 1,
                                y_size: 1,
                                x_offset: x,
                                y_offset: y,
                                buffer_x_size: 1,
                                buffer_y_size: 1)

        GDAL._read_pointer(output, data_type)
      end

      # Determines not only x and y block counts (how many blocks there are in
      # the raster band when using GDAL's suggested block size), but remainder
      # x and y counts for when the total number of pixels and lines does not
      # divide evently using GDAL's block count.
      #
      # @return [Hash{x => Fixnum, x_remainder => Fixnum, y => Fixnum,
      #   y_remainder => Fixnum}]
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
      # @return [Fixnum]
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
          pixels.each_slice(x_block_size).with_index do |row, block_row_number|
            yield row
            break if block_row_number == y_block_size - 1
          end
        end
      end

      # Reads through the raster block-by-block and yields all pixel values for
      # the block.
      #
      # @yieldparam pixels [Array<Number>] An Array the same size as
      #   {#block_buffer_size} containing all pixel values in the current block.
      # @yieldparam x_block_size [Fixnum] Instead of using only #{RasterBand#block_size},
      #   it will tell you the size of each block--handy for when the last block
      #   is smaller than the rest.
      # @yieldparam y_block_size [Fixnum] Same as +x_block_siz+ but for y.
      # @return [Enumerator, nil]
      def read_blocks_by_block
        return enum_for(:read_blocks_by_block) unless block_given?

        data_pointer = FFI::MemoryPointer.new(:buffer_inout, block_buffer_size)

        block_count[:y].times do |y_block_number|
          block_count[:x].times do |x_block_number|
            y_block_size = calculate_y_block_size(y_block_number)
            x_block_size = calculate_x_block_size(x_block_number)

            read_block(x_block_number, y_block_number, data_pointer)
            pixels = GDAL._read_pointer(data_pointer, data_type, block_buffer_size)

            yield(pixels, x_block_size, y_block_size)
          end
        end
      end

      # @return [Array]
      def to_a
        read_lines_by_block.map { |pixels| pixels }
      end

      # Iterates through all lines and builds an NArray of pixels.
      #
      # @return [NArray]
      def to_na(to_data_type = nil)
        narray = NArray.to_na(to_a)

        return narray unless to_data_type

        case to_data_type
        when :GDT_Byte                            then narray.to_type(NArray::BYTE)
        when :GDT_Int16                           then narray.to_type(NArray::SINT)
        when :GDT_UInt16, :GDT_Int32, :GDT_UInt32 then narray.to_type(NArray::INT)
        when :GDT_Float32                         then narray.to_type(NArray::FLOAT)
        when :GDT_Float64                         then narray.to_type(NArray::DFLOAT)
        when :GDT_CInt16, :GDT_CInt32             then narray.to_type(NArray::SCOMPLEX)
        when :GDT_CFloat32                        then narray.to_type(NArray::COMPLEX)
        when :GDT_CFloat64                        then narray.to_type(NArray::DCOMPLEX)
        else
          fail "Unknown data type: #{to_data_type}"
        end
      end

      # Each pixel of the raster projected using the dataset's geo_transform.
      # The output NArray is a 3D array where the inner-most array is a the
      # lat an lon, those are contained in an array per pixel line, and finally
      # the outter array contains each of the pixel lines.
      #
      # @return [NArray]
      def projected_points
        narray = GDAL._narray_from_data_type(data_type, 2, x_size, y_size)
        geo_transform = dataset.geo_transform

        y_size.times do |y_point|
          x_size.times do |x_point|
            coords = geo_transform.apply_geo_transform(x_point, y_point)
            narray[0, x_point, y_point] = coords[:x_geo] || 0
            narray[1, x_point, y_point] = coords[:y_geo] || 0
          end
        end

        narray
      end

      # @return [Hash]
      def as_json(_options = nil)
        {
          raster_band: {
            block_size: block_size,
            category_names: category_names,
            color_interpretation: color_interpretation,
            color_table: color_table,
            data_type: data_type,
            default_histogram: default_histogram(true),
            default_raster_attribute_table: default_raster_attribute_table,
            has_arbitrary_overviews: arbitrary_overviews?,
            mask_flags: mask_flags,
            maximum_value: maximum_value,
            minimum_value: minimum_value,
            no_data_value: no_data_value,
            number: number,
            offset: offset,
            overview_count: overview_count,
            overviews: overviews,
            scale: scale,
            statistics: statistics,
            unit_type: unit_type,
            x_size: x_size,
            y_size: y_size
          },
          metadata: all_metadata
        }
      end

      # @return [String]
      def to_json(options = nil)
        as_json(options).to_json
      end

      private

      # Determines how many lines to read for the block, considering that not
      # all blocks can be of equal size. For example, if there are 125 lines and
      # GDAL reports that the block size to read is 60, we still need to know
      # to read those last 5 lines when using block-related methods.
      #
      # @param block_number [Fixnum] The number of the y block when iterating
      #   through y blocks.
      # @return [Fixnum] The number of lines to read as part of the block.
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
      # @param block_number [Fixnum] The number of the x block when iterating
      #   through x blocks.
      # @return [Fixnum] The number of pixels to read as part of the block.
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
