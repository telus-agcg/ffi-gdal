require_relative 'layer'

module OGR

  # Geocode things!  http://www.gdal.org/ogr__geocoding_8h.html
  class GeocodingSession
    def initialize(**options)
      options_ptr = GDAL::Options.pointer(options)

      @geocoding_session_pointer = FFI::GDAL.OGRGeocodeCreateSession(options_ptr)
    end

    def c_pointer
      @geocoding_session_pointer
    end

    def destroy!
      FFI::GDAL.OGRGeocodeDestroySession(@geocoding_session_pointer)
    end

    # @param query [String]
    # @return [OGR::Layer, nil]
    def geocode(query, **options)
      options_ptr = GDAL::Options.pointer(options)
      layer_ptr = FFI::GDAL.OGRGeocode(@geocoding_session_pointer, query, nil,
        options_ptr)
      return nil if layer_ptr.null?

      OGR::Layer.new(layer_ptr)
    end

    # @param lon [Float]
    # @param lat [Float]
    # @return [OGR::Layer]
    def reverse_geocode(lon, lat, **options)
      options_ptr = GDAL::Options.pointer(options)
      layer_ptr = FFI::GDAL.OGRGeocodeReverse(@geocoding_session_pointer, lon,
        lat, options_ptr)
      return nil if layer_ptr.null?

      OGR::Layer.new(layer_ptr)
    end
  end
end
