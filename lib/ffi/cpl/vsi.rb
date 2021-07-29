# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    module VSI
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #------------------------------------------------------------------------
      # Defines
      #------------------------------------------------------------------------
      STAT_EXISTS_FLAG = 0x1
      STAT_NATURE_FLAG = 0x2
      STAT_SIZE_FLAG = 0x4

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef ::FFI::CPL::Port.find_type(:GUIntBig), :vsi_l_offset
      callback :VSIWriteFunction, %i[pointer size_t size_t pointer], :pointer

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_gdal_function :VSIFOpen, %i[string string], :pointer
      attach_gdal_function :VSIFClose, %i[pointer], :int
      attach_gdal_function :VSIFSeek, %i[pointer long int], :int
      attach_gdal_function :VSIFTell, %i[pointer], :long
      attach_gdal_function :VSIRewind, %i[pointer], :void
      attach_gdal_function :VSIFFlush, %i[pointer], :void
      attach_gdal_function :VSIFRead, %i[pointer size_t size_t pointer], :size_t
      attach_gdal_function :VSIFWrite, %i[pointer size_t size_t pointer], :size_t
      attach_gdal_function :VSIFGets, %i[pointer int pointer], :string
      attach_gdal_function :VSIFPuts, %i[string pointer], :int
      attach_gdal_function :VSIFPrintf, %i[pointer string varargs], :int
      attach_gdal_function :VSIFGetc, %i[pointer], :int
      attach_gdal_function :VSIFPutc, %i[int pointer], :int

      attach_gdal_function :VSIUngetc, %i[int pointer], :int
      attach_gdal_function :VSIFEof, %i[pointer], :int
      attach_gdal_function :VSIStat, %i[string pointer], :int

      attach_gdal_function :VSIFOpenL, %i[string string], :pointer
      attach_gdal_function :VSIFCloseL, %i[pointer], :int
      attach_gdal_function :VSIFSeekL, %i[pointer vsi_l_offset int], :int
      attach_gdal_function :VSIFTellL, %i[pointer], :vsi_l_offset
      attach_gdal_function :VSIRewindL, %i[pointer], :void
      attach_gdal_function :VSIFReadL, %i[pointer size_t size_t pointer], :size_t
      attach_gdal_function :VSIFReadMultiRangeL,
                           %i[int pointer pointer pointer pointer],
                           :int
      attach_gdal_function :VSIFWriteL, %i[pointer size_t size_t pointer], :size_t
      attach_gdal_function :VSIFEofL, %i[pointer], :int
      attach_gdal_function :VSIFTruncateL, %i[pointer vsi_l_offset], :int
      attach_gdal_function :VSIFFlushL, %i[pointer], :int
      attach_gdal_function :VSIFPrintfL, %i[pointer string varargs], :int
      attach_gdal_function :VSIFPutcL, %i[int pointer], :int
      attach_gdal_function :VSIIngestFile,
                           [:pointer, :string, :pointer, :pointer, Port.find_type(:GIntBig)],
                           :int
      attach_gdal_function :VSIStatL, %i[string pointer], :int
      attach_gdal_function :VSIStatExL, %i[string pointer int], :int

      attach_gdal_function :VSIIsCaseSensitiveFS, %i[string], :int
      attach_gdal_function :VSIFGetNativeFileDescriptorL, %i[pointer], :pointer

      attach_gdal_function :VSICalloc, %i[size_t size_t], :pointer
      attach_gdal_function :VSIMalloc, %i[size_t], :pointer
      attach_gdal_function :VSIFree, %i[pointer], :void
      attach_gdal_function :VSIRealloc, %i[pointer size_t], :pointer
      attach_gdal_function :VSIStrdup, %i[string], :strptr
      attach_gdal_function :VSIMalloc2, %i[size_t size_t], :pointer
      attach_gdal_function :VSIMalloc3, %i[size_t size_t size_t], :pointer

      attach_gdal_function :VSIReadDir, %i[string], :pointer
      attach_gdal_function :VSIReadDirRecursive, %i[string], :pointer
      attach_gdal_function :VSIMkdir, %i[string long], :int
      attach_gdal_function :VSIRmdir, %i[string], :int
      attach_gdal_function :VSIUnlink, %i[string], :int
      attach_gdal_function :VSIRename, %i[string string], :int

      attach_gdal_function :VSIStrerror, %i[int], :strptr

      attach_gdal_function :VSIInstallMemFileHandler, [], :void
      attach_gdal_function :VSIInstallLargeFileHandler, [], :void
      attach_gdal_function :VSIInstallSubFileHandler, [], :void
      attach_gdal_function :VSIInstallCurlFileHandler, [], :void
      attach_gdal_function :VSIInstallCurlStreamingFileHandler, [], :void
      attach_gdal_function :VSIInstallGZipFileHandler, [], :void
      attach_gdal_function :VSIInstallZipFileHandler, [], :void
      attach_gdal_function :VSIInstallStdinHandler, [], :void
      attach_gdal_function :VSIInstallStdoutHandler, [], :void
      attach_gdal_function :VSIInstallSparseFileHandler, [], :void
      attach_gdal_function :VSIInstallTarFileHandler, [], :void
      attach_gdal_function :VSICleanupFileManager, [], :void

      attach_gdal_function :VSIFileFromMemBuffer,
                           %i[string pointer vsi_l_offset int],
                           :pointer
      attach_gdal_function :VSIGetMemFileBuffer,
                           %i[string pointer int],
                           :pointer
      attach_gdal_function :VSIStdoutSetRedirection,
                           %i[VSIWriteFunction pointer],
                           :pointer

      attach_gdal_function :VSITime, %i[pointer], :ulong
      attach_gdal_function :VSICTime, %i[ulong], :strptr
      attach_gdal_function :VSIGMTime, %i[pointer pointer], :pointer
      attach_gdal_function :VSILocalTime, %i[pointer pointer], :pointer
    end
  end
end
