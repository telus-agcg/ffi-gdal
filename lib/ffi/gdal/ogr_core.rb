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
    OGRwkbGeometryType = enum :wkb_unknown, 0,
      :wkb_point,                   1,
      :wkb_line_string,             2,
      :wkb_polygon,                 3,
      :wkb_multi_point,             4,
      :wkb_multi_line_string,       5,
      :wkb_mulit_polygon,           6,
      :wkb_geometry_collection,     7,
      :wkb_none,                    100,
      :wkb_linear_ring,             101,
      :wkb_point_25d,               0x80000001,
      :wkb_line_string_25d,         0x80000002,
      :wkb_polygon_25d,             0x80000003,
      :wkb_multi_point_25d,         0x80000004,
      :wkb_multi_line_string_25d,   0x80000005,
      :wkb_multi_polygon_25d,       0x80000006,
      :wkb_geometry_collection_25d, 0x80000007

    OGRwkbVariant = enum :wkb_variant_ogc, :wkb_variant_iso
    OGRwkbByteOrder = enum :wkb_xdr, 0,
      :wkb_ndr, 1

    OGRFieldType = enum :oft_integer, 0,
      :oft_integer_list,      1,
      :oft_real,              2,
      :oft_real_list,         3,
      :oft_string,            4,
      :oft_string_list,       5,
      :oft_wide_string,       6,
      :oft_wide_string_list,  7,
      :oft_binary,            8,
      :oft_date,              9,
      :oft_time,              10,
      :oft_date_time,         11,
      :oft_max_type,          11

    OGRJustification = enum :oj_undefined, 0,
      :oj_left,   1,
      :oj_right,  2

    OGRStyleToolClassID = enum :ogr_stc_none, 0,
      :ogr_stc_pen,     1,
      :ogr_stc_brush,   2,
      :ogr_stc_symbol,  3,
      :ogr_stc_label,   4,
      :ogr_stc_vector,  5

    OGRStyleToolUnitsID = enum :ogr_stu_ground, 0,
      :ogr_stu_pixel,   1,
      :ogr_stu_points,  2,
      :ogr_stu_mm,      3,
      :ogr_stu_cm,      4,
      :ogr_stu_inches,  5

    OGRStyleToolParamPenID = enum :ogr_st_pen_color, 0,
      :ogr_st_pen_width,        1,
      :ogr_st_pen_pattern,      2,
      :ogr_st_pen_id,           3,
      :ogr_st_pen_per_offset,   4,
      :ogr_st_pen_per_cap,      5,
      :ogr_st_pen_per_join,     6,
      :ogr_st_pen_per_priority, 7,
      :ogr_st_pen_last,         8

    OGRStyleToolParamBrushID = enum :ogr_st_brush_f_color, 0,
      :ogr_st_brush_b_color,  1,
      :ogr_st_brush_id,       2,
      :ogr_st_brush_angle,    3,
      :ogr_st_brush_size,     4,
      :ogr_st_brush_dx,       5,
      :ogr_st_brush_dry,      6,
      :ogr_st_brush_priority, 7,
      :ogr_st_brush_last,     8

    OGRStyleToolParamSymbolID = enum :ogr_st_symbol_id, 0,
      :ogr_st_symbol_angle,     1,
      :ogr_st_symbol_color,     2,
      :ogr_st_symbol_size,      3,
      :ogr_st_symbol_dx,        4,
      :ogr_st_symbol_dy,        5,
      :ogr_st_symbol_step,      6,
      :ogr_st_symbol_perp,      7,
      :ogr_st_symbol_offset,    8,
      :ogr_st_symbol_priority,  9,
      :ogr_st_symbol_font_name, 10,
      :ogr_st_symbol_o_color,   11,
      :ogr_st_symbol_last,      12

    OGRStyleToolParamLabelID = enum :ogr_st_label_font_name, 0,
      :ogr_st_label_size,         1,
      :ogr_st_label_text_string,  2,
      :ogr_st_label_angle,        3,
      :ogr_st_label_f_color,      4,
      :ogr_st_label_b_color,      5,
      :ogr_st_label_placement,    6,
      :ogr_st_label_anchor,       7,
      :ogr_st_label_dx,           8,
      :ogr_st_label_dy,           9,
      :ogr_st_label_perp,         10,
      :ogr_st_label_bold,         11,
      :ogr_st_label_italic,       12,
      :ogr_st_label_underline,    13,
      :ogr_st_label_priority,     14,
      :ogr_st_label_strikeout,    15,
      :ogr_st_label_stretch,      16,
      :ogr_st_label_adj_hor,      17,
      :ogr_st_label_adj_vert,     18,
      :ogr_st_label_h_color,      19,
      :ogr_st_label_o_color,      20,
      :ogr_st_label_last,         21

    #------------------------------------------------------------------------
    # Typedefs
    #------------------------------------------------------------------------
    typedef :int, :OGRErr
    typedef :int, :OGRBoolean
    typedef OGRStyleToolClassID, :OGRSTClassId
    typedef OGRStyleToolUnitsID, :OGRSTUnitId
    typedef OGRStyleToolParamPenID, :OGRSTPenParam
    typedef OGRStyleToolParamBrushID, :OGRSTBrushParam
    typedef OGRStyleToolParamSymbolID, :OGRSTSymbolParam
    typedef OGRStyleToolParamLabelID, :OGRSTLabelParam

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
    attach_function :GDALVersionInfo, [:string], :string
    attach_function :GDALCheckVersion, [:int, :int, :string], :int
  end
end
