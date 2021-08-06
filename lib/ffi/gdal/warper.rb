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
                            FFI::GDAL::GDAL::DataType,
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
      ResampleAlg = enum :GRA_NearestNeighbor, 0,
                         :GRA_Bilinear, 1,
                         :GRA_Cubic, 2,
                         :GRA_CubicSpline, 3,
                         :GRA_Lanczos, 4,
                         :GRA_Average, 5,
                         :GRA_Mode, 6

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :GDALCreateWarpOptions, [], FFI::GDAL::WarpOptions.ptr
      # TODO: use this
      attach_function :GDALDestroyWarpOptions, [FFI::GDAL::WarpOptions.ptr], :void
      # TODO: wrap
      attach_function :GDALCloneWarpOptions, [FFI::GDAL::WarpOptions.by_ref], FFI::GDAL::WarpOptions.ptr

      attach_function :GDALCreateWarpOperation,
                      [FFI::GDAL::WarpOptions.by_ref],
                      :GDALWarpOperationH
      attach_function :GDALDestroyWarpOperation, %i[GDALWarpOperationH], :void

      attach_function :GDALReprojectImage,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        ResampleAlg,
                        :double,
                        :double,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer,
                        FFI::GDAL::WarpOptions.ptr
                      ],
                      CPL::Error::CPLErr
      attach_function :GDALCreateAndReprojectImage,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        :string,
                        :string,
                        FFI::GDAL::GDAL.find_type(:GDALDriverH),
                        :pointer,
                        ResampleAlg,
                        :double,
                        :double,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer,
                        FFI::GDAL::WarpOptions.ptr
                      ],
                      CPL::Error::CPLErr
      # TODO: wrap
      attach_function :GDALAutoCreateWarpedVRT,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        :string,
                        ResampleAlg,
                        :double,
                        FFI::GDAL::WarpOptions.ptr
                      ],
                      FFI::GDAL::GDAL.find_type(:GDALDatasetH)
      # TODO: wrap
      attach_function :GDALCreateWarpedVRT,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :int,
                        :int,
                        :double,
                        FFI::GDAL::WarpOptions.ptr
                      ],
                      FFI::GDAL::GDAL.find_type(:GDALDatasetH)
      # TODO: wrap
      attach_function :GDALInitializeWarpedVRT,
                      [FFI::GDAL::GDAL.find_type(:GDALDatasetH), FFI::GDAL::WarpOptions.ptr],
                      CPL::Error::CPLErr

      attach_function :GDALChunkAndWarpImage,
                      %i[GDALWarpOperationH int int int int],
                      CPL::Error::CPLErr
      attach_function :GDALChunkAndWarpMulti,
                      %i[GDALWarpOperationH int int int int],
                      CPL::Error::CPLErr
      attach_function :GDALWarpRegion,
                      %i[GDALWarpOperationH int int int int int int int int],
                      CPL::Error::CPLErr
      attach_function :GDALWarpRegionToBuffer,
                      [:GDALWarpOperationH, :int, :int, :int, :int, :pointer, GDAL::DataType, :int, :int, :int, :int],
                      CPL::Error::CPLErr
    end
  end
end
