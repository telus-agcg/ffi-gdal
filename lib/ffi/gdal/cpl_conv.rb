require_relative 'cpl_error'
require_relative 'cpl_vsi'


module FFI
  module GDAL

    def CPLFree(pointer)
      extend CPLVSI
      VSIFree(pointer)
    end

    #------------------------------------------------------------------------
    # cpl_port Typedefs
    #------------------------------------------------------------------------
    typedef :int, :GInt32
    typedef :uint, :GUInt32
    typedef :short, :GInt16
    typedef :ushort, :GUInt16
    typedef :uchar, :GByte
    typedef :int, :GBool
    typedef :long_long, :GIntBig
    typedef :ulong_long, :GUIntBig

    #--------------------------------------------------------------------------
    # Functions
    #--------------------------------------------------------------------------
    callback :CPLFileFinder, %i[string string], :string

    #---------
    # Config
    #---------
    attach_function :CPLVerifyConfiguration, %i[], :void
    attach_function :CPLGetConfigOption, %i[string string], :string
    attach_function :CPLSetConfigOption, %i[string string], :void
    attach_function :CPLSetThreadLocalConfigOption, %i[string string], :void
    attach_function :CPLFreeConfig, %i[], :void

    #---------
    # Memory
    #---------
    attach_function :CPLMalloc, %i[size_t], :pointer
    attach_function :CPLCalloc, %i[size_t size_t], :pointer
    attach_function :CPLRealloc, %i[pointer size_t], :pointer

    #---------
    # Strings
    #---------
    attach_function :CPLStrdup, %i[string], :string
    attach_function :CPLStrlwr, %i[string], :string
    attach_function :CPLFGets, %i[string int pointer], :string
    attach_function :CPLReadLine, %i[pointer], :string
    attach_function :CPLReadLineL, %i[pointer], :string
    attach_function :CPLReadLine2L, %i[pointer int pointer], :string
    attach_function :CPLAtof, %i[string], :double
    attach_function :CPLAtofDelim, %i[string char], :double
    attach_function :CPLStrtod, %i[string pointer], :double
    attach_function :CPLStrtodDelim, %i[string pointer char], :double
    attach_function :CPLStrtof, %i[string pointer], :float
    attach_function :CPLStrtofDelim, %i[string pointer char], :float
    attach_function :CPLAtofM, %i[string], :double
    attach_function :CPLScanString, %i[string int int int], :string
    attach_function :CPLScanDouble, %i[string int], :double
    attach_function :CPLScanLong, %i[string int], :long
    attach_function :CPLScanLong, %i[string int], :ulong
    attach_function :CPLScanUIntBig, %i[string int], :GUIntBig
    attach_function :CPLScanPointer, %i[string int], :pointer
    attach_function :CPLPrintString, %i[string string int], :int
    attach_function :CPLPrintStringFill, %i[string string int], :int

    #---------
    # Numbers to strings
    #---------
    attach_function :CPLPrintInt32, %i[string GInt32 int], :int
    attach_function :CPLPrintUIntBig, %i[string GUIntBig int], :int
    attach_function :CPLPrintDouble, %i[string string double string], :int
    attach_function :CPLPrintTime, %i[string int string pointer string], :int
    attach_function :CPLPrintPointer, %i[string pointer int], :int
    attach_function :CPLGetSymbol, %i[string string], :pointer

    #---------
    # Files
    #---------
    attach_function :CPLGetExecPath, %i[string int], :int
    attach_function :CPLGetPath, %i[string], :string
    attach_function :CPLGetDirname, %i[string], :string
    attach_function :CPLGetFilename, %i[string], :string
    attach_function :CPLGetBasename, %i[string], :string
    attach_function :CPLGetExtension, %i[string], :string
    attach_function :CPLGetCurrentDir, [], :string
    attach_function :CPLFormFilename, %i[string string string], :string
    attach_function :CPLFormCIFilename, %i[string string string], :string
    attach_function :CPLResetExtension, %i[string string], :string
    attach_function :CPLProjectRelativeFilename, %i[string string], :string
    attach_function :CPLIsFilenameRelative, %i[string], :int
    attach_function :CPLExtractRelativePath, %i[string string pointer], :string
    attach_function :CPLCleanTrailingSlash, %i[string], :string
    attach_function :CPLCorrespondingPaths, %i[string string pointer], :pointer
    attach_function :CPLCheckForFile, %i[string string], :int
    attach_function :CPLGenerateTempFilename, %i[string], :string
    attach_function :CPLFindFile, %i[string string], :string
    attach_function :CPLDefaultFindFile, %i[string string], :string
    attach_function :CPLPushFileFinder, %i[CPLFileFinder], :void
    attach_function :CPLPopFileFinder, %i[], :CPLFileFinder
    attach_function :CPLPushFinderLocation, %i[string], :void
    attach_function :CPLPopFinderLocation, %i[], :void
    attach_function :CPLFinderClean, %i[], :void
    attach_function :CPLStat, %i[string pointer], :int
    attach_function :CPLOpenShared, %i[string string int], :pointer
    attach_function :CPLCloseShared, %i[pointer], :void
    attach_function :CPLGetSharedList, %i[pointer], :pointer
    attach_function :CPLDumpSharedList, %i[pointer], :void
    #attach_function :CPLCleanupSharedFileMutex, %i[], :void

    attach_function :CPLDMSToDec, %i[string], :double
    attach_function :CPLDecToDMS, %i[double string int], :string
    attach_function :CPLPackedDMSToDec, %i[double], :double
    attach_function :CPLDecToPackedDMS, %i[double], :string
    attach_function :CPLStringToComplex, %i[string pointer pointer], :void
    attach_function :CPLUnlinkTree, %i[string], :int
    attach_function :CPLCopyFile, %i[string string], :int
    attach_function :CPLMoveFile, %i[string string], :int

    #---------
    # Zip Files
    #---------
    #attach_function :CPLCreateZip, %i[string pointer], :pointer
    #attach_function :CPLCreateFileInZip, %i[pointer string pointer], CPLErr
    #attach_function :CPLWriteFileInZip, %i[pointer pointer int], CPLErr
    #attach_function :CPLCloseFileInZip, %i[pointer], CPLErr
    #attach_function :CPLCloseZip, %i[pointer], CPLErr
    #attach_function :CPLZLibDeflate,
    #  %i[pointer size_t int pointer size_t pointer],
    #  :pointer
    #attach_function :CPLZLibInflate,
    #  %i[pointer size_t pointer size_t pointer],
    #  :pointer

    #attach_function :CPLValidateXML, %i[string string pointer], :int
    #attach_function :CPLsetlocale, %i[int string], :string

    #attach_function :CPLCleanupSetlocaleMutex, %i[], :void
  end
end
