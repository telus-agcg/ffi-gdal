# frozen_string_literal: true

require 'gdal'
require 'numo/narray'

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
    MIN_GAP_PERCENTAGE = 0.005

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
      raise 'range must be a Ruby Range' unless range.is_a? Range

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
    # @param range_count [Integer] The number of ranges to create.
    # @return [Array<Hash>, nil]
    def equal_count_ranges(range_count)
      pixels = @raster_band.to_nna
      masked_pixels = masked_pixels(pixels)

      return [] if masked_pixels.empty?

      sorted_and_masked_pixels = masked_pixels.to_a.sort
      range_size = (sorted_and_masked_pixels.size / range_count).to_i

      log "Masked pixel count/total pixel count: #{sorted_and_masked_pixels.size}/#{pixels.size}"
      log "Min pixel value: #{sorted_and_masked_pixels.min}"
      log "Max pixel value: #{sorted_and_masked_pixels.max}"
      log "Range size: #{range_size}"

      break_values = [*Array.new(range_count) { |i| sorted_and_masked_pixels[range_size * i] }.uniq,
                      sorted_and_masked_pixels.max]
      ensure_min_gap(break_values)
      log "Break values: #{break_values}"

      return if range_count != 1 && break_values.uniq.size - 1 != range_count

      breakpoint_calculator = lambda do |range_number|
        min = break_values[range_number]
        max = break_values[range_number + 1]

        range_for_type(min, max)
      end

      Array.new(range_count) do |i|
        range = breakpoint_calculator.call(i)
        { range: range, map_to: (i + 1).to_data_type(@raster_band.data_type) }
      end
    end

    # Uses the ranges that have been added to remap ranges to map_to values.
    # Note that this *will* overwrite the associated RasterBand with these
    # values, so if you don't want to overwrite the Dataset you're working with,
    # you should copy it first.
    def classify!
      band_pixels = @raster_band.to_nna
      new_band_pixels = band_pixels.clone
      data_pixels = if nodata_value
                      nodata_is_nan? ? ~band_pixels.isnan : band_pixels.ne(nodata_value)
                    else
                      Numo::Bit.cast(band_pixels.new_ones)
                    end

      @ranges.each do |r|
        new_band_pixels[data_pixels & band_pixels.le(r[:range].max) & band_pixels.ge(r[:range].min)] = r[:map_to]
      end

      mask_nan(new_band_pixels, data_pixels) if nodata_is_nan?
      @raster_band.write_xy_narray(new_band_pixels)
    end

    # @return [Numeric] NODATA value for the @raster_band.
    def nodata_value
      @raster_band.no_data_value[:value]
    end

    # @return [Boolean] True if NODATA is NaN.
    def nodata_is_nan?
      nodata_value.is_a?(Float) && nodata_value.nan?
    end

    private

    # @param pixels [Numo::NArray]
    # @return [Numo::NArray]
    def masked_pixels(pixels)
      no_data = @raster_band.no_data_value[:value]

      if no_data
        mask = no_data.is_a?(Float) && no_data.nan? ? ~pixels.isnan : pixels.ne(no_data)
        pixels[mask]
      else
        pixels
      end
    end

    # @param break_values [Array<Numeric>]
    def ensure_min_gap(break_values)
      min_gap = (break_values.last - break_values.first) * MIN_GAP_PERCENTAGE

      (1...break_values.size).each do |index|
        left, right = break_values[index - 1, 2]
        diff = right - left
        adjustment = (min_gap / 2) - (diff / 2)

        next unless diff < min_gap

        log "Index #{index} diff #{diff} smaller than min_gap #{min_gap}, adjusting by #{adjustment}"
        break_values.fill(0...index) { |x| break_values[x] - adjustment }
        break_values.fill(index..) { |x| break_values[x] + adjustment }
      end
    end

    def range_for_type(min, max)
      min.to_data_type(@raster_band.data_type)..max.to_data_type(@raster_band.data_type)
    end

    # Set nodata pixels to 0 and set the nodata value to 0.
    #
    # @param new_band_pixels [Numo::NArray]
    # @param data_pixels [Numo::Bit]
    def mask_nan(new_band_pixels, data_pixels)
      new_band_pixels[~data_pixels] = 0
      @raster_band.no_data_value = 0
    end
  end
end
