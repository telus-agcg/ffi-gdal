require_relative '../gdal'

module GDAL
  # Takes a list of Ranges of color values and remaps them.  Note that these
  # values are directly written to the raster band, overwriting all existing
  # values.
  #
  # @example
  #   classifier = GDAL::RasterBandClassifier.new(raster_band)
  #   ranges = [
  #     { range: 0...20, map_to: 1 },
  #     { range: 20...50, map_to: 2 },
  #     { range: 50...250, map_to: 3 }
  #   ]
  #   classifier.add_ranges(ranges)
  #   classifier.classify!(ranges)
  #
  # @param ranges [Array<Hash{range => Range, map_to => Number}>]
  class RasterBandClassifier
    include GDAL::Logger

    attr_reader :ranges

    # @param raster_band [GDAL::RasterBand]
    def initialize(raster_band)
      @raster_band = raster_band
      @ranges = []
    end

    # @param range [Range] The range of values to map to a new value.
    # @param map_to_value [Number]
    def add_range(range, map_to_value)
      fail 'range must be a Ruby Range' unless range.is_a? Range

      @ranges << { range: range, map_to: map_to_value }
    end

    # @param range_array [Array<Hash{range => Range, map_to => Number}>]
    def add_ranges(range_array)
      range_array.each do |range|
        add_range range[:range], range[:map_to]
      end
    end

    # Uses the max value of the associated RasterBand and +range_count+ to
    # calculate evenly-weighted ranges.  If there are remainder values at the
    # max end of the values, those get lumped in with the last range.
    #
    # @param range_count [Fixnum] The number of ranges to create.
    # @return [Array<Hash>, nil]
    def equal_count_ranges(range_count)
      sorted_pixels = @raster_band.to_na.sort
      sorted_and_masked_pixels = sorted_pixels[sorted_pixels.ne(@raster_band.no_data_value[:value])]
      range_size = (sorted_and_masked_pixels.size / range_count).to_i

      log "Pixel count: #{sorted_and_masked_pixels.size}"
      log "Min pixel value: #{sorted_and_masked_pixels.min}"
      log "Max pixel value: #{sorted_and_masked_pixels.max}"
      log "Range size: #{range_size}"

      break_values = Array.new(range_count) { |i| sorted_and_masked_pixels[range_size * i] }.uniq
      log "Break values: #{break_values}"
      return if break_values.uniq.size != range_count

      breakpoint_calculator = lambda do |range_number|
        min = break_values[range_number]
        max = break_values[range_number + 1] || sorted_and_masked_pixels.max

        range_for_type(min, max)
      end

      range_count.times.each_with_object([]) do |i, ranges|
        range = breakpoint_calculator.call(i)

        ranges << {
          range: range,
          map_to: (i + 1).to_data_type(@raster_band.data_type)
        }
      end
    end

    # Uses the ranges that have been added to remap ranges to map_to values.
    # Note that this *will* overwrite the associated RasterBand with these
    # values, so if you don't want to overwrite the Dataset you're working with,
    # you should copy it first.
    def classify!
      nodata_value = @raster_band.no_data_value[:value]

      @raster_band.read_lines_by_block.with_index do |pixels, row_number|
        pixel_number = 0

        while pixel_number < pixels.length
          pixel = pixels[pixel_number]

          if pixel == nodata_value
            pixel_number += 1
            next
          end

          range = @ranges.find { |r| r[:range].member?(pixel) }

          if range
            @raster_band.set_pixel_value(pixel_number, row_number, range[:map_to])
          else
            log "pixel #{pixel_number} (value: #{pixel}) not in any given range"
          end

          pixel_number += 1
        end
      end
    end

    private

    def range_for_type(min, max)
      min.to_data_type(@raster_band.data_type)..max.to_data_type(@raster_band.data_type)
    end
  end
end
