# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    module Conv
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      callback :CPLFileFinder, %i[string string], :pointer

      #---------
      # Config
      #---------
      attach_gdal_function :CPLVerifyConfiguration, %i[], :void
      attach_gdal_function :CPLGetConfigOption, %i[string string], :strptr
      attach_gdal_function :CPLSetConfigOption, %i[string string], :void
      attach_gdal_function :CPLSetThreadLocalConfigOption, %i[string string], :void
      attach_gdal_function :CPLFreeConfig, %i[], :void

      #---------
      # Memory
      #---------
      attach_gdal_function :CPLMalloc, %i[size_t], :pointer
      attach_gdal_function :CPLCalloc, %i[size_t size_t], :pointer
      attach_gdal_function :CPLRealloc, %i[pointer size_t], :pointer

      #---------
      # Strings
      #---------
      attach_gdal_function :CPLStrdup, %i[string], :string
      attach_gdal_function :CPLStrlwr, %i[string], :string
      attach_gdal_function :CPLFGets, %i[string int pointer], :string
      attach_gdal_function :CPLReadLine, %i[pointer], :strptr
      attach_gdal_function :CPLReadLineL, %i[pointer], :strptr
      attach_gdal_function :CPLReadLine2L, %i[pointer int pointer], :strptr
      attach_gdal_function :CPLAtof, %i[string], :double
      attach_gdal_function :CPLAtofDelim, %i[string char], :double
      attach_gdal_function :CPLStrtod, %i[string pointer], :double
      attach_gdal_function :CPLStrtodDelim, %i[string pointer char], :double
      attach_gdal_function :CPLStrtof, %i[string pointer], :float
      attach_gdal_function :CPLStrtofDelim, %i[string pointer char], :float
      attach_gdal_function :CPLAtofM, %i[string], :double
      # Caller responsible to free this buffer with CPLFree().
      attach_gdal_function :CPLScanString, %i[string int int int], :pointer
      attach_gdal_function :CPLScanDouble, %i[string int], :double
      attach_gdal_function :CPLScanLong, %i[string int], :long
      attach_gdal_function :CPLScanULong, %i[string int], :ulong
      attach_gdal_function :CPLScanUIntBig, %i[string int], ::FFI::CPL::Port.find_type(:GUIntBig)
      attach_gdal_function :CPLScanPointer, %i[string int], :pointer
      attach_gdal_function :CPLPrintString, %i[string string int], :int
      attach_gdal_function :CPLPrintStringFill, %i[string string int], :int

      #---------
      # Numbers to strings
      #---------
      attach_gdal_function :CPLPrintInt32, [:string, Port.find_type(:GInt32), :int], :int
      attach_gdal_function :CPLPrintUIntBig, [:string, Port.find_type(:GUIntBig), :int], :int
      attach_gdal_function :CPLPrintDouble, %i[string string double string], :int
      attach_gdal_function :CPLPrintTime, %i[string int string pointer string], :int
      attach_gdal_function :CPLPrintPointer, %i[string pointer int], :int
      attach_gdal_function :CPLGetSymbol, %i[string string], :pointer

      #---------
      # Files
      #---------
      attach_gdal_function :CPLGetExecPath, %i[string int], :int
      attach_gdal_function :CPLGetPath, %i[string], :strptr
      attach_gdal_function :CPLGetDirname, %i[string], :strptr
      attach_gdal_function :CPLGetFilename, %i[string], :strptr
      attach_gdal_function :CPLGetBasename, %i[string], :strptr
      attach_gdal_function :CPLGetExtension, %i[string], :strptr
      # User is responsible to free that buffer after usage with CPLFree() function.
      attach_gdal_function :CPLGetCurrentDir, [], :pointer
      attach_gdal_function :CPLFormFilename, %i[string string string], :strptr
      attach_gdal_function :CPLFormCIFilename, %i[string string string], :strptr
      attach_gdal_function :CPLResetExtension, %i[string string], :strptr
      attach_gdal_function :CPLProjectRelativeFilename, %i[string string], :strptr
      attach_gdal_function :CPLIsFilenameRelative, %i[string], :int
      attach_gdal_function :CPLExtractRelativePath, %i[string string pointer], :strptr
      attach_gdal_function :CPLCleanTrailingSlash, %i[string], :strptr
      attach_gdal_function :CPLCorrespondingPaths, %i[string string pointer], :pointer
      attach_gdal_function :CPLCheckForFile, %i[string string], :int
      attach_gdal_function :CPLGenerateTempFilename, %i[string], :strptr
      attach_gdal_function :CPLFindFile, %i[string string], :strptr
      attach_gdal_function :CPLDefaultFindFile, %i[string string], :strptr
      attach_gdal_function :CPLPushFileFinder, %i[CPLFileFinder], :void
      attach_gdal_function :CPLPopFileFinder, %i[], :CPLFileFinder
      attach_gdal_function :CPLPushFinderLocation, %i[string], :void
      attach_gdal_function :CPLPopFinderLocation, %i[], :void
      attach_gdal_function :CPLFinderClean, %i[], :void
      attach_gdal_function :CPLStat, %i[string pointer], :int
      attach_gdal_function :CPLOpenShared, %i[string string bool], :pointer
      attach_gdal_function :CPLCloseShared, %i[pointer], :void
      attach_gdal_function :CPLGetSharedList, %i[pointer], :pointer
      attach_gdal_function :CPLDumpSharedList, %i[pointer], :void
      attach_gdal_function :CPLCleanupSharedFileMutex, %i[], :void

      attach_gdal_function :CPLDMSToDec, %i[string], :double
      attach_gdal_function :CPLDecToDMS, %i[double string int], :string
      attach_gdal_function :CPLPackedDMSToDec, %i[double], :double
      attach_gdal_function :CPLDecToPackedDMS, %i[double], :string
      attach_gdal_function :CPLStringToComplex, %i[string pointer pointer], :void
      attach_gdal_function :CPLUnlinkTree, %i[string], :int
      attach_gdal_function :CPLCopyFile, %i[string string], :int
      attach_gdal_function :CPLMoveFile, %i[string string], :int

      #---------
      # Zip Files
      #---------
      attach_gdal_function :CPLCreateZip, %i[string pointer], :pointer
      attach_gdal_function :CPLCreateFileInZip, %i[pointer string pointer], FFI::CPL::Error::CPLErr
      attach_gdal_function :CPLWriteFileInZip, %i[pointer pointer int], FFI::CPL::Error::CPLErr
      attach_gdal_function :CPLCloseFileInZip, %i[pointer], FFI::CPL::Error::CPLErr
      attach_gdal_function :CPLCloseZip, %i[pointer], FFI::CPL::Error::CPLErr
      attach_gdal_function :CPLZLibDeflate,
                           %i[pointer size_t int pointer size_t pointer],
                           :pointer
      attach_gdal_function :CPLZLibInflate,
                           %i[pointer size_t pointer size_t pointer],
                           :pointer

      attach_gdal_function :CPLValidateXML, %i[string string pointer], :int
      attach_gdal_function :CPLsetlocale, %i[int string], :strptr

      attach_gdal_function :CPLCleanupSetlocaleMutex, %i[], :void
    end
  end
end
