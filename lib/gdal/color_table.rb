require_relative '../ffi/gdal'


module GDAL
  module ColorTableTypes
    module Gray
      def grays
        all_entries_for :c1
      end
    end

    module RGB
      def reds(index=nil)
        all_entries_for :c1
      end

      def greens
        all_entries_for :c2
      end

      def blues
        all_entries_for :c3
      end

      def alphas
        all_entries_for :c4
      end

      def to_a
        NArray[reds, greens, blues, alphas].rot90(3).to_a
      end
    end

    module CMYK
      def cyans
        all_entries_for :c1
      end

      def magentas
        all_entries_for :c2
      end

      def yellows
        all_entries_for :c3
      end

      def blacks
        all_entries_for :c4
      end

      def to_a
        NArray[cyans, magentas, yellows, blacks].rot90(3).to_a
      end
    end

    module HLS
      def hues
        all_entries_for :c1
      end

      def lightnesses
        all_entries_for :c2
      end

      def saturations
        all_entries_for :c3
      end

      def to_a
        NArray[hues, lightnesses, saturations].rot90(3).to_a
      end
    end
  end

  class ColorTable
    include FFI::GDAL

    def self.create(raster_band, palette_interpretation)
      color_table_pointer = FFI::GDAL::GDALCreateColorTable(palette_interpretation)
      new(raster_band, color_table_pointer: color_table_pointer)
    end

    def initialize(gdal_raster_band, color_table_pointer: nil)
      @gdal_raster_band = if gdal_raster_band.is_a? GDAL::RasterBand
        gdal_raster_band.c_pointer
      else
        gdal_raster_band
      end

      @gdal_color_table = if color_table_pointer
        color_table_pointer
      else
        GDALGetRasterColorTable(@gdal_raster_band)
      end

      case palette_interpretation
      when :GPI_Gray then extend GDAL::ColorTableTypes::Gray
      when :GPI_RGB then extend GDAL::ColorTableTypes::RGB
      when :GPI_CMYK then extend GDAL::ColorTableTypes::CMYK
      when :GPI_HLS then extend GDAL::ColorTableTypes::HLS
      end
    end

    def c_pointer
      @gdal_color_table
    end

    def null?
      c_pointer.null?
    end

    # Usually :GPI_RGB.
    #
    # @return [Symbol] One of FFI::GDAL::GDALPaletteInterp.
    def palette_interpretation
      @palette_interpretation ||= GDALGetPaletteInterpretation(@gdal_color_table)
    end

    # @return [Fixnum]
    def color_entry_count
      return 0 if null?

      GDALGetColorEntryCount(@gdal_color_table)
    end

    # @param index [Fixnum]
    # @return [FFI::GDAL::GDALColorEntry]
    def color_entry(index)
      return nil if null?

      GDALGetColorEntry(@gdal_color_table, index)
    end

    # @param index [Fixnum]
    # @return [GGI::GDAL::GDALColorEntry]
    def color_entry_as_rgb(index)
      return nil if null?

      entry = GDALColorEntry.new
      GDALGetColorEntryAsRGB(@gdal_color_table, index, entry)

      entry
    end

    # Add a new ColorEntry to the ColorTable.  Valid values depend on the image
    # type you're working with (i.e. for Tiff, values can be between 0 and
    # 65535).  Values must also be relevant to the PaletteInterp type you're
    # working with.
    #
    # @param index [Fixnum] The inex of the color table's color entry to set.
    #   Must be between 0 and color_entry_count - 1.
    # @param one [Fixnum] The `c1` value of the FFI::GDAL::GDALColorEntry struct
    #   to set.
    # @param two [Fixnum] The `c2` value of the FFI::GDAL::GDALColorEntry struct
    #   to set.
    # @param three [Fixnum] The `c3` value of the FFI::GDAL::GDALColorEntry
    #   struct to set.
    # @param four [Fixnum] The `c4` value of the FFI::GDAL::GDALColorEntry
    #   struct to set.
    def add_color_entry(index, one: nil, two: nil, three: nil, four: nil)
      # unless (0..color_entry_count).include? index
      #   raise "Invalid color entry index.  Choose betwen 0 - #{color_entry_count}."
      # end

      entry = GDALColorEntry.new
      entry[:c1] = one if one
      entry[:c2] = two if two
      entry[:c3] = three if three
      entry[:c4] = four if four

      GDALSetColorEntry(@gdal_color_table, index, entry)
    end

    def all_entries_for(color_entry_c)
      unless %i[c1 c2 c3 c4].include? color_entry_c
        raise "Invalid ColorEntry attribute '#{color_entry_c}'"
      end

      0.upto(color_entry_count - 1).map do |i|
        color_entry(i)[color_entry_c]
      end
    end
  end
end
