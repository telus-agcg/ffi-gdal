require 'json'

module GDAL
  module RasterBandMixins
    module Extensions
      def overviews
        overview_count.times.map do |i|
          overview(i)
        end
      end

      # @return [Hash{x => Fixnum, y => Fixnum}]
      def block_count
        x_blocks = (x_size + block_size[:x]).divmod(block_size[:x])
        y_blocks = (y_size + block_size[:y]).divmod(block_size[:y])

        {
          x: x_blocks.first - 1,
          x_remainder: x_blocks.last,
          y: y_blocks.first - 1,
          y_remainder: y_blocks.last
        }
      end

      # The buffer size to use for block-based IO, based on #block_size.
      #
      # @return [Fixnum]
      def block_buffer_size
        block_size[:x] * block_size[:y]
      end

      # Reads through the raster, block-by-block and yields the pixel data that
      # it gathered.
      #
      # @param to_data_type [FFI::GDAL::DataType]
      # @return [Enumerator, nil] Returns an Enumerable if no block is given,
      #   allowing to chain with other Enumerable methods.  Returns nil if a
      #   block is given.
      def each_by_block(to_data_type = nil)
        return enum_for(:each_by_block) unless block_given?

        data_type = to_data_type || self.data_type
        data_pointer = GDAL._pointer_from_data_type(data_type, block_buffer_size)

        0.upto(block_count[:y]).each do |y_block_number|
          0.upto(block_count[:x] - 1).each do |x_block_number|
            y_block_size = if y_block_number == block_count[:y] && !block_count[:y_remainder].zero?
              block_count[:y_remainder]
            elsif y_block_number == block_count[:y]
              0
            else
              block_size[:y]
            end

            unless y_block_size.zero?
              read_block(x_block_number, y_block_number, data_pointer)

              0.upto(y_block_size - 1).each do |block_index|
                x_read_offset = block_size[:x] * block_index

                pixels = if data_type == :GDT_Byte
                           data_pointer.get_array_of_uint8(x_read_offset, block_size[:x])
                         elsif data_type == :GDT_UInt16
                           data_pointer.get_array_of_uint16(x_read_offset, block_size[:x])
                         else
                           data_pointer.get_array_of_float(x_read_offset, block_size[:x])
                         end

                yield(pixels)
              end
            end
          end
        end
      end

      # Iterates through all lines and builds an NArray of pixels.
      #
      # @return [NArray]
      def to_na(to_data_type = nil)
        values = each_by_block.map do |pixels|
          pixels
        end

        if to_data_type
          case to_data_type
          when :GDT_Byte then NArray.to_na(values).to_type(NArray::BYTE)
          when :GDT_Int16 then NArray.to_na(values).to_type(NArray::SINT)
          when :GDT_UInt16 then NArray.to_na(values).to_type(NArray::INT)
          when :GDT_Int32 then NArray.to_na(values).to_type(NArray::INT)
          when :GDT_UInt32 then NArray.to_na(values).to_type(NArray::INT)
          when :GDT_Float32 then NArray.to_na(values).to_type(NArray::SFLOAT)
          when :GDT_Float64 then NArray.to_na(values).to_type(NArray::DFLOAT)
          when :GDT_CInt16 then NArray.to_na(values).to_type(NArray::SCOMPLEX)
          when :GDT_CInt32 then NArray.to_na(values).to_type(NArray::DCOMPLEX)
          when :GDT_CFloat32 then NArray.to_na(values).to_type(NArray::SCOMPLEX)
          when :GDT_CFloat64 then NArray.to_na(values).to_type(NArray::DCOMPLEX)
          else
            fail "Unknown data type: #{to_data_type}"
          end
        else
          NArray.to_na(values)
        end
      end

      # Sets the band to be a Palette band, then applies an RGB color table using
      # the given colors.  Colors are distributed evenly across the table based
      # on the number of colors given.  Note that this will overwrite any existing
      # color table that may be set on this band.
      #
      # @param colors [Array<Fixnum, String>, Fixnum, String] Can be a single or
      #   many colors, given as either R, G, and B integers (0-255) or as strings
      #   of Hex.
      #
      # @example Colors as RGB values
      #   # This will make the first 128 values black, and the last 128, red.
      #   my_band.colorize!([[0, 0, 0], [255, 0, 0]])
      #
      # @example Colors as Hex values
      #   # Same as above...
      #   my_band.colorize!(%w[#000000 #FF0000])
      def colorize!(*colors)
        return if colors.empty?

        table = GDAL::ColorTable.new(:GPI_RGB)

        color_entry_index_count =
          if data_type == :GDT_Byte
            256
          elsif data_type == :GDT_UInt16
            65_536
          else
            fail "Can't colorize a #{data_type} band--must be :GDT_Byte or :GDT_UInt16"
          end

        self.color_interpretation ||= :GCI_PaletteIndex
        table.add_color_entry(0, 0, 0, 0, 255)
        bin_count = color_entry_index_count / colors.size.to_f

        1.upto(color_entry_index_count - 1) do |color_entry_index|
          color_number = (color_entry_index / bin_count).to_i

          color = colors[color_number]
          # TODO: Fix possible uninitialized rgb_array
          rgb_array = hex_to_rgb(color) unless color.is_a?(Array)
          table.add_color_entry(color_entry_index,
            rgb_array[0], rgb_array[1], rgb_array[2], 255)
        end

        self.color_table = table
      end

      # Gets the colors from the associated ColorTable and returns an Array of
      # those, where each ColorEntry is [R, G, B, A].
      #
      # @return [Array<Array<Fixnum>>]
      def colors_as_rgb
        return [] unless color_table

        color_table.color_entries_as_rgb.map(&:to_a)
      end

      # Gets the colors from the associated ColorTable and returns an Array of
      # Strings, where the RGB color for each ColorEntry has been converted to
      # Hex.
      #
      # @return [Array<String>]
      def colors_as_hex
        colors_as_rgb.map do |rgba|
          rgb = rgba.to_a[0..2]

          "##{rgb[0].to_s(16)}#{rgb[1].to_s(16)}#{rgb[2].to_s(16)}"
        end
      end

      # @param hex [String]
      def hex_to_rgb(hex)
        hex.sub!(/^#/, '')
        matches = hex.match(/(?<red>[a-zA-Z0-9]{2})(?<green>[a-zA-Z0-9]{2})(?<blue>[a-zA-Z0-9]{2})/)

        [matches[:red].to_i(16), matches[:green].to_i(16), matches[:blue].to_i(16)]
      end

      # Each pixel of the raster projected using the dataset's geo_transform.
      #
      # @return [NArray]
      def projected_points
        point_count = (y_size) * (x_size)
        narray = NArray.object(2, point_count)

        0.upto(y_size - 1).each do |y_point|
          0.upto(x_size - 1).each do |x_point|
            hash = dataset.geo_transform.apply_geo_transform(y_point, x_point)
            point_number = y_point * x_point
            narray[0, point_number] = hash[:y_geo] || 0
            narray[1, point_number] = hash[:x_geo] || 0
          end
        end

        narray
      end

      # @return [Hash]
      def as_json(options = nil)
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
    end
  end
end
