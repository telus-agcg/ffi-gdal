module FFI
  module GDAL
    autoload :OGRStyleParam,
      File.expand_path('ogr_style_param', __dir__)
    autoload :OGRStyleValue,
      File.expand_path('ogr_style_value', __dir__)

    #------------------------------------------------------------------------
    # Enums
    #------------------------------------------------------------------------
    OGRStyleType = enum :OGRSTypeString,
      :OGRSTypeDouble,
      :OGRSTypeInteger,
      :OGRSTypeBoolean

    #------------------------------------------------------------------------
    # Typedefs
    #------------------------------------------------------------------------
    OGRSType = OGRStyleType
    OGRStyleParamId = OGRStyleParam
  end
end
