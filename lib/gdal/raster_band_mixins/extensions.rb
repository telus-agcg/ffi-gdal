require 'json'

module GDAL
  module RasterBandMixins
    module Extensions
      def overviews
        Array.new(overview_count) do |i|
          overview(i)
        end
      end


        end
      end

      end

      # @return [Array]
      def to_a
        read_lines_by_block.to_a
      end

      # Iterates through all lines and builds an NArray of pixels.
      #
      # @return [NArray]
      def to_na(to_data_type = nil)
        narray = NArray.to_na(to_a)

        return narray unless to_data_type

        narray_type = GDAL._gdal_data_type_to_narray_type_constant(to_data_type)

        narray.to_type(narray_type)
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

      # The total number of pixels in the raster band.
      #
      # @return [Fixnum]
      def pixel_count
        x_size * y_size
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
    end
  end
end
