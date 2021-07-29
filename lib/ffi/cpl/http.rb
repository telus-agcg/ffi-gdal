# frozen_string_literal: true

require 'ffi'
require_relative 'http_result'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    module HTTP
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_gdal_function :CPLHTTPEnabled, [], :bool
      attach_gdal_function :CPLHTTPFetch, %i[string pointer], HTTPResult.ptr
      attach_gdal_function :CPLHTTPCleanup, [], :void
      attach_gdal_function :CPLHTTPDestroyResult, [HTTPResult.ptr], :void
      attach_gdal_function :CPLHTTPParseMultipartMime, [HTTPResult.ptr], :bool

      attach_gdal_function :GOA2GetAuthorizationURL, %i[string], :strptr
      attach_gdal_function :GOA2GetRefreshToken, %i[string string], :strptr
      attach_gdal_function :GOA2GetAccessToken, %i[string string], :strptr
    end
  end
end
