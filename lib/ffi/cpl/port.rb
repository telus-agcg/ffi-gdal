# frozen_string_literal: true

require 'ffi'
require_relative '../gdal'

module FFI
  module CPL
    module Port
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef :int, :GInt32
      typedef :uint, :GUInt32
      typedef :short, :GInt16
      typedef :ushort, :GUInt16
      typedef :uchar, :GByte
      typedef :int, :GBool
      typedef :long_long, :GIntBig
      typedef :ulong_long, :GUIntBig
      typedef :GIntBig, :GPtrDiff_t
    end
  end
end
