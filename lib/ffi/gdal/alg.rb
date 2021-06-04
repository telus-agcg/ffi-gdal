# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'

module FFI
  module GDAL
    module Alg
      extend FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      # -----------------------------------------------------------------------
      # Enums
      # -----------------------------------------------------------------------
      GridAlgorithm = enum :GDALGridAlgorithm, [:GGA_InverseDistanceToAPower, 1,
                                                :GGA_MovingAverage, 2,
                                                :GGA_NearestNeighbor, 3,
                                                :GGA_MetricMinimum, 4,
                                                :GGA_MetricMaximum, 5,
                                                :GGA_MetricRange, 6,
                                                :GGA_MetricCount, 7,
                                                :GGA_MetricAverageDistance, 8,
                                                :GGA_MetricAverageDistancePts, 9]

      # -----------------------------------------------------------------------
      # Typedefs
      # -----------------------------------------------------------------------
      callback :GDALTransformerFunc,
               %i[pointer bool int pointer pointer pointer pointer],
               :int
      callback :GDALContourWriter,
               %i[double int pointer pointer pointer],
               FFI::CPL::Error.enum_type(:CPLErr)
      typedef :pointer, :GDALContourGeneratorH

      # -----------------------------------------------------------------------
      # Functions
      # -----------------------------------------------------------------------
      attach_gdal_function :GDALDestroyTransformer, %i[pointer], :void

      attach_gdal_function :GDALChecksumImage,
                      [FFI::GDAL::GDAL.find_type(:GDALRasterBandH), :int, :int, :int, :int],
                      :int
      attach_gdal_function :GDALComputeMedianCutPCT,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        :pointer,
                        :int,
                        FFI::GDAL::GDAL.find_type(:GDALColorTableH),
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      :int
      attach_gdal_function :GDALComputeProximity,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)

      # ~~~~~~~~~~~~~~~~~~~~~
      # Contour functions
      # ~~~~~~~~~~~~~~~~~~~~~
      attach_gdal_function :GDAL_CG_Create,
                      %i[
                        int
                        int
                        int
                        double
                        double
                        double
                        GDALContourWriter
                        pointer
                      ],
                      :GDALContourGeneratorH
      attach_gdal_function :GDAL_CG_FeedLine,
                      %i[GDALContourGeneratorH pointer],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDAL_CG_Destroy, %i[pointer], :void
      attach_gdal_function :OGRContourWriter,
                      %i[double int pointer pointer pointer],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALContourGenerate,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        :double,
                        :double,
                        :int,
                        :pointer,
                        :int,
                        :double,
                        :pointer,
                        :int,
                        :int,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)

      # ~~~~~~~~~~~~~~~~~~~~~
      # Transformer functions
      # ~~~~~~~~~~~~~~~~~~~~~
      attach_gdal_function :GDALSuggestedWarpOutput,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :GDALTransformerFunc,
                        :pointer,
                        :pointer,
                        :pointer,
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALSuggestedWarpOutput2,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :GDALTransformerFunc,
                        :pointer,
                        :pointer,
                        :pointer,
                        :pointer,
                        :pointer,
                        :int
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALSerializeTransformer,
                      %i[GDALTransformerFunc pointer],
                      CPL::XMLNode.ptr
      attach_gdal_function :GDALDeserializeTransformer,
                      [CPL::XMLNode.ptr, :GDALTransformerFunc, :pointer],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALTransformGeolocations,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        :GDALTransformerFunc,
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer,
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)

      # ~~~
      # Approx
      # ~~~
      attach_gdal_function :GDALCreateApproxTransformer,
                      %i[GDALTransformerFunc pointer double],
                      :pointer
      attach_gdal_function :GDALDestroyApproxTransformer, %i[pointer], :void
      attach_gdal_function :GDALApproxTransformerOwnsSubtransformer,
                      %i[pointer bool],
                      :void
      ApproxTransform = attach_gdal_function :GDALApproxTransform,
                                        %i[pointer bool int pointer pointer pointer pointer],
                                        :int

      # ~~~
      # GCP Transform
      # ~~~
      attach_gdal_function :GDALCreateGCPTransformer, %i[int pointer int int], :pointer
      attach_gdal_function :GDALCreateGCPRefineTransformer,
                      %i[int pointer int int double int],
                      :pointer
      attach_gdal_function :GDALDestroyGCPTransformer, %i[pointer], :void
      GCPTransform = attach_gdal_function :GDALGCPTransform,
                                     %i[pointer bool int pointer pointer pointer pointer],
                                     :bool

      # ~~~
      # GeoLoc Transform
      # ~~~
      attach_gdal_function :GDALCreateGeoLocTransformer,
                      [FFI::GDAL::GDAL.find_type(:GDALDatasetH), :pointer, :bool],
                      :pointer
      attach_gdal_function :GDALDestroyGeoLocTransformer, %i[pointer], :void
      GeoLocTransform = attach_gdal_function :GDALGeoLocTransform,
                                        %i[pointer bool int pointer pointer pointer pointer],
                                        :bool

      # ~~~
      # GenImgProj Transform
      # ~~~
      attach_gdal_function :GDALCreateGenImgProjTransformer,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :string,
                        :bool,
                        :double,
                        :int
                      ],
                      :pointer
      attach_gdal_function :GDALCreateGenImgProjTransformer2,
                      [FFI::GDAL::GDAL.find_type(:GDALDatasetH), FFI::GDAL::GDAL.find_type(:GDALDatasetH), :pointer],
                      :pointer
      attach_gdal_function :GDALCreateGenImgProjTransformer3,
                      %i[string pointer string pointer],
                      :pointer
      attach_gdal_function :GDALDestroyGenImgProjTransformer, %i[pointer], :void
      attach_gdal_function :GDALSetGenImgProjTransformerDstGeoTransform,
                      %i[pointer pointer],
                      :void
      GenImgProjTransform = attach_gdal_function :GDALGenImgProjTransform,
                                            %i[pointer bool int pointer pointer pointer pointer],
                                            :bool

      # ~~~
      # Reprojection Transform
      # ~~~
      attach_gdal_function :GDALCreateReprojectionTransformer,
                      %i[string string],
                      :pointer
      attach_gdal_function :GDALDestroyReprojectionTransformer, %i[pointer], :void
      ReprojectionTransform = attach_gdal_function :GDALReprojectionTransform,
                                              %i[pointer bool int pointer pointer pointer pointer],
                                              :int

      # ~~~
      # RPC Transform
      # ~~~
      attach_gdal_function :GDALCreateRPCTransformer,
                      [RPCInfo.ptr, :int, :double, :pointer],
                      :pointer
      attach_gdal_function :RPCInfoToMD, [RPCInfo.ptr], :pointer
      attach_gdal_function :GDALDestroyRPCTransformer, %i[pointer], :void
      RPCTransform = attach_gdal_function :GDALRPCTransform,
                                     %i[pointer bool int pointer pointer pointer pointer],
                                     :int

      # ~~~
      # TPS Transform
      # ~~~
      attach_gdal_function :GDALCreateTPSTransformer, %i[int pointer int], :pointer
      attach_gdal_function :GDALDestroyTPSTransformer, %i[pointer], :void
      TPSTransform = attach_gdal_function :GDALTPSTransform,
                                     %i[pointer bool int pointer pointer pointer pointer],
                                     :int

      # ~~~
      # RasterBand related functions
      # ~~~
      attach_gdal_function :GDALDitherRGB2PCT,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALColorTableH),
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALFillNodata,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        :double,
                        :int,
                        :int,
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALPolygonize,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::OGR::API.find_type(:OGRLayerH),
                        :int,
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALFPolygonize,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::OGR::API.find_type(:OGRLayerH),
                        :int,
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALSieveFilter,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        FFI::GDAL::GDAL.find_type(:GDALRasterBandH),
                        :int,
                        :int,
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Dataset-related
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attach_gdal_function :GDALGridCreate,
                      [
                        GridAlgorithm,
                        :pointer,
                        FFI::CPL::Port.find_type(:GUInt32),
                        :pointer,
                        :pointer,
                        :pointer,
                        :double,
                        :double,
                        :double,
                        :double,
                        FFI::CPL::Port.find_type(:GUInt32),
                        FFI::CPL::Port.find_type(:GUInt32),
                        FFI::GDAL::GDAL.enum_type(:GDALDataType),
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALRasterizeGeometries,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :int,
                        :pointer,
                        :int,
                        :pointer,
                        :GDALTransformerFunc,
                        :pointer,
                        :pointer,
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALRasterizeLayers,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :int,
                        :pointer,
                        :int,
                        :pointer,
                        :GDALTransformerFunc,
                        :pointer,
                        :pointer,
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)
      attach_gdal_function :GDALRasterizeLayersBuf,
                      [
                        :pointer,
                        :int,
                        :int,
                        FFI::GDAL::GDAL.enum_type(:GDALDataType),
                        :int,
                        :int,
                        :int,
                        :pointer,
                        :string,
                        :pointer,
                        :GDALTransformerFunc,
                        :pointer,
                        :double,
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer
                      ],
                      FFI::CPL::Error.enum_type(:CPLErr)

      attach_gdal_function :GDALSimpleImageWarp,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :int,
                        :pointer,
                        :GDALTransformerFunc,
                        :pointer,
                        FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                        :pointer,
                        :pointer
                      ],
                      :bool

      attach_gdal_function :GDALComputeMatchingPoints,
                      [
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        FFI::GDAL::GDAL.find_type(:GDALDatasetH),
                        :pointer,
                        :pointer
                      ],
                      FFI::GDAL::GCP.ptr
    end
  end
end
