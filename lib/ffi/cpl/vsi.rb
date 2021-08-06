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
      attach_function :VSIStat, %i[string pointer], :int

      attach_function :VSICalloc, %i[size_t size_t], :pointer
      attach_function :VSIMalloc, %i[size_t], :pointer
      attach_function :VSIFree, %i[pointer], :void
      attach_function :VSIRealloc, %i[pointer size_t], :pointer
      attach_function :VSIStrdup, %i[string], :strptr
      attach_function :VSIMalloc2, %i[size_t size_t], :pointer
      attach_function :VSIMalloc3, %i[size_t size_t size_t], :pointer
    end
  end
end
