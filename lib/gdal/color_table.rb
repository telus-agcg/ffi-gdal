require_relative '../ffi/gdal'


module GDAL
  class ColorTable
    include FFI::GDAL

    def initialize(gdal_raster_band, gdal_color_table=nil)
      @gdal_raster_band = gdal_raster_band
      @gdal_color_table = gdal_color_table
    end

    def gdal_color_table
      @gdal_color_table ||= GDALGetRasterColorTable(@gdal_raster_band)
    end

    def null?
      gdal_color_table.nil? || gdal_color_table.null?
    end

    # @return [Symbol] One of FFI::GDAL::GDALPaletteInterp.
    def palette_interpretation
      #return GDALPaletteInterp[0] if null?

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

      ptr = GDALGetColorEntry(gdal_color_table, index)
      GDALColorEntry.new(ptr)
    end

    # @param index [Fixnum]
    # @return [GGI::GDAL::GDALColorEntry]
    def color_entry_as_rgb(index)
      return nil if null?

      entry = GDALColorEntry.new
      GDALGetColorEntryAsRGB(gdal_color_table, index, entry)

      entry
    end
  end
end
