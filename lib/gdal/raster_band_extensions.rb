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
    def to_na(width: nil, height: nil)
      lines = []

      readlines do |line|
        lines << line
      end

      if height
        rows_needed = height - lines.size

        if rows_needed > 0
          # create new empty lines at the end
          rows_needed.times { lines << Array.new(lines.first.size, 0.0) }
        elsif rows_needed < 0
          # remove lines from the end
          lines.pop(rows_needed.abs)
        end
      end

      if width
        columns_needed = width - lines.first.size

        if columns_needed > 0
          # create new empty lines at the end
          lines.map! { |line| line.push(*Array.new(columns_needed, 0.0)) }
        elsif columns_needed < 0
          # remove lines from the end
          lines.pop(rows_needed.abs)
        end
      end

      NArray.to_na(lines)
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
