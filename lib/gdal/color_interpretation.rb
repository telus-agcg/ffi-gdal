# frozen_string_literal: true

module GDAL
  class ColorInterpretation
    # Normally this method would be called "name", but that would conflict with
    # `Class#name`.
    #
    # @param gdal_color_interp [FFI::GDAL::GDAL::ColorInterp]
    # @return [String]
    def self.color_interpretation_name(gdal_color_interp)
      # The returned strings are static strings and should not be modified or freed by the application.
      FFI::GDAL::GDAL.GDALGetColorInterpretationName(gdal_color_interp)
    end

    # @param name [String]
    # @return [FFI::GDAL::GDAL::ColorInterp]
    def self.by_name(name)
      FFI::GDAL::GDAL.GDALGetColorInterpretationByName(name)
    end
  end
end
