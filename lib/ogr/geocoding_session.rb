require_relative 'layer'

module OGR

  # Geocode things!  http://www.gdal.org/ogr__geocoding_8h.html
  class GeocodingSession
    # @param options [Hash]
    # @option options cache_file [String] Name of the file to write the cache
    #   to.
    # @option options read_cache [Boolean] Defaults to true.
    # @option options write_cache [Boolean] Defaults to true.
    # @option options service [String] "MAPQUEST_NOMINATIM", "YAHOO",
    #   "GEONAMES", "BING", or other value.
    # @option options email [String] Required for the GEONAMES service.
    # @option options key [String] Required for the BING service.
    # @option options application [String] Sets the User-Agent request header.
    #   Defaults to the GDAL version string.
    # @option options language [String] Sets the Accept-Language request
    #   headeer.
    # @option options delay [Float] Minimum delay, in seconds, between
    #   consecutive requests. Defaults to 1.0.
    # @option options query_template [String] URL template for GET requests.
    #   Must contain one and only one occurence of %s.  If not specified, the
    #   URL template is hard-coded.
    # @option options reverse_query_template [String] Template to use for
    #   reverse geocoding.
    def initialize(**options)
      converted_options = options.each_with_object({}) do |(k, v), obj|
        key = "OGR_GEOCODE_#{k.to_s.upcase}"
        obj[key] = v
      end

      options_ptr = GDAL::Options.pointer(converted_options)

      @geocoding_session_pointer = FFI::GDAL.OGRGeocodeCreateSession(options_ptr)
    end

    def c_pointer
      @geocoding_session_pointer
    end

    def destroy!
      FFI::GDAL.OGRGeocodeDestroySession(@geocoding_session_pointer)
    end

    # @param query [String]
    # @param options [Hash]
    # @option options addressdetails [Boolean] +true+ to include a breakdown of
    #   the adddress into elements.  Only works with some geocoding services.
    # @option options countrycodes [Array<String, Symbol>] Limit the search to a
    #   specific country or countries.  Only works with some geocoding services.
    # @option options limit [Fixnum] Limit the number of records returned.  Only
    #   works with some geocoding services.
    # @option options raw_feature ["YES"] Adds a raw feature to the returned
    #   feature that includes that raw XML response body.
    # @option extra_query_parameters [String] Adds params to the GET request.
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
    # @param options [Hash]
    # @option options zoom [Float] Only used by the Nominatim service.
    # @option options raw_feature ["YES"] Adds a raw feature to the returned
    #   feature that includes that raw XML response body.
    # @option extra_query_parameters [String] Adds params to the GET request.
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
