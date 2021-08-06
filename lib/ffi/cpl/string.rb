# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    module String
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef :string, :CPLString

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      ValueType = enum :CPL_VALUE_STRING,
                       :CPL_VALUE_REAL,
                       :CPL_VALUE_INTEGER

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :CSLAddString, %i[pointer string], :pointer
      attach_function :CSLCount, %i[pointer], :int
      attach_function :CSLGetField, %i[pointer int], :strptr
      attach_function :CSLDestroy, %i[pointer], :void
      attach_function :CSLDuplicate, %i[pointer], :pointer
      attach_function :CSLMerge, %i[pointer pointer], :pointer
      attach_function :CSLTokenizeString, %i[string], :pointer
      attach_function :CSLTokenizeString2, %i[string string int], :pointer

      attach_function :CSLTestBoolean, %i[string], :bool
      attach_function :CSLFetchBoolean, %i[pointer string int], :bool

      attach_function :CPLParseNameValue, %i[string pointer], :strptr
      attach_function :CSLFetchNameValue, %i[pointer string], :strptr
      attach_function :CSLFetchNameValueDef, %i[pointer string string], :strptr
      attach_function :CSLFetchNameValueMultiple, %i[pointer string], :pointer
      attach_function :CSLAddNameValue, %i[pointer string string], :pointer
      attach_function :CSLSetNameValue, %i[pointer string string], :pointer
      attach_function :CSLSetNameValueSeparator, %i[pointer string], :void

      attach_function :CPLEscapeString, %i[string int int], :strptr
      attach_function :CPLUnescapeString, %i[string pointer int], :strptr
      attach_function :CPLBinaryToHex, %i[int pointer], :strptr
      attach_function :CPLHexToBinary, %i[string pointer], :pointer
      attach_function :CPLBase64Encode, %i[int pointer], :strptr
      attach_function :CPLBase64DecodeInPlace, %i[pointer], :int

      attach_function :CPLGetValueType, %i[string], ValueType

      attach_function :CPLIsUTF8, %i[string int], :bool
      attach_function :CPLStrlenUTF8, %i[string], :int
    end
  end
end
