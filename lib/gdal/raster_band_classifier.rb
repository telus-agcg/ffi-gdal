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
    attr_reader :ranges

    # @param raster_band [GDAL::RasterBand]
    def initialize(raster_band)
      @raster_band = raster_band
      @ranges = []
    end

    # @param range [Range] The range of values to map to a new value.
    # @param map_to_value [Number]
    def add_range(range, map_to_value)
      fail "range must be a Ruby Range" unless range.is_a? Range

      @ranges << { range: range, map_to: map_to_value }
    end

    # @param [Array<Hash{range => Range, map_to => Number}>]
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
    def equal_value_ranges(range_count)
      raster_min_max = @raster_band.min_max
      range_size = (raster_min_max[:max] - raster_min_max[:min]) / range_count
      ranges = []

      breakpoint_calculator = lambda do |range_number|
        min = raster_min_max[:min] + (range_size * range_number)
        max = raster_min_max[:min] + (range_size * (range_number + 1))

        range_for_type(min, max)
      end

      range_count.times do |i|
        range = breakpoint_calculator.call(i)

        ranges << {
          range: range,
          map_to: (i + 1).to_data_type(@raster_band.data_type)
        }
      end

      ranges
    end

    # Uses the ranges that have been added to remap ranges to map_to values.
    # Note that this *will* overwrite the associated RasterBand with these
    # values, so if you don't want to overwrite the Dataset you're working with,
    # you should copy it first.
    def classify!
      narray = @raster_band.to_na.dup

      0.upto(narray.size - 1) do |pixel_number|
        next if narray[pixel_number] == @raster_band.no_data_value[:value]

        @ranges.each do |range|
          if range[:range].member?(narray[pixel_number])
            narray[pixel_number] = range[:map_to]
          end
        end
      end

      @raster_band.write_array(narray, data_type: @raster_band.data_type)
    end

    private

    def range_for_type(min, max)
      min.to_data_type(@raster_band.data_type)..max.to_data_type(@raster_band.data_type)
    end
  end
end
