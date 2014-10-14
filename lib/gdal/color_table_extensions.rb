require 'json'

module GDAL
  module ColorTableExtensions

    def color_entries_for(color_entry_c)
      unless %i[c1 c2 c3 c4].include? color_entry_c
        raise "Invalid ColorEntry attribute '#{color_entry_c}'"
      end

      0.upto(color_entry_count - 1).map do |i|
        color_entry(i)[color_entry_c]
      end
    end

    # @return [Array<GDAL::ColorEntry>]
    def color_entries
      0.upto(color_entry_count - 1).map do |i|
        color_entry(i)
      end
    end

    # @return [Hash]
    def as_json
      {
        color_entry_count: color_entry_count,
        color_entries: color_entries.map(&:as_json),
        palette_interpretation: palette_interpretation,
      }
    end

    # @return [String]
    def to_json
      as_json.to_json
    end
  end
end
