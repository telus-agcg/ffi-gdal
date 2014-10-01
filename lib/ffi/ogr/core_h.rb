module FFI
  module GDAL

    #------------------------------------------------------------------------
    # Defines
    #------------------------------------------------------------------------
    OGRERR_NONE                       = 0
    OGRERR_NOT_ENOUGH_DATA            = 1
    OGRERR_NOT_ENOUGH_MEMORY          = 2
    OGRERR_UNSUPPORTED_GEOMETRY_TYPE  = 3
    OGRERR_UNSUPPORTED_OPERATION      = 4
    OGRERR_CORRUPT_DATA               = 5
    OGRERR_FAILURE                    = 6
    OGRERR_UNSUPPORTED_SRS            = 7
    OGRERR_INVALID_HANDLE             = 8

    WKB_25D_BIT = 0x80000000
    #WKB_FLATTEN
    OGR_Z_MARKER = 0x21125711

    ALTER_NAME_FLAG = 0x1
    ALTER_TYPE_FLAG = 0x2
    ALTER_WIDTH_PRECISION_FLAG = 0x4
    ALTER_ALL_FLAG =
      ALTER_NAME_FLAG | ALTER_TYPE_FLAG | ALTER_WIDTH_PRECISION_FLAG

    OGRNullFID = -1
    OGRUnsetMarker = -21121
    OLCRandomRead = 'RandomRead'
    OLCSequentialWrite = 'SequentialWrite'
    OLCRandomeWrite = 'RandomWrite'
    OLCFastSpatialFilter = 'FastSpatialFilter'
    OLCFastFeatureCount = 'FastFeatureCount'
    OLCFastGetExtent = 'FastGetExtent'
    OLCCreateField = 'CreateField'
    OLCDeleteField = 'DeleteField'
    OLCReorderFields = 'ReorderFields'
    OLCAlterFieldDefn = 'AlterFieldDefn'
    OLCTransactions = 'Transactions'
    OLCDeleteFeature = 'DeleteFeature'
    OLCFastSetNextByIndex = 'FastSetNextByIndex'
    OLCStringsAsUTF8 = 'StringsAsUTF8'
    OLCIgnoreFields = 'IgnoreFields'
    OLCCreateGeomField = 'CreateGeomField'

    ODsCCreateLayer = 'CreateLayer'
    ODsCDeleteLayer = 'DeleteLayer'
    ODsCCreateGeomFieldAfterCreateLayer = 'CreateGeomFieldAfterCreateLayer'

    ODrCCreateDataSource = 'CreateDataSource'
    ODrCDeleteDataSource = 'DeleteDataSource'

    #------------------------------------------------------------------------
    # Enums
    #------------------------------------------------------------------------
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
    typedef :int, :OGRErr
    typedef :int, :OGRBoolean
    # typedef OGRStyleToolClassID, :OGRSTClassId
    # typedef OGRStyleToolUnitsID, :OGRSTUnitId
    # typedef OGRStyleToolParamPenID, :OGRSTPenParam
    # typedef OGRStyleToolParamBrushID, :OGRSTBrushParam
    # typedef OGRStyleToolParamSymbolID, :OGRSTSymbolParam
    # typedef OGRStyleToolParamLabelID, :OGRSTLabelParam

    #------------------------------------------------------------------------
    # Functions
    #------------------------------------------------------------------------
    attach_function :OGRMalloc, [:size_t], :pointer
    attach_function :OGRCalloc, [:size_t, :size_t], :pointer
    attach_function :OGRRealloc, [:pointer, :size_t], :pointer
    #attach_function :OGRStrdup, [:string], :string
    attach_function :OGRFree, [:pointer], :void
    attach_function :OGRGeometryTypeToName, [OGRwkbGeometryType], :string
    attach_function :OGRMergeGeometryTypes,
      [OGRwkbGeometryType, OGRwkbGeometryType],
      OGRwkbGeometryType
    attach_function :OGRParseDate, [:string, :pointer, :int], :int
  end
end
