require_relative '../ffi/gdal'


module GDAL
  class ColorTable
    include FFI::GDAL

    attr_accessor :gdal_raster_band

    def initialize(gdal_raster_band=nil)
      @gdal_raster_band = gdal_raster_band
    end

    def gdal_color_table
      return @gdal_color_table if @gdal_color_table
      return nil unless @gdal_raster_band

      @gdal_color_table = GDALGetRasterColorTable(@gdal_raster_band)
    end

    def null?
      @gdal_color_table.nil? || @gdal_color_table.null?
    end

    # @return [Symbol] One of FFI::GDAL::GDALPaletteInterp.
    def palette_interpretation
      return GDALPaletteInterp[0] if null?

      GDALGetPaletteInterpretation(gdal_color_table)
    end

    # @return [Fixnum]
    def color_entry_count
      return 0 if null?

      GDALGetColorEntryCount(gdal_color_table)
    end

    # @param index [Fixnum]
    # @return [FFI::GDAL::GDALColorEntry]
    def color_entry(index)
      return nil if null?

      GDALGetColorEntry(gdal_color_table, index)
    end

    # @param index [Fixnum]
    # @return [Fixnum]
    def color_entry_as_rgb(index)
      entry = color_entry(index)
      return 0 if entry.nil?

      GDALGetColorEntryAsRGB(gdal_color_table, index, entry)
    end
  end
end
