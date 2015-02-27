module GDAL
  class ColorInterpretation
    # @param gdal_color_interp [FFI::GDAL::ColorInterp]
    # @return [String]
    def self.name(gdal_color_interp)
      FFI::GDAL.GDALGetColorInterpretationName(gdal_color_interp)
    end

    # @param name [String]
    # @return [FFI::GDAL::ColorInterp]
    def self.by_name(name)
      FFI::GDAL.GDALGetColorInterpretationByName(name)
    end
  end
end
