# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative 'field'
require_relative '../gdal'

module FFI
  module OGR
    module Core
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      # The C API defines :OGRErr as a function that returns constants.  I'm
      # taking the liberty to turn this into an enum.
      # https://trac.osgeo.org/gdal/ticket/3153
      Err = enum :ogr_err, %i[OGRERR_NONE
                              OGRERR_NOT_ENOUGH_DATA
                              OGRERR_NOT_ENOUGH_MEMORY
                              OGRERR_UNSUPPORTED_GEOMETRY_TYPE
                              OGRERR_UNSUPPORTED_OPERATION
                              OGRERR_CORRUPT_DATA
                              OGRERR_FAILURE
                              OGRERR_UNSUPPORTED_SRS
                              OGRERR_INVALID_HANDLE]

      # https://gdal.org/api/vector_c_api.html#_CPPv418OGRwkbGeometryType
      #
      WKBGeometryType = enum FFI::Type::UINT,
                             :wkbUnknown,                0,
                             :wkbPoint,                  1,
                             :wkbLineString,             2,
                             :wkbPolygon,                3,
                             :wkbMultiPoint,             4,
                             :wkbMultiLineString,        5,
                             :wkbMultiPolygon,           6,
                             :wkbGeometryCollection,     7,
                             :wkbCircularString,         8,
                             :wkbCompoundCurve,          9,
                             :wkbCurvePolygon,           10,
                             :wkbMultiCurve,             11,
                             :wkbMultiSurface,           12,
                             :wkbCurve,                  13,
                             :wkbSurface,                14,
                             :wkbNone,                   100,    # non-standard, for pure attribute records
                             :wkbLinearRing,             101,    # non-standard, just for createGeometry
                             :wkbPoint25D,               0x8000_0001,
                             :wkbLineString25D,          0x8000_0002,
                             :wkbPolygon25D,             0x8000_0003,
                             :wkbMultiPoint25D,          0x8000_0004,
                             :wkbMultiLineString25D,     0x8000_0005,
                             :wkbMultiPolygon25D,        0x8000_0006,
                             :wkbGeometryCollection25D,  0x8000_0007

      WKBByteOrder = enum %i[wkbXDR wkbNDR]

      FieldType = enum %i[OFTInteger
                          OFTIntegerList
                          OFTReal
                          OFTRealList
                          OFTString
                          OFTStringList
                          OFTWideString
                          OFTWideStringList
                          OFTBinary
                          OFTDate
                          OFTTime
                          OFTDateTime
                          OFTInteger64
                          OFTInteger64List]

      # TODO: Add related methods
      FieldSubType = enum %i[OFSTNone OFSTBoolean OFSTInt16 OFSTFloat32 OFSTJSON OFSTUUID OFSTMaxSubType]

      Justification = enum %i[OJUndefined OJLeft OJRight]
      STClassId = enum %i[OGRSTCNone OGRSTCPen OGRSTCBrush OGRSTCSymbol OGRSTCLabel OGRSTCVector]
      STUnitId = enum %i[OGRSTUGround OGRSTUPixel OGRSTUPoints OGRSTUMM OGRSTUCM OGRSTUInches]

      STPenParam = enum %i[OGRSTPenColor
                           OGRSTPenWidth
                           OGRSTPenPattern
                           OGRSTPenId
                           OGRSTPenPerOffset
                           OGRSTPenPerCap
                           OGRSTPenPerJoin
                           OGRSTPenPerPriority]

      STBrushParam = enum %i[OGRSTBrushFColor
                             OGRSTBrushBColor
                             OGRSTBrushId
                             OGRSTBrushAngle
                             OGRSTBrushSize
                             OGRSTBrushDx
                             OGRSTBrushDy
                             OGRSTBrushPriority]

      STSymbolParam = enum %i[OGRSTSymbolId
                              OGRSTSymbolAngle
                              OGRSTSymbolColor
                              OGRSTSymbolSize
                              OGRSTSymbolDx
                              OGRSTSymbolDy
                              OGRSTSymbolStep
                              OGRSTSymbolPerp
                              OGRSTSymbolOffset
                              OGRSTSymbolPriority
                              OGRSTSymbolFontName
                              OGRSTSymbolOColor]

      STLabelParam = enum %i[OGRSTLabelFontName
                             OGRSTLabelSize
                             OGRSTLabelTextString
                             OGRSTLabelAngle
                             OGRSTLabelFColor
                             OGRSTLabelBColor
                             OGRSTLabelPlacement
                             OGRSTLabelAnchor
                             OGRSTLabelDx
                             OGRSTLabelDy
                             OGRSTLabelPerp
                             OGRSTLabelBold
                             OGRSTLabelItalic
                             OGRSTLabelUnderline
                             OGRSTLabelPriority
                             OGRSTLabelStrikeout
                             OGRSTLabelStretch
                             OGRSTLabelAdjHor
                             OGRSTLabelAdjVert
                             OGRSTLabelHColor
                             OGRSTLabelOColor]

      #------------------------------------------------------------------------
      # Constants
      #------------------------------------------------------------------------
      OGR_ALTER = FFI::ConstGenerator.new do |gen|
        gen.include FFI::GDAL._file_with_constants('ogr_core.h')
        gen.const :ALTER_NAME_FLAG, '%x'
        gen.const :ALTER_TYPE_FLAG, '%x'
        gen.const :ALTER_WIDTH_PRECISION_FLAG, '%x'
        gen.const :ALTER_ALL_FLAG, '%x'
      end
      OGR_ALTER.calculate

      #------------------------------------------------------------------------
      # Functions
      #------------------------------------------------------------------------
      attach_function :OGRGeometryTypeToName, [WKBGeometryType], :string
      attach_function :OGRMergeGeometryTypes,
                      [WKBGeometryType, WKBGeometryType],
                      WKBGeometryType
      # TODO: use this
      attach_function :OGRParseDate, [:string, FFI::OGR::Field.ptr, :int], :bool
    end
  end
end
