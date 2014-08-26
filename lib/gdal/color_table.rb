require_relative '../ffi/gdal'


module GDAL
  class ColorTable
    include FFI::GDAL

    def initialize(raster_band)
      @raster_band = raster_band
      @gdal_color_table = GDALGetRasterColorTable(raster_band)
    end

    # @return [Symbol] One of FFI::GDAL::GDALPaletteInterp.
    def palette_interpretation
      return GDALPaletteInterp[0] if @gdal_color_table.null?

      GDALGetPaletteInterpretation(@gdal_color_table)
    end

    # @return [Fixnum]
    def color_entry_count
      return 0 if @gdal_color_table.null?

      GDALGetColorEntryCount(@gdal_color_table)
    end

    # @param index [Fixnum]
    # @return [FFI::GDAL::GDALColorEntry]
    def color_entry(index)
      return nil if @gdal_color_table.null?

      GDALGetColorEntry(@gdal_color_table, index)
    end

    # @param index [Fixnum]
    # @return [Fixnum]
    def color_entry_as_rgb(index)
      entry = color_entry(index)
      return 0 if entry.nil?

      GDALGetColorEntryAsRGB(@gdal_color_table, index, entry)
    end
  end
end
