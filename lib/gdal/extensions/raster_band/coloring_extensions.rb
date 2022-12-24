# frozen_string_literal: true

module GDAL
  class RasterBand
    # RasterBand methods added for dealing with colorizing.
    module ColoringExtensions
      # Sets the band to be a Palette band, then applies an RGB color table using
      # the given colors.  Colors are distributed evenly across the table based
      # on the number of colors given.  Note that this will overwrite any existing
      # color table that may be set on this band.
      #
      # @param colors [Array<Integer, String>, Integer, String] Can be a single or
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

        self.color_interpretation ||= :GCI_PaletteIndex
        table = GDAL::ColorTable.new(:GPI_RGB)
        table.add_color_entry(0, 0, 0, 0, 255)

        # Start at 1 instead of 0 because we manually set the first color entry
        # to white.
        color_entry_index_range =
          case data_type
          when :GDT_Byte then 1..255
          when :GDT_UInt16 then 1..65_535
          else raise "Can't colorize a #{data_type} band--must be :GDT_Byte or :GDT_UInt16"
          end

        bin_count = (color_entry_index_range.last + 1) / colors.size.to_f

        color_entry_index_range.step do |color_entry_index|
          color_number = (color_entry_index / bin_count).floor.to_i
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
      # @return [Array<Array<Integer>>]
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
        hex = hex.sub(/^#/, '')
        matches = hex.match(/(?<red>[a-zA-Z0-9]{2})(?<green>[a-zA-Z0-9]{2})(?<blue>[a-zA-Z0-9]{2})/)

        [matches[:red].to_i(16), matches[:green].to_i(16), matches[:blue].to_i(16)]
      end
    end
  end
end

GDAL::RasterBand.include(GDAL::RasterBand::ColoringExtensions)
