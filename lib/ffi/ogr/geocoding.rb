# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module OGR
    module Geocoding
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef :pointer, :OGRGeocodingSessionH

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_gdal_function :OGRGeocodeCreateSession, %i[pointer], :OGRGeocodingSessionH
      attach_gdal_function :OGRGeocodeDestroySession, %i[OGRGeocodingSessionH], :void
      attach_gdal_function :OGRGeocode,
                      %i[OGRGeocodingSessionH string pointer pointer],
                      FFI::OGR::API.find_type(:OGRLayerH)
      attach_gdal_function :OGRGeocodeReverse,
                      %i[OGRGeocodingSessionH double double pointer],
                      FFI::OGR::API.find_type(:OGRLayerH)
      attach_gdal_function :OGRGeocodeFreeResult, [FFI::OGR::API.find_type(:OGRLayerH)], :void
    end
  end
end
