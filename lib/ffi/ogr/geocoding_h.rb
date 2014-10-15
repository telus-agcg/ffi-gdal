module FFI
  module GDAL
    #------------------------------------------------------------------------
    # Typedefs
    #------------------------------------------------------------------------
    typedef :pointer, :OGRGeocodingSessionH

    #------------------------------------------------------------------------
    # Functions
    #------------------------------------------------------------------------
    attach_function :OGRGeocodeCreateSession, %i[pointer], :OGRGeocodingSessionH
    attach_function :OGRGeocodeDestroySession, %i[OGRGeocodingSessionH], :void
    attach_function :OGRGeocode,
      %i[OGRGeocodingSessionH string pointer pointer],
      :OGRLayerH
    attach_function :OGRGeocodeReverse,
      %i[OGRGeocodingSessionH double double pointer],
      :OGRLayerH
    attach_function :OGRGeocodeFreeResult, %i[OGRLayerH], :void
  end
end
