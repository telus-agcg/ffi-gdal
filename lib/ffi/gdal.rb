require 'ffi'
require_relative "gdal/version"
require_relative "gdal/cpl_error"

module FFI
  module GDAL
    extend ::FFI::Library
    ffi_lib 'gdal'

    extend CPLError

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

    #attach_function :GDALDestroyDataset, [:GDALDriverH, :string], 
  end
end
