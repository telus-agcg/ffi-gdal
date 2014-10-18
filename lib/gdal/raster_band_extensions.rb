require 'json'

module GDAL
  module RasterBandExtensions
    def overviews
      0.upto(overview_count - 1).map do |i|
        overview(i)
      end
    end

    # @return [Hash{x => Fixnum, y => Fixnum}]
    def block_count
      x_blocks = (x_size + block_size[:x] - 1) / block_size[:x]
      y_blocks = (y_size + block_size[:y] - 1) / block_size[:y]

      { x: x_blocks, y: y_blocks }
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
    # @param to_data_type [FFI::GDAL::GDALDataType]
    # @return [Enumerator, nil] Returns an Enumerable if no block is given,
    #   allowing to chain with other Enumerable methods.  Returns nil if a
    #   block is given.
    def each_by_block(to_data_type=nil)
      return enum_for(:each_by_block) unless block_given?

      data_type = to_data_type || self.data_type
      data_pointer = GDAL._pointer_from_data_type(data_type, block_buffer_size)

      0.upto(block_count[:y] - 1).each do |y_block_number|
        0.upto(block_count[:x] - 1).each do |x_block_number|
          read_block(x_block_number, y_block_number, data_pointer)

          0.upto(block_size[:y] - 1).each do |block_index|
            read_offset = block_size[:x] * block_index
            pixels = if data_type == :GDT_Byte
              data_pointer.get_array_of_uint8(read_offset, block_size[:x])
            else
              data_pointer.get_array_of_float(read_offset, block_size[:x])
            end

            yield(pixels)
          end
        end
      end
    end

    # Iterates through all lines and builds an NArray of pixels.
    #
    # @return [NArray]
    def to_na(to_data_type=nil)
      data_type = to_data_type || self.data_type

      values = each_by_block(to_data_type).map do |pixels|
        pixels
      end

      case data_type
      when :GDT_Byte then NArray.to_na(values).to_type(NArray::BYTE)
      when :GDT_UInt16 then NArray.to_na(values).to_type(NArray::SINT)
      when :GDT_Int16 then NArray.to_na(values).to_type(NArray::SINT)
      when :GDT_UInt32 then NArray.to_na(values).to_type(NArray::INT)
      when :GDT_Int32 then NArray.to_na(values).to_type(NArray::INT)
      when :GDT_Float32 then NArray.to_na(values).to_type(NArray::SFLOAT)
      when :GDT_Float64 then NArray.to_na(values).to_type(NArray::DFLOAT)
      when :GDT_CInt16 then NArray.to_na(values).to_type(NArray::SCOMPLEX)
      when :GDT_CInt32 then NArray.to_na(values).to_type(NArray::DCOMPLEX)
      when :GDT_CFloat32 then NArray.to_na(values).to_type(NArray::SCOMPLEX)
      when :GDT_CFloat64 then NArray.to_na(values).to_type(NArray::DCOMPLEX)
      else
        NArray.to_na(values)
      end
    end

    # @return [Hash]
    def as_json
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
    def to_json
      as_json.to_json
    end
  end
end
