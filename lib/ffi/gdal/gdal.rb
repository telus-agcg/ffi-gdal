# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative 'color_entry'
require_relative '../gdal'

module FFI
  module GDAL
    module GDAL
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      # ----------------------------------------------------------------
      # Enums
      # ----------------------------------------------------------------
      DataType = enum :GDALDataType, [:GDT_Unknown, 0,
                                      :GDT_Byte,        1,
                                      :GDT_UInt16,      2,
                                      :GDT_Int16,       3,
                                      :GDT_UInt32,      4,
                                      :GDT_Int32,       5,
                                      :GDT_Float32,     6,
                                      :GDT_Float64,     7,
                                      :GDT_CInt16,      8,
                                      :GDT_CInt32,      9,
                                      :GDT_CFloat32,    10,
                                      :GDT_CFloat64,    11,
                                      :GDT_TypeCount,   12]

      AsyncStatusType = enum :GARIO_PENDING, 0,
                             :GARIO_UPDATE,     1,
                             :GARIO_ERROR,      2,
                             :GARIO_COMPLETE,   3,
                             :GARIO_TypeCount,  4

      Access = enum %i[GA_ReadOnly GA_Update]
      RWFlag = enum %i[GF_Read GF_Write]

      ColorInterp = enum :GCI_Undefined, 0,
                         :GCI_GrayIndex,      1,
                         :GCI_PaletteIndex,   2,
                         :GCI_RedBand,        3,
                         :GCI_GreenBand,      4,
                         :GCI_BlueBand,       5,
                         :GCI_AlphaBand,      6,
                         :GCI_HueBand,        7,
                         :GCI_SaturationBand, 8,
                         :GCI_LightnessBand,  9,
                         :GCI_CyanBand,       10,
                         :GCI_MagentaBand,    11,
                         :GCI_YellowBand,     12,
                         :GCI_BlackBand,      13,
                         :GCI_YCbCr_YBand,    14,
                         :GCI_YCbCr_CbBand,   15,
                         :GCI_YCbCr_CrBand,   16,
                         :GCI_Max, 16 # Seems wrong that this is also 16...

      PaletteInterp = enum %i[GPI_Gray GPI_RGB GPI_CMYK GPI_HLS]
      RATFieldType = enum %i[GFT_Integer GFT_Real GFT_String]

      RATFieldUsage = enum :GFU_Generic, 0,
                           :GFU_PixelCount,  1,
                           :GFU_Name,        2,
                           :GFU_Min,         3,
                           :GFU_Max,         4,
                           :GFU_MinMax,      5,
                           :GFU_Red,         6,
                           :GFU_Green,       7,
                           :GFU_Blue,        8,
                           :GFU_Alpha,       9,
                           :GFU_RedMin,     10,
                           :GFU_GreenMin,   11,
                           :GFU_BlueMin,    12,
                           :GFU_AlphaMin,   13,
                           :GFU_RedMax,     14,
                           :GFU_GreenMax,   15,
                           :GFU_BlueMax,    16,
                           :GFU_AlphaMax,   17,
                           :GFU_MaxCount

      TileOrganization = enum %i[GTO_TIP GTO_BIT GTO_BSQ]

      # ----------------------------------------------------------------
      # typedefs
      # ----------------------------------------------------------------
      typedef :pointer, :GDALMajorObjectH
      typedef :pointer, :GDALDatasetH
      typedef :pointer, :GDALRasterBandH
      typedef :pointer, :GDALDriverH
      typedef :pointer, :GDALColorTableH
      typedef :pointer, :GDALRasterAttributeTableH
      typedef :pointer, :GDALAsyncReaderH

      # When using, make sure to return +true+ if the operation should continue;
      #   +false+ if the user has canceled.
      callback :GDALProgressFunc,
               %i[double string pointer], # completion, message, progress_arg
               :bool

      callback :GDALDerivedPixelFunc,
               [:pointer, :int, :pointer, :int, :int, enum_type(:GDALDataType), enum_type(:GDALDataType), :int, :int],
               :int

      # ----------------------------------------------------------------
      # functions
      # ----------------------------------------------------------------
      # AsyncStatus
      attach_gdal_function :GDALGetAsyncStatusTypeName, [AsyncStatusType], :string
      attach_gdal_function :GDALGetAsyncStatusTypeByName, [:string], AsyncStatusType

      # ~~~~~~~~~~~~~~~~~~~
      # ColorInterpretation
      # ~~~~~~~~~~~~~~~~~~~
      attach_gdal_function :GDALGetColorInterpretationName, [ColorInterp], :strptr
      attach_gdal_function :GDALGetColorInterpretationByName, [:string], ColorInterp

      # ~~~~~~~~~~~~~~~~~~~
      # Driver
      # ~~~~~~~~~~~~~~~~~~~
      attach_gdal_function :GDALAllRegister, [], :void

      # Class-level functions
      attach_gdal_function :GDALGetDriver, [:int], :GDALDriverH
      attach_gdal_function :GDALGetDriverCount, [], :int
      attach_gdal_function :GDALIdentifyDriver, %i[string pointer], :GDALDriverH
      attach_gdal_function :GDALGetDriverByName, [:string], :GDALDriverH
      attach_gdal_function :GDALDestroyDriverManager, [], :void

      # Instance-level functions
      attach_gdal_function :GDALCreate,
                           [:GDALDriverH, :string, :int, :int, :int, enum_type(:GDALDataType), :pointer],
                           :GDALDatasetH
      attach_gdal_function :GDALCreateCopy,
                           %i[GDALDriverH string GDALDatasetH bool pointer GDALProgressFunc pointer],
                           :GDALDatasetH
      attach_gdal_function :GDALValidateCreationOptions, %i[GDALDriverH pointer], :bool
      attach_gdal_function :GDALGetDriverShortName, [:GDALDriverH], :strptr
      attach_gdal_function :GDALGetDriverLongName, [:GDALDriverH], :strptr
      attach_gdal_function :GDALGetDriverHelpTopic, [:GDALDriverH], :strptr
      attach_gdal_function :GDALGetDriverCreationOptionList, [:GDALDriverH], :strptr

      attach_gdal_function :GDALDestroyDriver, [:GDALDriverH], :void
      attach_gdal_function :GDALRegisterDriver, [:GDALDriverH], :int
      attach_gdal_function :GDALDeregisterDriver, [:GDALDriverH], :void
      attach_gdal_function :GDALDeleteDataset, %i[GDALDriverH string], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALRenameDataset,
                           %i[GDALDriverH string string],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALCopyDatasetFiles,
                           %i[GDALDriverH string string],
                           FFI::CPL::Error::CPLErr

      # ~~~~~~~~~~~~~~~~~~~
      # Dataset
      # ~~~~~~~~~~~~~~~~~~~
      # Class-level functions
      attach_gdal_function :GDALOpen, [:string, Access], :GDALDatasetH
      attach_gdal_function :GDALOpenShared,
                           [:string, Access],
                           :GDALDatasetH
      attach_gdal_function :GDALDumpOpenDatasets, [:pointer], :int
      attach_gdal_function :GDALGetOpenDatasets, %i[pointer pointer], :void

      # Instance-level functions
      attach_gdal_function :GDALClose, [:GDALDatasetH], :void
      attach_gdal_function :GDALGetDatasetDriver, [:GDALDatasetH], :GDALDriverH
      attach_gdal_function :GDALGetFileList, [:GDALDatasetH], :pointer
      attach_gdal_function :GDALGetInternalHandle, %i[GDALDatasetH string], :pointer
      attach_gdal_function :GDALReferenceDataset, [:GDALDatasetH], :int
      attach_gdal_function :GDALDereferenceDataset, [:GDALDatasetH], :int

      attach_gdal_function :GDALGetAccess, [:GDALDatasetH], :int
      attach_gdal_function :GDALFlushCache, [:GDALDatasetH], :void

      attach_gdal_function :GDALGetRasterXSize, [:GDALDatasetH], :int
      attach_gdal_function :GDALGetRasterYSize, [:GDALDatasetH], :int
      attach_gdal_function :GDALGetRasterCount, [:GDALDatasetH], :int
      attach_gdal_function :GDALGetRasterBand, %i[GDALDatasetH int], :GDALRasterBandH
      attach_gdal_function :GDALAddBand,
                           [:GDALDatasetH, enum_type(:GDALDataType), :pointer],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALBeginAsyncReader,
                           [
                             :GDALDatasetH,
                             RWFlag,
                             :int,
                             :int,
                             :int,
                             :int,
                             :pointer,
                             :int,
                             :int,
                             enum_type(:GDALDataType),
                             :int,
                             :pointer,
                             :int,
                             :int,
                             :int
                           ], :GDALAsyncReaderH

      attach_gdal_function :GDALEndAsyncReader,
                           %i[GDALDatasetH GDALAsyncReaderH],
                           :void

      attach_gdal_function :GDALDatasetRasterIO,
                           [
                             :GDALDatasetH,
                             RWFlag,
                             :int,
                             :int,
                             :int,
                             :int,
                             :pointer,
                             :int,
                             :int,
                             enum_type(:GDALDataType),
                             :int,
                             :pointer,
                             :int,
                             :int,
                             :int
                           ], FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALDatasetAdviseRead,
                           [
                             :GDALDatasetH,
                             :int,
                             :int,
                             :int,
                             :int,
                             :int,
                             :int,
                             enum_type(:GDALDataType),
                             :int,
                             :pointer,
                             :pointer
                           ], FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALInitGCPs, %i[int pointer], :void
      attach_gdal_function :GDALDeinitGCPs, %i[int pointer], :void
      attach_gdal_function :GDALDuplicateGCPs, %i[int pointer], :pointer
      attach_gdal_function :GDALGCPsToGeoTransform,
                           %i[int pointer pointer int],
                           :int
      attach_gdal_function :GDALGetGCPCount, [:GDALDatasetH], :int
      attach_gdal_function :GDALGetGCPProjection, [:GDALDatasetH], :strptr
      attach_gdal_function :GDALGetGCPs, [:GDALDatasetH], :pointer
      attach_gdal_function :GDALSetGCPs,
                           %i[GDALDatasetH int pointer string],
                           FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALGetProjectionRef, [:GDALDatasetH], :strptr
      attach_gdal_function :GDALSetProjection, %i[GDALDatasetH string], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetGeoTransform, %i[GDALDatasetH pointer], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALSetGeoTransform,
                           %i[GDALDatasetH pointer],
                           FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALBuildOverviews,
                           %i[
                             GDALDatasetH
                             string
                             int
                             pointer
                             int
                             pointer
                             GDALProgressFunc
                             pointer
                           ], FFI::CPL::Error::CPLErr

      # OGR datasets.  Not found in v1.11.1
      # attach_gdal_function :GDALDatasetGetLayerCount, [:GDALDatasetH], :int
      # attach_gdal_function :GDALDatasetGetLayer, [:GDALDatasetH, :int], :OGRLayerH
      # attach_gdal_function :GDALDatasetGetLayerByName, [:GDALDatasetH, :string], :OGRLayerH
      # attach_gdal_function :GDALDatasetDeleteLayer, [:GDALDatasetH, :int], FFI::OGR::::OGRErr
      # attach_gdal_function :GDALDatasetCreateLayer,
      #   [
      #     :GDALDatasetH,
      #     :string,
      #     FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH),
      #     FFI::OGR::::OGRwkbGeometryType,
      #     :pointer
      #   ],
      #   :OGRLayerH
      # attach_gdal_function :GDALDatasetCopyLayer,
      #   [:GDALDatasetH, :OGRLayerH, :string, :pointer],
      #   :OGRLayerH
      # attach_gdal_function :GDALDatasetTestCapability, [:GDALDatasetH, :string], :int
      # attach_gdal_function :GDALDatasetExecuteSQL,
      #   [:GDALDatasetH, :string, :OGRGeometryH, :string],
      #   :OGRLayerH
      # attach_gdal_function :GDALDatasetReleaseResultSet,
      #   %i[GDALDatasetH OGRLayerH],
      #   :void
      # attach_gdal_function :GDALDatasetGetStyleTable, [:GDALDatasetH], :OGRStyleTableH
      # attach_gdal_function :GDALDatasetSetStyleTableDirectly,
      #   %i[GDALDatasetH OGRStyleTableH],
      #   :void
      # attach_gdal_function :GDALDatasetSetStyleTable,
      #   %i[GDALDatasetH OGRStyleTableH],
      #   :void

      attach_gdal_function :GDALCreateDatasetMaskBand, %i[GDALDatasetH int], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALDatasetCopyWholeRaster,
                           %i[GDALDatasetH GDALDatasetH pointer GDALProgressFunc pointer],
                           FFI::CPL::Error::CPLErr

      # ~~~~~~~~~~~~~~~~~~~
      # MajorObject
      # ~~~~~~~~~~~~~~~~~~~
      attach_gdal_function :GDALGetMetadataDomainList, [:GDALMajorObjectH], :pointer
      attach_gdal_function :GDALGetMetadata, %i[GDALMajorObjectH string], :pointer
      attach_gdal_function :GDALSetMetadata, %i[GDALMajorObjectH pointer string], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetMetadataItem,
                           %i[GDALMajorObjectH string string],
                           :strptr
      attach_gdal_function :GDALSetMetadataItem,
                           %i[GDALMajorObjectH string string string],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetDescription, [:GDALMajorObjectH], :strptr
      attach_gdal_function :GDALSetDescription, %i[GDALMajorObjectH string], :void

      # ~~~~~~~~~~~~~~~~~~~
      # GeoTransform
      # ~~~~~~~~~~~~~~~~~~~
      attach_gdal_function :GDALInvGeoTransform, %i[pointer pointer], :int
      attach_gdal_function :GDALApplyGeoTransform,
                           %i[pointer double double pointer pointer],
                           :void
      attach_gdal_function :GDALComposeGeoTransforms,
                           %i[pointer pointer pointer],
                           :void

      # ----------------
      # Raster functions
      # ----------------
      attach_gdal_function :GDALRasterBandCopyWholeRaster,
                           %i[
                             GDALRasterBandH
                             GDALRasterBandH
                             pointer
                             GDALProgressFunc
                             pointer
                           ], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALRegenerateOverviews,
                           %i[
                             GDALRasterBandH
                             int
                             pointer
                             string
                             GDALProgressFunc
                             pointer
                           ], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetMaskBand, [:GDALRasterBandH], :GDALRasterBandH
      attach_gdal_function :GDALGetMaskFlags, [:GDALRasterBandH], :int
      attach_gdal_function :GDALCreateMaskBand,
                           %i[GDALRasterBandH int],
                           FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALGetRasterDataType, [:GDALRasterBandH], enum_type(:GDALDataType)
      attach_gdal_function :GDALGetBlockSize,
                           %i[GDALRasterBandH pointer pointer],
                           enum_type(:GDALDataType)

      attach_gdal_function :GDALRasterAdviseRead,
                           [
                             :GDALRasterBandH,
                             :int,
                             :int,
                             :int,
                             :int,
                             :int,
                             :int,
                             enum_type(:GDALDataType),
                             :pointer
                           ], FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALRasterIO,
                           [
                             :GDALRasterBandH,
                             RWFlag,
                             :int,
                             :int,
                             :int,
                             :int,
                             :pointer,
                             :int,
                             :int,
                             enum_type(:GDALDataType),
                             :int,
                             :int
                           ], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALReadBlock,
                           %i[GDALRasterBandH int int pointer],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALWriteBlock,
                           %i[GDALRasterBandH int int pointer],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetRasterBandXSize, [:GDALRasterBandH], :int
      attach_gdal_function :GDALGetRasterBandYSize, [:GDALRasterBandH], :int
      attach_gdal_function :GDALGetRasterAccess, [:GDALRasterBandH], Access
      attach_gdal_function :GDALGetBandNumber, [:GDALRasterBandH], :int
      attach_gdal_function :GDALGetBandDataset, [:GDALRasterBandH], :GDALDatasetH
      attach_gdal_function :GDALGetRasterColorInterpretation,
                           [:GDALRasterBandH],
                           ColorInterp
      attach_gdal_function :GDALSetRasterColorInterpretation,
                           [:GDALRasterBandH, ColorInterp],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetRasterColorTable,
                           [:GDALRasterBandH],
                           :GDALColorTableH
      attach_gdal_function :GDALSetRasterColorTable,
                           %i[GDALRasterBandH GDALColorTableH],
                           FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALHasArbitraryOverviews, [:GDALRasterBandH], :int
      attach_gdal_function :GDALGetOverviewCount, [:GDALRasterBandH], :int
      attach_gdal_function :GDALGetOverview, %i[GDALRasterBandH int], :GDALRasterBandH
      attach_gdal_function :GDALGetRasterNoDataValue,
                           %i[GDALRasterBandH pointer],
                           :double
      attach_gdal_function :GDALSetRasterNoDataValue,
                           %i[GDALRasterBandH double],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetRasterCategoryNames,
                           [:GDALRasterBandH],
                           :pointer
      attach_gdal_function :GDALSetRasterCategoryNames,
                           %i[GDALRasterBandH pointer],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetRasterMinimum,
                           %i[GDALRasterBandH pointer],
                           :double
      attach_gdal_function :GDALGetRasterMaximum,
                           %i[GDALRasterBandH pointer],
                           :double
      attach_gdal_function :GDALGetRasterStatistics,
                           %i[GDALRasterBandH bool bool pointer pointer pointer pointer],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALComputeRasterStatistics,
                           %i[
                             GDALRasterBandH
                             bool
                             pointer
                             pointer
                             pointer
                             pointer
                             GDALProgressFunc
                             pointer
                           ], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALSetRasterStatistics,
                           %i[GDALRasterBandH double double double double],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetRasterUnitType, [:GDALRasterBandH], :strptr
      attach_gdal_function :GDALSetRasterUnitType, %i[GDALRasterBandH string], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetRasterOffset, %i[GDALRasterBandH pointer], :double
      attach_gdal_function :GDALSetRasterOffset, %i[GDALRasterBandH double], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetRasterScale, %i[GDALRasterBandH pointer], :double
      attach_gdal_function :GDALSetRasterScale, %i[GDALRasterBandH double], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALComputeRasterMinMax,
                           %i[GDALRasterBandH bool pointer],
                           :void
      attach_gdal_function :GDALFlushRasterCache, [:GDALRasterBandH], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALGetRasterHistogram,
                           %i[
                             GDALRasterBandH
                             double
                             double
                             int
                             pointer
                             bool
                             bool
                             GDALProgressFunc
                             pointer
                           ], FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALGetDefaultHistogram,
                           %i[
                             GDALRasterBandH
                             pointer
                             pointer
                             pointer
                             pointer
                             bool
                             GDALProgressFunc
                             pointer
                           ], FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALSetDefaultHistogram,
                           %i[
                             GDALRasterBandH
                             double
                             double
                             int
                             pointer
                           ], FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALGetRandomRasterSample,
                           %i[GDALRasterBandH int pointer],
                           :int
      attach_gdal_function :GDALGetRasterSampleOverview,
                           %i[GDALRasterBandH int],
                           :GDALRasterBandH
      attach_gdal_function :GDALFillRaster,
                           %i[GDALRasterBandH double double],
                           FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALGetDefaultRAT,
                           [:GDALRasterBandH],
                           :GDALRasterAttributeTableH
      attach_gdal_function :GDALSetDefaultRAT,
                           %i[GDALRasterBandH GDALRasterAttributeTableH],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALAddDerivedBandPixelFunc,
                           %i[string GDALDerivedPixelFunc],
                           FFI::CPL::Error::CPLErr

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Raster Attribute Table functions
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Class-level functions
      attach_gdal_function :GDALCreateRasterAttributeTable,
                           [],
                           :GDALRasterAttributeTableH

      # Instance-level functions
      attach_gdal_function :GDALDestroyRasterAttributeTable,
                           [:GDALRasterAttributeTableH],
                           :void
      attach_gdal_function :GDALRATChangesAreWrittenToFile,
                           [:GDALRasterAttributeTableH],
                           :bool
      attach_gdal_function :GDALRATClone,
                           [:GDALRasterAttributeTableH],
                           :GDALRasterAttributeTableH

      attach_gdal_function :GDALRATGetColumnCount,
                           [:GDALRasterAttributeTableH],
                           :int
      attach_gdal_function :GDALRATGetNameOfCol,
                           %i[GDALRasterAttributeTableH int],
                           :strptr
      attach_gdal_function :GDALRATGetUsageOfCol,
                           %i[GDALRasterAttributeTableH int],
                           RATFieldUsage
      attach_gdal_function :GDALRATGetTypeOfCol,
                           %i[GDALRasterAttributeTableH int],
                           RATFieldType
      attach_gdal_function :GDALRATGetColOfUsage,
                           [:GDALRasterAttributeTableH, RATFieldUsage],
                           :int
      attach_gdal_function :GDALRATCreateColumn,
                           [:GDALRasterAttributeTableH, :string, RATFieldType, RATFieldUsage],
                           FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALRATGetValueAsString,
                           %i[GDALRasterAttributeTableH int int],
                           :strptr
      attach_gdal_function :GDALRATGetValueAsInt,
                           %i[GDALRasterAttributeTableH int int],
                           :int
      attach_gdal_function :GDALRATGetValueAsDouble,
                           %i[GDALRasterAttributeTableH int int],
                           :double
      attach_gdal_function :GDALRATSetValueAsString,
                           %i[GDALRasterAttributeTableH int int string],
                           :void
      attach_gdal_function :GDALRATSetValueAsInt,
                           %i[GDALRasterAttributeTableH int int int],
                           :void
      attach_gdal_function :GDALRATSetValueAsDouble,
                           %i[GDALRasterAttributeTableH int int double],
                           :void
      attach_gdal_function :GDALRATValuesIOAsDouble,
                           [:GDALRasterAttributeTableH, RWFlag, :int, :int, :int, :pointer],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALRATValuesIOAsInteger,
                           [:GDALRasterAttributeTableH, RWFlag, :int, :int, :int, :pointer],
                           FFI::CPL::Error::CPLErr
      attach_gdal_function :GDALRATValuesIOAsString,
                           [:GDALRasterAttributeTableH, RWFlag, :int, :int, :int, :pointer],
                           FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALRATGetRowCount,
                           [:GDALRasterAttributeTableH],
                           :int
      attach_gdal_function :GDALRATSetRowCount,
                           %i[GDALRasterAttributeTableH int],
                           :void
      attach_gdal_function :GDALRATGetRowOfValue,
                           %i[GDALRasterAttributeTableH double],
                           :int

      attach_gdal_function :GDALRATSetLinearBinning,
                           %i[GDALRasterAttributeTableH double double],
                           :int
      attach_gdal_function :GDALRATGetLinearBinning,
                           %i[GDALRasterAttributeTableH pointer pointer],
                           :bool
      attach_gdal_function :GDALRATTranslateToColorTable,
                           %i[GDALRasterAttributeTableH int],
                           :GDALColorTableH
      attach_gdal_function :GDALRATInitializeFromColorTable,
                           %i[GDALRasterAttributeTableH GDALColorTableH],
                           FFI::CPL::Error::CPLErr

      attach_gdal_function :GDALRATDumpReadable,
                           %i[GDALRasterAttributeTableH pointer],
                           :void

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # ColorTable functions
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # Class-level functions
      attach_gdal_function :GDALCreateColorTable, [PaletteInterp], :GDALColorTableH

      # Instance-level functions
      attach_gdal_function :GDALDestroyColorTable, [:GDALColorTableH], :void
      attach_gdal_function :GDALCloneColorTable, [:GDALColorTableH], :GDALColorTableH

      attach_gdal_function :GDALGetPaletteInterpretation, [:GDALColorTableH], PaletteInterp
      attach_gdal_function :GDALGetColorEntryCount, [:GDALColorTableH], :int
      attach_gdal_function :GDALGetColorEntry, %i[GDALColorTableH int], FFI::GDAL::ColorEntry.ptr
      attach_gdal_function :GDALGetColorEntryAsRGB, [:GDALColorTableH, :int, FFI::GDAL::ColorEntry], :int
      attach_gdal_function :GDALSetColorEntry, [:GDALColorTableH, :int, FFI::GDAL::ColorEntry.ptr], :void

      attach_gdal_function :GDALCreateColorRamp,
                           [:GDALColorTableH, :int, FFI::GDAL::ColorEntry.ptr, :int, FFI::GDAL::ColorEntry.ptr],
                           :void

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # PaletteInterp functions
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attach_gdal_function :GDALGetPaletteInterpretationName, [PaletteInterp], :strptr

      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      # General stuff
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      attach_gdal_function :GDALGetDataTypeSize, [enum_type(:GDALDataType)], :int
      attach_gdal_function :GDALDataTypeIsComplex, [enum_type(:GDALDataType)], :bool
      attach_gdal_function :GDALGetDataTypeName, [enum_type(:GDALDataType)], :strptr
      attach_gdal_function :GDALGetDataTypeByName, [:string], enum_type(:GDALDataType)
      attach_gdal_function :GDALDataTypeUnion, [enum_type(:GDALDataType), enum_type(:GDALDataType)],
                           enum_type(:GDALDataType)

      attach_gdal_function :GDALSetCacheMax, %i[int], :void
      attach_gdal_function :GDALSetCacheMax64, [CPL::Port.find_type(:GIntBig)], :void
      attach_gdal_function :GDALGetCacheMax, [], :int
      attach_gdal_function :GDALGetCacheMax64, [], CPL::Port.find_type(:GIntBig)
      attach_gdal_function :GDALGetCacheUsed, [], :int
      attach_gdal_function :GDALGetCacheUsed64, [], CPL::Port.find_type(:GIntBig)
      attach_gdal_function :GDALFlushCacheBlock, [], :bool

      attach_gdal_function :GDALLoadWorldFile, %i[string pointer], :bool
      attach_gdal_function :GDALReadWorldFile, %i[string string pointer], :bool
      attach_gdal_function :GDALWriteWorldFile, %i[string string pointer], :bool

      attach_gdal_function :GDALPackedDMSToDec, %i[double], :double
      attach_gdal_function :GDALDecToPackedDMS, %i[double], :double

      attach_gdal_function :GDALGeneralCmdLineProcessor, %i[int pointer int], :int
      attach_gdal_function :GDALSwapWords,
                           %i[pointer int int int],
                           :void
      attach_gdal_function :GDALCopyWords,
                           %i[pointer int int pointer int int int int],
                           :void
      attach_gdal_function :GDALCopyBits,
                           %i[pointer int int pointer int int int int],
                           :void
    end
  end
end
