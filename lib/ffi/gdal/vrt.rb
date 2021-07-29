# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module GDAL
    module VRT
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #-------------------------------------------------------------------------
      # Typedefs
      #-------------------------------------------------------------------------
      typedef :pointer, :VRTDriverH

      typedef :pointer, :VRTSourceH
      typedef :pointer, :VRTSimpleSourceH
      typedef :pointer, :VRTAveragedSourceH
      typedef :pointer, :VRTComplexSourceH
      typedef :pointer, :VRTFilteredSourceH
      typedef :pointer, :VRTKernelFilteredSourceH
      typedef :pointer, :VRTAverageFilteredSourceH
      typedef :pointer, :VRTFuncSourceH

      typedef :pointer, :VRTDatasetH
      typedef :pointer, :VRTWarpedDatasetH

      typedef :pointer, :VRTRasterBandH
      typedef :pointer, :VRTSourcedRasterBandH
      typedef :pointer, :VRTWarpedRasterBandH
      typedef :pointer, :VRTDerivedRasterBandH
      typedef :pointer, :VRTRawRasterBandH

      callback :VRTImageReadFunc,
               %i[pointer int int int int pointer],
               FFI::CPL::Error.enum_type(:CPLErr)

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_gdal_function :GDALRegister_VRT, [], :void
      attach_gdal_function :VRTCreate, %i[int int], :VRTDatasetH
      attach_gdal_function :VRTFlushCache, %i[VRTDatasetH], :void
      attach_gdal_function :VRTSerializeToXML, %i[VRTDatasetH string], CPL::XMLNode.ptr

      attach_gdal_function :VRTAddBand,
                           [:VRTDatasetH, FFI::GDAL::GDAL.enum_type(:GDALDataType), :pointer],
                           :int

      attach_gdal_function :VRTAddSource,
                           %i[VRTSourcedRasterBandH VRTSourceH],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :VRTAddSimpleSource,
                           [
                             :VRTSourcedRasterBandH, # hVRTBand
                             FFI::GDAL::GDAL.find_type(:GDALRasterBandH), # hSrcBand
                             :int,                               # nSrcXOff
                             :int,                               # nSrcYOff
                             :int,                               # nSrcXSize
                             :int,                               # nSrcYSize
                             :int,                               # nDstXOff
                             :int,                               # nDstYOff
                             :int,                               # nDstXSize
                             :int,                               # nDstYSize
                             :string,                            # pszResampling
                             :double                             # dfNoDataValue
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :VRTAddComplexSource,
                           [
                             :VRTSourcedRasterBandH,             # hVRTBand
                             FFI::GDAL::GDAL.find_type(:GDALRasterBandH), # hSrcBand
                             :int,                               # nSrcXOff
                             :int,                               # nSrcYOff
                             :int,                               # nSrcXSize
                             :int,                               # nSrcYSize
                             :int,                               # nDstXOff
                             :int,                               # nDstYOff
                             :int,                               # nDstXSize
                             :int,                               # nDstYSize
                             :double,                            # dfScaleOff
                             :double,                            # dfScaleRation
                             :double                             # dfNoDataValue
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :VRTAddFuncSource,
                           %i[VRTSourcedRasterBandH VRTImageReadFunc pointer double],
                           FFI::CPL::Error.enum_type(:CPLErr)
    end
  end
end
