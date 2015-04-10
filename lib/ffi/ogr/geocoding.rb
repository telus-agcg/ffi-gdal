require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative 'api'

module FFI
  module OGR
    module Geocoding
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

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
        FFI::OGR::API.find_type(:OGRLayerH)
      attach_function :OGRGeocodeReverse,
        %i[OGRGeocodingSessionH double double pointer],
        FFI::OGR::API.find_type(:OGRLayerH)
      attach_function :OGRGeocodeFreeResult, [FFI::OGR::API.find_type(:OGRLayerH)], :void
    end
  end
end
