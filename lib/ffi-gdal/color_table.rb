require_relative '../ffi/gdal'


module GDAL
  module ColorTableTypes
    module Gray
      def grays
        0.upto(color_entry_count - 1).map do |i|
          color_entry(i)[:c1]
        end
      end
    end

    module RGB
      def reds(index=nil)
        if index
          color_entry(index)[:c1]
        else
          0.upto(color_entry_count - 1).map do |i|
            color_entry(i)[:c1]
          end
        end
      end

      def greens
        0.upto(color_entry_count - 1).map do |i|
          color_entry(i)[:c2]
        end
      end

      def blues
        0.upto(color_entry_count - 1).map do |i|
          color_entry(i)[:c3]
        end
      end

      def alphas
        0.upto(color_entry_count - 1).map do |i|
          color_entry(i)[:c4]
        end
      end

      def to_a
        NArray[reds, greens, blues, alphas].rot90(3)
      end
    end

    module CMYK

    end

    module HLS

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

    def add_color_entry(index, one: nil, two: nil, three: nil, four: nil)
      entry = GDALColorEntry.new
      entry[:c1] = one if one
      entry[:c2] = two if two
      entry[:c3] = three if three
      entry[:c4] = four if four

      GDALSetColorEntry(@gdal_color_table, index, entry)
    end
  end
end
