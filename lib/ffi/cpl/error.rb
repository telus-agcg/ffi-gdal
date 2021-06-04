# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    module Error
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      callback :CPLErrorHandler, [enum_type(:CPLErr), :int, :string], :void

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      CPLErr = enum :CPLErr, %i[CE_None CE_Debug CE_Warning CE_Failure CE_Fatal]

      # CPLErrorNum is a typedef to an int in GDAL, but turning into an enum
      # here for convenience.
      CPLErrorNum = enum :CPLE_None,
                         :CPLE_AppDefined,
                         :CPLE_OutOfMemory,
                         :CPLE_FileIO,
                         :CPLE_OpenFailed,
                         :CPLE_IllegalArg,
                         :CPLE_NotSupported,
                         :CPLE_AssertionFailed,
                         :CPLE_NoWriteAccess,
                         :CPLE_UserInterrupt,
                         :CPLE_ObjectNull

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_gdal_function :CPLCleanupErrorMutex, [], :void
      attach_gdal_function :CPLDefaultErrorHandler, [enum_type(:CPLErr), :int, :string], :void
      attach_gdal_function :CPLEmergencyError, [], :void
      attach_gdal_function :CPLError, [enum_type(:CPLErr), :int, :string], :void
      attach_gdal_function :CPLErrorReset, [], :void
      attach_gdal_function :CPLErrorV, [enum_type(:CPLErr), :int, :string, :pointer], :void
      attach_gdal_function :CPLGetErrorHandlerUserData, [], :pointer
      attach_gdal_function :CPLGetLastErrorNo, [], :int
      attach_gdal_function :CPLGetLastErrorType, [], enum_type(:CPLErr)
      attach_gdal_function :CPLGetLastErrorMsg, [], :strptr

      attach_gdal_function :CPLLoggingErrorHandler, [enum_type(:CPLErr), :int, :string], :void
      attach_gdal_function :CPLPopErrorHandler, [], :void
      attach_gdal_function :CPLPushErrorHandler, [:CPLErrorHandler], :void
      attach_gdal_function :CPLPushErrorHandlerEx, %i[CPLErrorHandler pointer], :void
      attach_gdal_function :CPLQuietErrorHandler, [enum_type(:CPLErr), :int, :string], :void
      attach_gdal_function :CPLSetErrorHandler, [:CPLErrorHandler], find_type(:CPLErrorHandler)
      attach_gdal_function :CPLSetErrorHandlerEx, %i[CPLErrorHandler pointer], find_type(:CPLErrorHandler)
      attach_gdal_function :CPLTurnFailureIntoWarning, [:int], :void
    end
  end
end
