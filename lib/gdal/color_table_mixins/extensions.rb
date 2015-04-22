require 'json'

module GDAL
  module ColorTableMixins
    module Extensions
      def color_entries_for(color_number)
        unless (1..4).to_a.include? color_number
          fail "Invalid ColorEntry number 'color#{color_number}'"
        end

        color_entry_count.times.map do |i|
          color_entry(i).send("color#{color_number}".to_sym)
        end
      end

      # @return [Array<GDAL::ColorEntry>]
      def color_entries
        color_entry_count.times.map do |i|
          color_entry(i)
        end
      end

      # Does the same as #color_entries, but calls #color_entry_as_rgb() instead
      # of #color_entry().
      #
      # @return [Array<GDAL::ColorEntry>]
      def color_entries_as_rgb
        color_entry_count.times.map do |i|
          color_entry_as_rgb(i)
        end
      end

      # @return [Hash]
      def as_json(_options = nil)
        {
          color_entry_count: color_entry_count,
          color_entries: color_entries.map(&:as_json),
          palette_interpretation: palette_interpretation
        }
      end

      # @return [String]
      def to_json(options = nil)
        as_json(options).to_json
      end
    end
  end
end
