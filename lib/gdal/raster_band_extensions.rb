require 'json'

module GDAL
  module RasterBandExtensions

    def overviews
      0.upto(overview_count - 1).map do |i|
        overview(i)
      end
    end

    # Iterates through all lines and builds an NArray of pixels.
    #
    # @return [NArray]
    def to_na(data_type=nil)
      values = []
      x_blocks = (x_size + block_size[:x] - 1) / block_size[:x]
      y_blocks = (y_size + block_size[:y] - 1) / block_size[:y]

      data_pointer = FFI::MemoryPointer.new(:uchar, block_size[:x] * block_size[:y])

      (0...y_blocks).each do |y_block|
        (0...x_blocks).each do |x_block|
          read_block(x_block, y_block, data_pointer)

          (0...block_size[:y]).each do |block_index|
            pixels = data_pointer.get_array_of_uint8(block_size[:x] * block_index, block_size[:x])
            values.push(pixels)
          end
        end
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
