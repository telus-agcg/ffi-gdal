# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    module Conv
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #---------
      # Config
      #---------
      attach_function :CPLGetConfigOption, %i[string string], :strptr
      attach_function :CPLSetConfigOption, %i[string string], :void
      attach_function :CPLSetThreadLocalConfigOption, %i[string string], :void

      #---------
      # Files
      #---------
      # User is responsible to free that buffer after usage with CPLFree() function.
      attach_function :CPLOpenShared, %i[string string bool], :pointer
      attach_function :CPLCloseShared, %i[pointer], :void

      #---------
      # Zip Files
      #---------
      attach_function :CPLCreateZip, %i[string pointer], :pointer
      attach_function :CPLCreateFileInZip, %i[pointer string pointer], FFI::CPL::Error::CPLErr
      attach_function :CPLWriteFileInZip, %i[pointer pointer int], FFI::CPL::Error::CPLErr
      attach_function :CPLCloseFileInZip, %i[pointer], FFI::CPL::Error::CPLErr
      attach_function :CPLCloseZip, %i[pointer], FFI::CPL::Error::CPLErr
      attach_function :CPLZLibDeflate,
                      %i[pointer size_t int pointer size_t pointer],
                      :pointer
      attach_function :CPLZLibInflate,
                      %i[pointer size_t pointer size_t pointer],
                      :pointer

      attach_function :CPLsetlocale, %i[int string], :strptr
    end
  end
end
