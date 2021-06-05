# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module GDAL
    module Warper
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef :pointer, :GDALWarpOperationH
      MaskFunc = callback :GDALMaskFunc,
                          [
                            :pointer,
                            :int,
                            FFI::GDAL::GDAL.enum_type(:GDALDataType),
                            :int,
                            :int,
                            :int,
                            :int,
                            :pointer,
                            :int,
                            :pointer
                          ],
                          :pointer

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      ResampleAlg = enum :GDALResampleAlg, [:GRA_NearestNeighbor, 0,
                                            :GRA_Bilinear, 1,
                                            :GRA_Cubic, 2,
                                            :GRA_CubicSpline, 3,
                                            :GRA_Lanczos, 4,
                                            :GRA_Average, 5,
                                            :GRA_Mode, 6,
                                            :GRA_Max,
                                            :GRA_Min,
                                            :GRA_Med,
                                            :GRA_Q1,
                                            :GRA_Q3,
                                            :GRA_Sum,
                                            :GRA_RMS]

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_gdal_function :GDALCreateWarpOptions, [], FFI::GDAL::WarpOptions.ptr
      attach_gdal_function :GDALDestroyWarpOptions, [FFI::GDAL::WarpOptions.ptr], :void
      attach_gdal_function :GDALCloneWarpOptions, [FFI::GDAL::WarpOptions.ptr], FFI::GDAL::WarpOptions.ptr
      attach_gdal_function :GDALSerializeWarpOptions,
                           [FFI::GDAL::WarpOptions.ptr],
                           FFI::CPL::XMLNode.ptr
      attach_gdal_function :GDALDeserializeWarpOptions,
                           [FFI::CPL::XMLNode.ptr],
                           FFI::GDAL::WarpOptions.ptr

      attach_gdal_function :GDALCreateWarpOperation,
                           [FFI::GDAL::WarpOptions.ptr],
                           :GDALWarpOperationH
      attach_gdal_function :GDALDestroyWarpOperation, %i[GDALWarpOperationH], :void

      attach_gdal_function :GDALWarpNoDataMasker,
                           [:pointer, :int, FFI::GDAL::GDAL.enum_type(:GDALDataType), :int, :int, :int, :int, :pointer,
                            :int, :pointer],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALWarpDstAlphaMasker,
                           [:pointer, :int, FFI::GDAL::GDAL.enum_type(:GDALDataType), :int, :int, :int, :int, :pointer,
                            :int, :pointer],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALWarpSrcAlphaMasker,
                           [:pointer, :int, FFI::GDAL::GDAL.enum_type(:GDALDataType), :int, :int, :int, :int, :pointer,
                            :int, :pointer],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALWarpSrcMaskMasker,
                           [:pointer, :int, FFI::GDAL::GDAL.enum_type(:GDALDataType), :int, :int, :int, :int, :pointer,
                            :int, :pointer],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALWarpCutlineMasker,
                           [:pointer, :int, FFI::GDAL::GDAL.enum_type(:GDALDataType), :int, :int, :int, :int, :pointer,
                            :int, :pointer],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALReprojectImage,
                           [
                             FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                             :string,
                             FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                             :string,
                             enum_type(:GDALResampleAlg),
                             :double,
                             :double,
                             FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                             :pointer,
                             FFI::GDAL::WarpOptions.ptr
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALCreateAndReprojectImage,
                           [
                             FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                             :string,
                             :string,
                             :string,
                             FFI::GDAL::GDAL.find_type(:GDALDriverH),
                             :pointer,
                             enum_type(:GDALResampleAlg),
                             :double,
                             :double,
                             FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                             :pointer,
                             FFI::GDAL::WarpOptions.ptr
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALAutoCreateWarpedVRT,
                           [
                             FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                             :string,
                             :string,
                             enum_type(:GDALResampleAlg),
                             :double,
                             FFI::GDAL::WarpOptions.ptr
                           ],
                           FFI::GDAL::GDAL.find_type(:GDALDatasetH)
      attach_gdal_function :GDALCreateWarpedVRT,
                           [
                             FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                             :int,
                             :int,
                             :double,
                             FFI::GDAL::WarpOptions.ptr
                           ],
                           FFI::GDAL::GDAL.find_type(:GDALDatasetH)
      attach_gdal_function :GDALInitializeWarpedVRT,
                           [FFI::GDAL::GDAL.find_type(:GDALDatasetH), FFI::GDAL::WarpOptions.ptr],
                           FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALChunkAndWarpImage,
                           %i[GDALWarpOperationH int int int int],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALChunkAndWarpMulti,
                           %i[GDALWarpOperationH int int int int],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALWarpRegion,
                           %i[GDALWarpOperationH int int int int int int int int],
                           FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALWarpRegionToBuffer,
                           [
                             :GDALWarpOperationH,
                             :int, :int, :int, :int,
                             :pointer, FFI::GDAL::GDAL.enum_type(:GDALDataType),
                             :int, :int, :int, :int
                           ],
                           FFI::CPL::Error.enum_type(:CPLErr)
    end
  end
end
