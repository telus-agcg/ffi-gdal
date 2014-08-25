require 'ffi'
require_relative 'gdal/version'
require_relative 'gdal/cpl_conv'
require_relative 'gdal/cpl_error'
require_relative 'gdal/cpl_string'
require_relative 'gdal/ogr_core'
require_relative 'gdal/ogr_api'
require_relative 'gdal/ogr_srs_api'

module FFI
  module GDAL
    extend ::FFI::Library
    ffi_lib 'gdal'

    include CPLError
    include CPLConv
    include CPLString
    include OGRCore
    include OGRAPI
    include OGRSRSAPI

    #-----------------------------------------------------------------
    # Defines
    #-----------------------------------------------------------------
    GDALMD_AREA_OR_POINT = 'AREA_OR_POINT'
    GDALMD_AOP_AREA = 'Area'
    GDALMD_AOP_POINT = 'Point'

    CPLE_WrongFormat = 200

    GDAL_DMD_LONGNAME = 'DMD_LONGNAME'
    GDAL_DMD_HELPTOPIC = 'DMD_HELPTOPIC'
    GDAL_DMD_MIMETYPE = 'DMD_MIMETYPE'
    GDAL_DMD_EXTENSION = 'DMD_EXTENSION'
    GDAL_DMD_EXTENSIONS = 'DMD_EXTENSIONS'
    GDAL_DMD_CREATIONOPTIONLIST = 'DMD_CREATIONOPTIONLIST'
    GDAL_DMD_OPTIONLIST = 'DMD_OPTIONLIST'
    GDAL_DMD_CREATIONDATATYPES = 'DMD_CREATIONDATATYPES'
    GDAL_DMD_SUBDATASETS = 'DMD_SUBDATASETS'

    GDAL_DCAP_OPEN = 'DCAP_OPEN'
    GDAL_DCAP_CREATE = 'DCAP_CREATE'
    GDAL_DCAP_CREATECOPY = 'DCAP_CREATECOPY'
    GDAL_DCAP_VIRTUALIO = 'DCAP_VIRTUALIO'
    GDAL_DCAP_RASTER = 'DCAP_RASTER'
    GDAL_DCAP_VECTOR = 'DCAP_VECTOR'

    GDAL_OF_READONLY = 0x00
    GDAL_OF_UPDATE = 0x01
    GDAL_OF_ALL = 0x00
    GDAL_OF_RASTER = 0x02
    GDAL_OF_VECTOR = 0x04
    GDAL_OF_SHARED = 0x20
    GDAL_OF_VERBOSE_ERROR = 0x40

    GDAL_DS_LAYER_CREATIONOPTIONLIST= 'DS_LAYER_CREATIONOPTIONLIST'

    GMF_ALL_VALID = 0x01
    GMF_PER_DATASET = 0x02
    GMF_ALPHA = 0x04
    GMF_NODATA = 0x08

    def srcval(popo_source, e_src_type, ii)
    end

    def gdal_check_version(psz_calling_component_name)
    end

    #-----------------------------------------------------------------
    # Enums
    #-----------------------------------------------------------------
    GDALDataType = enum :GDT_Unknown, 0,
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
      :GDT_TypeCount,   12

    GDALAsyncStatusType = enum :GARIO_PENDING, 0,
      :GARIO_UPDATE,     1,
      :GARIO_ERROR,      2,
      :GARIO_COMPLETE,   3,
      :GARIO_TypeCount,  4

    GDALAccess = enum :GA_ReadOnly, 0,
      :GA_update, 1

    GDALRWFlag = enum :GF_Read, 0,
      :GF_Write, 1

    GDALColorInterp = enum :GCI_Undefined, 0,
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
      :GCI_Max, 16      # Seems wrong that this is also 16...

    GDALPaletteInterp = enum :GPI_Gray, 0,
      :GPI_RGB,   1,
      :GPI_CMYK,  2,
      :GPI_HLS,   3

    GDALRATFieldUsage = enum :GFU_Generic, 0,
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

    GDALTileOrganization = enum :GTO_TIP,
      :GTO_BIT,
      :GTO_BSQ

    #-----------------------------------------------------------------
    # typedefs
    #-----------------------------------------------------------------
    typedef :pointer, :GDALMajorObjectH
    typedef :pointer, :GDALDatasetH
    typedef :pointer, :GDALRasterBandH
    typedef :pointer, :GDALDriverH
    typedef :pointer, :GDALColorTableH
    typedef :pointer, :GDALRasterAttributeTableH
    typedef :pointer, :GDALAsyncReaderH
    #typedef :pointer, :OGRGeometryH

    #-----------------------------------------------------------------
    # functions
    #-----------------------------------------------------------------
    callback :GDALProgressFunc, [:double, :string, :pointer], :int
    callback :GDALDerivedPixelFunc,
      [:pointer, :int, :pointer, :int, :int, GDALDataType, GDALDataType, :int, :int],
      :int

    # DataType
    attach_function :GDALGetDataTypeSize, [GDALDataType], :int
    attach_function :GDALDataTypeIsComplex, [GDALDataType], :int
    attach_function :GDALGetDataTypeName, [GDALDataType], :string
    attach_function :GDALGetDataTypeByName, [:string], GDALDataType
    attach_function :GDALDataTypeUnion, [GDALDataType, GDALDataType], GDALDataType

    # AsyncStatus
    attach_function :GDALGetAsyncStatusTypeName, [GDALAsyncStatusType], :string
    attach_function :GDALGetAsyncStatusTypeByName, [:string], GDALAsyncStatusType

    # ColorInterpretation
    attach_function :GDALGetColorInterpretationName, [GDALColorInterp], :string
    attach_function :GDALGetColorInterpretationByName, [:string], GDALColorInterp

    # PaletteInterpretation
    attach_function :GDALGetPaletteInterpretationName, [GDALPaletteInterp], :string

    attach_function :GDALAllRegister, [], :void
    attach_function :GDALCreate,
      [:GDALDriverH, :string, :int, :int, :int, GDALDataType, :pointer],
      :GDALDatasetH
    attach_function :GDALCreateCopy,
      [:GDALDriverH, :string, :GDALDatasetH, :int, :pointer, :GDALProgressFunc, :pointer],
      :GDALDatasetH
    attach_function :GDALIdentifyDriver,
      [:string, :pointer],
      :GDALDriverH
    attach_function :GDALOpen, [:string, GDALAccess], :GDALDatasetH
    attach_function :GDALOpenShared,
      [:string, GDALAccess],
      :GDALDatasetH
    #attach_function :GDALOpenEx,
      #[:string, :uint, :string, :string, :string],
      #:GDALDatasetH

    attach_function :GDALDumpOpenDatasets, [:pointer], :int
    attach_function :GDALGetDriverByName, [:string], :GDALDriverH
    attach_function :GDALGetDriverCount, [], :int
    attach_function :GDALGetDriver, [:int], :GDALDriverH
    attach_function :GDALDestroyDriver, [:GDALDriverH], :void
    attach_function :GDALRegisterDriver, [:GDALDriverH], :int
    attach_function :GDALDeregisterDriver, [:GDALDriverH], :void
    attach_function :GDALDestroyDriverManager, [:void], :void
    #attach_function :GDALDestroy, [], :void

    attach_function :GDALDeleteDataset, [:GDALDriverH, :string], CPLErr
    attach_function :GDALRenameDataset,
      [:GDALDriverH, :string, :string],
      CPLErr
    attach_function :GDALCopyDatasetFiles,
      [:GDALDriverH, :string, :string],
      CPLErr

    attach_function :GDALValidateCreationOptions,
      [:GDALDriverH, :pointer],
      CPLErr

    attach_function :GDALGetDriverShortName, [:GDALDriverH], :string
    attach_function :GDALGetDriverLongName, [:GDALDriverH], :string
    attach_function :GDALGetDriverHelpTopic, [:GDALDriverH], :string
    attach_function :GDALGetDriverCreationOptionList, [:GDALDriverH], :string

    attach_function :GDALInitGCPs, [:int, :pointer], :void
    attach_function :GDALDeinitGCPs, [:int, :pointer], :void
    attach_function :GDALDuplicateGCPs, [:int, :pointer], :pointer
    attach_function :GDALGCPsToGeoTransform,
      [:int, :pointer, :pointer, :int],
      :int
    attach_function :GDALInvGeoTransform,
      [:pointer, :pointer],
      :int
    attach_function :GDALApplyGeoTransform,
      [:pointer, :double, :double, :pointer, :pointer],
      :void
    attach_function :GDALComposeGeoTransforms,
      [:pointer, :pointer, :pointer],
      :void

    attach_function :GDALGetMetadataDomainList, [:GDALMajorObjectH], :pointer
    attach_function :GDALGetMetadata, [:GDALMajorObjectH, :string], :pointer
    attach_function :GDALSetMetadata,
      [:GDALMajorObjectH, :pointer, :string],
      CPLErr
    attach_function :GDALGetMetadataItem,
      [:GDALMajorObjectH, :string, :string],
      :string
    attach_function :GDALSetMetadataItem,
      [:GDALMajorObjectH, :string, :string, :string],
      CPLErr
    attach_function :GDALGetDescription, [:GDALMajorObjectH], :string
    attach_function :GDALSetDescription, [:GDALMajorObjectH, :string], :void

    attach_function :GDALGetDatasetDriver, [:GDALMajorObjectH], :GDALDriverH
    attach_function :GDALGetFileList, [:GDALDatasetH], :pointer
    attach_function :GDALClose, [:GDALDatasetH], :void

    #-----------------
    # Raster functions
    #-----------------
    attach_function :GDALGetRasterXSize, [:GDALDatasetH], :int
    attach_function :GDALGetRasterYSize, [:GDALDatasetH], :int
    attach_function :GDALGetRasterCount, [:GDALDatasetH], :int
    attach_function :GDALGetRasterBand, [:GDALDatasetH, :int], :GDALRasterBandH

    attach_function :GDALAddBand,
      [:GDALDatasetH, GDALDataType, :pointer],
      CPLErr

    attach_function :GDALBeginAsyncReader,
      [
        :GDALDatasetH,
        GDALRWFlag,
        :int,
        :int,
        :int,
        :int,
        :pointer,
        :int,
        :int,
        GDALDataType,
        :int,
        :pointer,
        :int,
        :int,
        :int
    ], :GDALAsyncReaderH

    attach_function :GDALEndAsyncReader,
      [:GDALDatasetH, :GDALAsyncReaderH],
      :void

    attach_function :GDALDatasetRasterIO,
      [
        :GDALDatasetH,
        GDALRWFlag,
        :int,
        :int,
        :int,
        :int,
        :pointer,
        :int,
        :int,
        GDALDataType,
        :int,
        :pointer,
        :int,
        :int,
        :int
      ], CPLErr

    attach_function :GDALDatasetAdviseRead,
      [
        :GDALDatasetH,
        :int,
        :int,
        :int,
        :int,
        :int,
        :int,
        GDALDataType,
        :int,
        :pointer,
        :pointer
      ], CPLErr

    #-----------------
    # Projection functions
    #-----------------
    attach_function :GDALGetProjectionRef, [:GDALDatasetH], :string
    attach_function :GDALSetProjection, [:GDALDatasetH, :string], CPLErr
    attach_function :GDALGetGeoTransform, [:GDALDatasetH, :pointer], CPLErr
    attach_function :GDALSetGeoTransform, [:GDALDatasetH, :pointer], CPLErr
    attach_function :GDALGetGCPCount, [:GDALDatasetH], :int
    attach_function :GDALGetGCPProjection, [:GDALDatasetH], :string
    attach_function :GDALGetGCPs, [:GDALDatasetH], :pointer
    attach_function :GDALSetGCPs,
      [:GDALDatasetH, :int, :pointer, :string],
      CPLErr

    attach_function :GDALGetInternalHandle, [:GDALDatasetH, :string], :pointer
    attach_function :GDALReferenceDataset, [:GDALDatasetH], :int
    attach_function :GDALDereferenceDataset, [:GDALDatasetH], :int

    attach_function :GDALBuildOverviews,
      [
        :GDALDatasetH,
        :string,
        :int,
        :pointer,
        :int,
        :pointer,
        :GDALProgressFunc,
        :pointer
      ], CPLErr

    attach_function :GDALGetOpenDatasets, [:pointer, :pointer], :void
    attach_function :GDALGetAccess, [:GDALDatasetH], :int
    attach_function :GDALFlushCache, [:GDALDatasetH], :void
    attach_function :GDALCreateDatasetMaskBand, [:GDALDatasetH, :int], CPLErr
    attach_function :GDALDatasetCopyWholeRaster,
      [:GDALDatasetH, :GDALDatasetH, :pointer, :GDALProgressFunc, :pointer],
      CPLErr
    attach_function :GDALRasterBandCopyWholeRaster,
      [
        :GDALRasterBandH,
        :GDALRasterBandH,
        :pointer,
        :GDALProgressFunc,
        :pointer
      ], CPLErr
    attach_function :GDALRegenerateOverviews,
      [
        :GDALRasterBandH,
        :int,
        :pointer,
        :string,
        :GDALProgressFunc,
        :pointer
      ], CPLErr
    #attach_function :GDALDatasetGetLayerCount, [:GDALDatasetH], :int
    #attach_function :GDALDatasetGetLayer, [:GDALDatasetH, :int], :OGRLayerH
    #attach_function :GDALDatasetGetLayerByName, [:GDALDatasetH, :string], :OGRLayerH
    #attach_function :GDALDatasetDeleteLayer, [:GDALDatasetH, :int], :OGRErr
    #attach_function :GDALDatasetCreateLayer
    #attach_function :GDALDatasetCopyLayer
    #attach_function :GDALDatasetTestCapability, [:GDALDatasetH, :string], :int
    #attach_function :GDALDatasetExecuteSQL,
    #  [:GDALDatasetH, :string, :OGRGeometryH, :string],
    #  :int
    #attach_function :GDALDatasetReleaseResultSet
    #attach_function :GDALDatasetGetStyleTable, [:GDALDatasetH], :OGRStyleTableH
    #attach_function :GDALDatasetSetStyleTableDirectly
    #attach_function :GDALDatasetSetStyleTable

    attach_function :GDALGetRasterDataType, [:GDALRasterBandH], GDALDataType
    attach_function :GDALGetBlockSize,
      [:GDALRasterBandH, :pointer, :pointer],
      GDALDataType

    attach_function :GDALRasterAdviseRead,
      [
        :GDALRasterBandH,
        :int,
        :int,
        :int,
        :int,
        :int,
        :int,
        GDALDataType,
        :pointer
      ], CPLErr

    attach_function :GDALRasterIO,
      [
        :GDALRasterBandH,
        GDALRWFlag,
        :int,
        :int,
        :int,
        :int,
        :pointer,
        :int,
        :int,
        GDALDataType,
        :int,
        :int
      ], CPLErr
    attach_function :GDALReadBlock,
      [:GDALRasterBandH, :int, :int, :pointer],
      CPLErr
    attach_function :GDALWriteBlock,
      [:GDALRasterBandH, :int, :int, :pointer],
      CPLErr
    attach_function :GDALGetRasterBandXSize, [:GDALRasterBandH], :int
    attach_function :GDALGetRasterBandYSize, [:GDALRasterBandH], :int
    attach_function :GDALGetRasterAccess, [:GDALRasterBandH], GDALAccess
    attach_function :GDALGetBandNumber, [:GDALRasterBandH], :int
    attach_function :GDALGetBandDataset, [:GDALRasterBandH], :GDALDatasetH
    attach_function :GDALGetRasterColorInterpretation,
      [:GDALRasterBandH],
      GDALColorInterp
    attach_function :GDALSetRasterColorInterpretation,
      [:GDALRasterBandH, GDALColorInterp],
      CPLErr
    attach_function :GDALGetRasterColorTable,
      [:GDALRasterBandH],
      :GDALColorTableH

    attach_function :GDALHasArbitraryOverviews, [:GDALRasterBandH], :int
    attach_function :GDALGetOverviewCount, [:GDALRasterBandH], :int
    attach_function :GDALGetOverview, [:GDALRasterBandH, :int], :GDALRasterBandH
    attach_function :GDALGetRasterNoDataValue,
      [:GDALRasterBandH, :pointer],
      :double
    attach_function :GDALSetRasterNoDataValue,
      [:GDALRasterBandH, :double],
      CPLErr
    attach_function :GDALGetRasterCategoryNames,
      [:GDALRasterBandH],
      :pointer
    attach_function :GDALSetRasterCategoryNames,
      [:GDALRasterBandH, :pointer],
      CPLErr
    attach_function :GDALGetRasterMinimum,
      [:GDALRasterBandH, :pointer],
      :double
    attach_function :GDALGetRasterMaximum,
      [:GDALRasterBandH, :pointer],
      :double
    attach_function :GDALGetRasterStatistics,
      [:GDALRasterBandH, :int, :int, :pointer, :pointer, :pointer, :pointer],
      CPLErr
    attach_function :GDALComputeRasterStatistics,
      [
        :GDALRasterBandH,
        :int,
        :int,
        :pointer,
        :pointer,
        :pointer,
        :pointer,
        :GDALProgressFunc,
        :pointer
      ], CPLErr
    attach_function :GDALSetRasterStatistics,
      [:GDALRasterBandH, :double, :double, :double, :double],
      CPLErr
    attach_function :GDALGetRasterUnitType, [:GDALRasterBandH], :string
    attach_function :GDALSetRasterUnitType, [:GDALRasterBandH, :string], CPLErr
    attach_function :GDALGetRasterOffset, [:GDALRasterBandH, :pointer], :double
    attach_function :GDALSetRasterOffset, [:GDALRasterBandH, :double], CPLErr
    attach_function :GDALGetRasterScale, [:GDALRasterBandH, :pointer], :double
    attach_function :GDALSetRasterScale, [:GDALRasterBandH, :double], CPLErr
    attach_function :GDALComputeRasterMinMax,
      [:GDALRasterBandH, :int, :pointer],
      :void
    attach_function :GDALFlushRasterCache, [:GDALRasterBandH], CPLErr
    attach_function :GDALGetRasterHistogram,
      [
        :GDALRasterBandH,
        :double,
        :double,
        :int,
        :pointer,
        :int,
        :int,
        :GDALProgressFunc,
        :pointer
      ], CPLErr

    attach_function :GDALGetDefaultHistogram,
      [
        :GDALRasterBandH,
        :pointer,
        :pointer,
        :pointer,
        :pointer,
        :int,
        :GDALProgressFunc,
        :pointer
      ], CPLErr
    attach_function :GDALSetDefaultHistogram,
      [
        :GDALRasterBandH,
        :double,
        :double,
        :int,
        :pointer
      ], CPLErr

    attach_function :GDALGetRandomRasterSample,
      [:GDALRasterBandH, :int, :pointer],
      :int
    attach_function :GDALGetRasterSampleOverview,
      [:GDALRasterBandH, :int],
      :GDALRasterBandH
    attach_function :GDALFillRaster,
      [:GDALRasterBandH, :double, :double],
      CPLErr
  end
end
