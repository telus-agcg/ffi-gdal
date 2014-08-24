require 'ffi'
require_relative 'gdal/version'
require_relative 'gdal/cpl_error'
require_relative 'gdal/ogr_core'
require_relative 'gdal/ogr_api'
require_relative 'gdal/ogr_srs_api'

module FFI
  module GDAL
    extend ::FFI::Library
    ffi_lib 'gdal'

    include CPLError
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
    GDALDataType = enum :unknown, 0,
      :byte,        1,
      :uint16,      2,
      :int16,       3,
      :uint32,      4,
      :int32,       5,
      :float32,     6,
      :float64,     7,
      :cint16,      8,
      :cint32,      9,
      :cfloat32,   10,
      :cfloat64,   11,
      :type_count, 12

    GDALAsyncStatusType = enum :pending, 0,
      :update,     1,
      :error,      2,
      :complete,   3,
      :type_count, 4

    GDALAccess = enum :read_only, 0,
      :update, 1

    GDALRWFlag = enum :read, 0,
      :write, 1

    GDALColorInterp = enum :undefined, 0,
      :gray_index,      1,
      :palette_index,   2,
      :red_band,        3,
      :green_band,      4,
      :blue_band,       5,
      :alpha_band,      6,
      :hue_band,        7,
      :saturation_band, 8,
      :lightness_band,  9,
      :cyan_band,       10,
      :magenta_band,    11,
      :yellow_band,     12,
      :black_band,      13,
      :ycbcr_y_band,    14,
      :ycbcr_cb_band,   15,
      :ycbcr_cr_band,   16,
      :max, 16      # Seems wrong that this is also 16...

    GDALPaletteInterp = enum :gray, 0,
      :rgb, 1,
      :cmyk, 2,
      :hls, 3

    GDALRATFieldUsage = enum :generic, 0,
      :pixel_count, 1,
      :name,        2,
      :min,         3,
      :max,         4,
      :min_max,     5,
      :red,         6,
      :green,       7,
      :blue,        8,
      :alpha,       9,
      :red_min,     10,
      :green_min,   11,
      :blue_min,    12,
      :alpha_min,   13,
      :red_max,     14,
      :green_max,   15,
      :blue_max,    16,
      :alpha_max,   17,
      :max_count

    GDALTileOrganization = enum :tip,
      :bit,
      :bsq

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
      [:GDALDriverH, :string, :GDALDatasetH, :int, :string, :GDALProgressFunc, :pointer],
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
    attach_function :GDALGetDriverCount, [:void], :int
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
  end
end
