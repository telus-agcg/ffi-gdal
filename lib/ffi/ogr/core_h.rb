module FFI
  module GDAL

    #------------------------------------------------------------------------
    # Enums
    #------------------------------------------------------------------------
    # The C API defines :OGRErr as a function that returns constants.  I'm
    # taking the liberty to turn this into an enum.
    OGRErr = enum :OGRERR_NONE,
      :OGRERR_NOT_ENOUGH_DATA,
      :OGRERR_NOT_ENOUGH_MEMORY,
      :OGRERR_UNSUPPORTED_GEOMETRY_TYPE,
      :OGRERR_UNSUPPORTED_OPERATION,
      :OGRERR_CORRUPT_DATA,
      :OGRERR_FAILURE,
      :OGRERR_UNSUPPORTED_SRS,
      :OGRERR_INVALID_HANDLE

    OGRwkbGeometryType = enum :wkbUnknown, 0,
      :wkbPoint,                  1,
      :wkbLineString,             2,
      :wkbPolygon,                3,
      :wkbMultiPoint,             4,
      :wkbMultiLineString,        5,
      :wkbMultiPolygon,           6,
      :wkbGeometryCollection,     7,
      :wkbNone,                   100,
      :wkbLinearRing,             101,
      :wkbPoint25D,               0x80000001,
      :wkbLineString25D,          0x80000002,
      :wkbPolygon25D,             0x80000003,
      :wkbMultiPoint25D,          0x80000004,
      :wkbMultiLineString25D,     0x80000005,
      :wkbMultiPolygon25D,        0x80000006,
      :wkbGeometryCollection25D,  0x80000007

    OGRwkbVariant = enum :wkbVariantOgc, :wkbVariantIso
    OGRwkbByteOrder = enum :wkbXDR, 0,
      :wkbNDR, 1

    OGRFieldType = enum :OFTInteger, 0,
      :OFTIntegerList,     1,
      :OFTReal,            2,
      :OFTRealList,        3,
      :OFTString,          4,
      :OFTStringList,      5,
      :OFTWideString,      6,
      :OFTWideStringList,  7,
      :OFTBinary,          8,
      :OFTDate,            9,
      :OFTTime,            10,
      :OFTDateTime,        11,
      :OFTMaxType,         11

    OGRJustification = enum :OJUndefined, 0,
      :OJLeft,   1,
      :OJRight,  2

    OGRSTClassId = enum :OGRSTCNone, 0,
      :OGRSTCPen,     1,
      :OGRSTCBrush,   2,
      :OGRSTCSymbol,  3,
      :OGRSTCLabel,   4,
      :OGRSTCVector,  5

    OGRSTUnitId = enum :OGRSTUGround, 0,
      :OGRSTUPixel,   1,
      :OGRSTUPoints,  2,
      :OGRSTUMM,      3,
      :OGRSTUCM,      4,
      :OGRSTUInches,  5

    OGRSTPenParam = enum :OGRSTPenColor, 0,
      :OGRSTPenWidth,       1,
      :OGRSTPenPattern,     2,
      :OGRSTPenId,          3,
      :OGRSTPenPerOffset,   4,
      :OGRSTPenPerCap,      5,
      :OGRSTPenPerJoin,     6,
      :OGRSTPenPerPriority, 7,
      :OGRSTPenLast,        8

    OGRSTBrushParam = enum :OGRSTBrushFColor, 0,
      :OGRSTBrushBColor,    1,
      :OGRSTBrushId,        2,
      :OGRSTBrushAngle,     3,
      :OGRSTBrushSize,      4,
      :OGRSTBrushDx,        5,
      :OGRSTBrushDy,        6,
      :OGRSTBrushPriority,  7,
      :OGRSTBrushLast,      8

    OGRSTSymbolParam = enum :OGRSTSymbolId, 0,
      :OGRSTSymbolAngle,     1,
      :OGRSTSymbolColor,     2,
      :OGRSTSymbolSize,      3,
      :OGRSTSymbolDx,        4,
      :OGRSTSymbolDy,        5,
      :OGRSTSymbolStep,      6,
      :OGRSTSymbolPerp,      7,
      :OGRSTSymbolOffset,    8,
      :OGRSTSymbolPriority,  9,
      :OGRSTSymbolFontName, 10,
      :OGRSTSymbolOColor,   11,
      :OGRSTSymbolLast,      12

    OGRSTLabelParam = enum :OGRSTLabelFontName, 0,
      :OGRSTLabelSize,        1,
      :OGRSTLabelTextString,  2,
      :OGRSTLabelAngle,       3,
      :OGRSTLabelFColor,      4,
      :OGRSTLabelBColor,      5,
      :OGRSTLabelPlacement,   6,
      :OGRSTLabelAnchor,      7,
      :OGRSTLabelDx,          8,
      :OGRSTLabelDy,          9,
      :OGRSTLabelPerp,        10,
      :OGRSTLabelBold,        11,
      :OGRSTLabelItalic,      12,
      :OGRSTLabelUnderline,   13,
      :OGRSTLabelPriority,    14,
      :OGRSTLabelStrikeout,   15,
      :OGRSTLabelStretch,     16,
      :OGRSTLabelAdjHor,      17,
      :OGRSTLabelAdjVert,     18,
      :OGRSTLabelHColor,      19,
      :OGRSTLabelOColor,      20,
      :OGRSTLabelLast,        21

    #------------------------------------------------------------------------
    # Typedefs
    #------------------------------------------------------------------------
    typedef :int, :OGRBoolean

    #------------------------------------------------------------------------
    # Functions
    #------------------------------------------------------------------------
    attach_function :OGRMalloc, [:size_t], :pointer
    attach_function :OGRCalloc, [:size_t, :size_t], :pointer
    attach_function :OGRRealloc, [:pointer, :size_t], :pointer
    attach_function :OGRFree, [:pointer], :void
    attach_function :OGRGeometryTypeToName, [OGRwkbGeometryType], :string
    attach_function :OGRMergeGeometryTypes,
      [OGRwkbGeometryType, OGRwkbGeometryType],
      OGRwkbGeometryType
    attach_function :OGRParseDate, [:string, :pointer, :int], :int
  end
end
