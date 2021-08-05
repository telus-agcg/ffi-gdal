# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    module Progress
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_function :GDALCreateScaledProgress,
                      [:double, :double, FFI::GDAL::GDAL.find_type(:GDALProgressFunc), :pointer],
                      :pointer
      attach_function :GDALDestroyScaledProgress,
                      %i[pointer],
                      :void
      ScaledProgress = attach_function :GDALScaledProgress,
                                       %i[double string pointer],
                                       :int
      TermProgress = attach_function :GDALTermProgress,
                                     %i[double string pointer],
                                     :int
    end
  end
end
