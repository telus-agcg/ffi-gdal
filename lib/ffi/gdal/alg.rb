require 'ffi'
require_relative 'rpc_info'
require_relative '../ogr/api'
require_relative '../cpl/error'
require_relative '../cpl/port'
require_relative '../cpl/xml_node'

module FFI
  module GDAL
    module Alg
      extend FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      GridAlgorithm = enum :GGA_InverseDistanceToAPower, 1,
        :GGA_MovingAverage, 2,
        :GGA_NearestNeighbor, 3,
        :GGA_MetricMinimum, 4,
        :GGA_MetricMaximum, 5,
        :GGA_MetricRange, 6,
        :GGA_MetricCount, 7,
        :GGA_MetricAverageDistance, 8,
        :GGA_MetricAverageDistancePts, 9

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      callback :GDALTransformerFunc,
        %i[pointer bool int pointer pointer pointer pointer],
        :int
      callback :GDALContourWriter,
        %i[double int pointer pointer pointer],
        CPL::Error::CPLErr
      typedef :pointer, :GDALContourGeneratorH

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :GDALChecksumImage,
        [GDAL.find_type(:GDALRasterBandH), :int, :int, :int, :int],
        :int
      attach_function :GDALComputeMedianCutPCT,
        [
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          :pointer,
          :int,
          GDAL.find_type(:GDALColorTableH),
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        :int
      attach_function :GDALComputeProximity,
        [
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          :pointer,
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr

      #~~~~~~~~~~~~~~~~~~~~~~
      # Contour functions
      #~~~~~~~~~~~~~~~~~~~~~~
      attach_function :GDAL_CG_Create,
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
      attach_function :GDAL_CG_FeedLine,
        %i[GDALContourGeneratorH pointer],
        CPL::Error::CPLErr
      attach_function :GDAL_CG_Destroy, %i[pointer], :void
      attach_function :OGRContourWriter,
        %i[double int pointer pointer pointer],
        CPL::Error::CPLErr
      attach_function :GDALContourGenerate,
        [
          GDAL.find_type(:GDALRasterBandH),
          :double,
          :double,
          :int,
          :pointer,
          :int,
          :double,
          :pointer,
          :int,
          :int,
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr

      #~~~~~~~~~~~~~~~~~~~~~~
      # Transformer functions
      #~~~~~~~~~~~~~~~~~~~~~~
      attach_function :GDALSetTransformerDstGeoTransform,
        %i[pointer pointer],
        :void
      attach_function :GDALSuggestedWarpOutput,
        [
          GDAL.find_type(:GDALDatasetH),
          :GDALTransformerFunc,
          :pointer,
          :pointer,
          :pointer,
          :pointer
        ],
        CPL::Error::CPLErr
      attach_function :GDALSuggestedWarpOutput2,
        [
          GDAL.find_type(:GDALDatasetH),
          :GDALTransformerFunc,
          :pointer,
          :pointer,
          :pointer,
          :pointer,
          :pointer,
          :int
        ],
        CPL::Error::CPLErr
      attach_function :GDALSerializeTransformer,
        %i[GDALTransformerFunc pointer],
        CPL::XMLNode.ptr
      attach_function :GDALDeserializeTransformer,
        [CPL::XMLNode.ptr, :GDALTransformerFunc, :pointer],
        CPL::Error::CPLErr
      attach_function :GDALTransformGeolocations,
        [
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          :GDALTransformerFunc,
          :pointer,
          GDAL.find_type(:GDALProgressFunc),
          :pointer,
          :pointer
        ],
        CPL::Error::CPLErr

      #~~~~
      # Approx
      #~~~~
      attach_function :GDALCreateApproxTransformer,
        %i[GDALTransformerFunc pointer double],
        :pointer
      attach_function :GDALDestroyApproxTransformer, %i[pointer], :void
      attach_function :GDALApproxTransformerOwnsSubtransformer,
        %i[pointer bool],
        :void
      ApproxTransform = attach_function :GDALApproxTransform,
        %i[pointer bool int pointer pointer pointer pointer],
        :int

      #~~~~
      # GCP Transform
      #~~~~
      attach_function :GDALCreateGCPTransformer, %i[int pointer int int], :pointer
      attach_function :GDALCreateGCPRefineTransformer,
        %i[int pointer int int double int],
        :pointer
      attach_function :GDALDestroyGCPTransformer, %i[pointer], :void
      GCPTransform = attach_function :GDALGCPTransform,
        %i[pointer bool int pointer pointer pointer pointer],
        :bool

      #~~~~
      # GeoLoc Transform
      #~~~~
      attach_function :GDALCreateGeoLocTransformer,
        [GDAL.find_type(:GDALDatasetH), :pointer, :bool],
        :pointer
      attach_function :GDALDestroyGeoLocTransformer, %i[pointer], :void
      GeoLocTransform = attach_function :GDALGeoLocTransform,
        %i[pointer bool int pointer pointer pointer pointer],
        :bool

      #~~~~
      # GenImgProj Transform
      #~~~~
      attach_function :GDALCreateGenImgProjTransformer,
        [
          GDAL.find_type(:GDALDatasetH),
          :string,
          GDAL.find_type(:GDALDatasetH),
          :string,
          :bool,
          :double,
          :int
        ],
        :pointer
      attach_function :GDALCreateGenImgProjTransformer2,
        [GDAL.find_type(:GDALDatasetH), GDAL.find_type(:GDALDatasetH), :pointer],
        :pointer
      attach_function :GDALCreateGenImgProjTransformer3,
        %i[string pointer string pointer],
        :pointer
      attach_function :GDALDestroyGenImgProjTransformer, %i[pointer], :void
      attach_function :GDALSetGenImgProjTransformerDstGeoTransform,
        %i[pointer pointer],
        :void
      GenImgProjTransform = attach_function :GDALGenImgProjTransform,
        %i[pointer bool int pointer pointer pointer pointer],
        :bool

      #~~~~
      # Reprojection Transform
      #~~~~
      attach_function :GDALCreateReprojectionTransformer,
        %i[string string],
        :pointer
      attach_function :GDALDestroyReprojectionTransformer, %i[pointer], :void
      ReprojectionTransform = attach_function :GDALReprojectionTransform,
        %i[pointer bool int pointer pointer pointer pointer],
        :int

      #~~~~
      # RPC Transform
      #~~~~
      attach_function :GDALCreateRPCTransformer,
        [RPCInfo.ptr, :int, :double, :pointer],
        :pointer
      attach_function :RPCInfoToMD, [GDAL::RPCInfo.ptr], :pointer
      attach_function :GDALDestroyRPCTransformer, %i[pointer], :void
      RPCTransform = attach_function :GDALRPCTransform,
        %i[pointer bool int pointer pointer pointer pointer],
        :int

      #~~~~
      # TPS Transform
      #~~~~
      attach_function :GDALCreateTPSTransformer, %i[int pointer int], :pointer
      attach_function :GDALDestroyTPSTransformer, %i[pointer], :void
      TPSTransform = attach_function :GDALTPSTransform,
        %i[pointer bool int pointer pointer pointer pointer],
        :int

      attach_function :GDALDitherRGB2PCT,
        [
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALColorTableH),
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr
      attach_function :GDALFillNodata,
        [
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          :double,
          :int,
          :int,
          :pointer,
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr
      attach_function :GDALPolygonize,
        [
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          OGR::API.find_type(:OGRLayerH),
          :int,
          :pointer,
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr
      attach_function :GDALFPolygonize,
        [
          GDAL.find_type(:GDALRasterBandH),
          GDAL.find_type(:GDALRasterBandH),
          OGR::API.find_type(:OGRLayerH),
          :int,
          :pointer,
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr

      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Dataset-related
      #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attach_function :GDALGridCreate,
        [
          GridAlgorithm,
          :pointer,
          CPL::Port.find_type(:GUInt32),
          :pointer,
          :pointer,
          :pointer,
          :double,
          :double,
          :double,
          :double,
          CPL::Port.find_type(:GUInt32),
          CPL::Port.find_type(:GUInt32),
          GDAL::DataType,
          :pointer,
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr
      attach_function :GDALRasterizeGeometries,
        [
          GDAL.find_type(:GDALDatasetH),
          :int,
          :pointer,
          :int,
          :pointer,
          :GDALTransformerFunc,
          :pointer,
          :pointer,
          :pointer,
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr
      attach_function :GDALRasterizeLayers,
        [
          GDAL.find_type(:GDALDatasetH),
          :int,
          :pointer,
          :int,
          :pointer,
          :GDALTransformerFunc,
          :pointer,
          :pointer,
          :pointer,
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr
      attach_function :GDALRasterizeLayersBuf,
        [
          :pointer,
          :int,
          :int,
          GDAL::DataType,
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
          GDAL.find_type(:GDALProgressFunc),
          :pointer
        ],
        CPL::Error::CPLErr

      attach_function :GDALSimpleImageWarp,
        [
          GDAL.find_type(:GDALDatasetH),
          GDAL.find_type(:GDALDatasetH),
          :int,
          :pointer,
          :GDALTransformerFunc,
          :pointer,
          GDAL.find_type(:GDALProgressFunc),
          :pointer,
          :pointer
        ],
        :bool
    end
  end
end
