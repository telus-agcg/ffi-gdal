require_relative '../ffi/gdal'


module GDAL
  class ColorTable
    include FFI::GDAL

    def initialize(gdal_raster_band, color_table_pointer: nil)
      @gdal_raster_band = if gdal_raster_band.is_a? GDAL::RasterBand
        gdal_raster_band.c_pointer
      else
        gdal_raster_band
      end

      @gdal_color_table = color_table_pointer
    end

    def c_pointer
      @gdal_color_table ||= GDALGetRasterColorTable(@gdal_raster_band)
    end

    def null?
      c_pointer.nil? || c_pointer.null?
    end

    # @return [Symbol] One of FFI::GDAL::GDALPaletteInterp.
    def palette_interpretation
      #return GDALPaletteInterp[0] if null?

      GDALGetPaletteInterpretation(c_pointer)
    end

    # @return [Fixnum]
    def color_entry_count
      return 0 if null?

      GDALGetColorEntryCount(c_pointer)
    end

    # @param index [Fixnum]
    # @return [FFI::GDAL::GDALColorEntry]
    def color_entry(index)
      return nil if null?

      ptr = GDALGetColorEntry(c_pointer, index)
      GDALColorEntry.new(ptr)
    end

    # @param index [Fixnum]
    # @return [GGI::GDAL::GDALColorEntry]
    def color_entry_as_rgb(index)
      return nil if null?

      entry = GDALColorEntry.new
      GDALGetColorEntryAsRGB(c_pointer, index, entry)

      entry
    end
  end
end
