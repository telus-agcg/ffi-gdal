module FFI
  module GDAL
    module CPLError
      extend FFI::Library
      ffi_lib 'gdal'

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      CPLErr = enum :none, 0,
        :debug, 1,
        :warning, 2,
        :failure, 3,
        :fatal, 4

      callback :CPLErrorHandler, [CPLErr, :int, :string], :void

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :CPLError, [CPLErr, :int, :string], :void
      attach_function :CPLErrorV, [CPLErr, :int, :string, :pointer], :void
      attach_function :CPLEmergencyError, [:void], :void
      attach_function :CPLErrorReset, [:void], :void

      attach_function :CPLGetLastErrorNo, [:void], :int
      attach_function :CPLGetLastErrorType, [:void], CPLErr
      attach_function :CPLGetLastErrorMsg, [:void], :string

      attach_function :CPLGetErrorHandlerUserData, [:void], :pointer
      #attach_function :CPLErrorSetState,
        #[CPLErr, :int, :string],
        #:void
      attach_function :CPLCleanupErrorMutex, [:void], :void
      attach_function :CPLLoggingErrorHandler,
        [CPLErr, :int, :string],
        :void
      attach_function :CPLDefaultErrorHandler,
        [CPLErr, :int, :string],
        :void
      attach_function :CPLQuietErrorHandler,
        [CPLErr, :int, :string],
        :void
      attach_function :CPLTurnFailureIntoWarning, [:int], :void

      attach_function :CPLSetErrorHandler,
        [:CPLErrorHandler],
        :CPLErrorHandler
      attach_function :CPLSetErrorHandlerEx,
        [:CPLErrorHandler, :pointer],
        :CPLErrorHandler
      attach_function :CPLPushErrorHandler,
        [:CPLErrorHandler],
        :void
      attach_function :CPLPushErrorHandlerEx,
        [:CPLErrorHandler, :pointer],
        :void
      attach_function :CPLPopErrorHandler, [:void], :void

      attach_function :CPLDebug, [:string, :string], :void
      attach_function :_CPLAssert, [:string, :string, :int], :void
    end
  end
end
