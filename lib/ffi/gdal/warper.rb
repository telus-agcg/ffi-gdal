require 'ffi'
require_relative '../cpl/error'

module FFI
  module GDAL
    autoload :WarpOptions, File.expand_path('warp_options', __dir__)

    module Warper
      extend ::FFI::Library
      ffi_lib [FFI::CURRENT_PROCESS, FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      typedef :pointer, :GDALWarpOperationH
      callback :GDALMaskFunc,
        [
          :pointer,
          :int,
          FFI::GDAL::DataType,
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
      attach_function :GDALSerializeWarpOptions,
        [FFI::GDAL::WarpOptions.ptr],
        FFI::CPL::XMLNode.ptr

      attach_function :GDALCreateWarpOperation,
        [FFI::GDAL::WarpOptions.ptr],
        :GDALWarpOperationH
      attach_function :GDALDestroyWarpOperation, [:GDALWarpOperationH], :void

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
        [:GDALWarpOperationH, :int, :int, :int, :int, :pointer, DataType, :int, :int, :int, :int],
        CPL::Error::CPLErr
    end
  end
end
