# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module OGR
    module SRSAPI
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      # -----------------------------------------------------------------------
      # Enums
      # -----------------------------------------------------------------------
      AxisOrientation = enum :OAO_Other, 0,
                             :OAO_North, 1,
                             :OAO_South, 2,
                             :OAO_East, 3,
                             :OAO_West, 4,
                             :OAO_Up, 5,
                             :OAO_Down, 6

      DatumType = enum :ODT_HD_Min, 1000,
                       :ODT_HD_Other, 1000,
                       :ODT_HD_Classic, 1001,
                       :ODT_HD_Geocentric, 1002,
                       :ODT_HD_Max, 1999,
                       :ODT_VD_Min, 2000,
                       :ODT_VD_Other, 2000,
                       :ODT_VD_Orthometric, 2001,
                       :ODT_VD_Ellipsoidal, 2002,
                       :ODT_VD_AltitudeBarometric, 2003,
                       :ODT_VD_Normal, 2004,
                       :ODT_VD_GeoidModelDerived, 2005,
                       :ODT_VD_Depth, 2006,
                       :ODT_VD_Max, 2999,
                       :ODT_LD_Min, 10_000,
                       :ODT_LD_Max, 32_767

      # -----------------------------------------------------------------------
      # Constants
      # -----------------------------------------------------------------------
      SRS_UL = FFI::ConstGenerator.new('SRS_UL')

      if (path = FFI::GDAL._file_with_constants('ogr_srs_api.h'))
        SRS_UL.include(path)
        floater = ->(thing) { thing.to_f }
        SRS_UL.const :SRS_UL_METER,              '%s', nil, :METER_LABEL
        SRS_UL.const :SRS_UL_FOOT,               '%s', nil, :FOOT_LABEL
        SRS_UL.const :SRS_UL_FOOT_CONV,          '%s', nil, :METER_TO_FOOT, floater
        SRS_UL.const :SRS_UL_NAUTICAL_MILE,      '%s', nil, :NAUTICAL_MILE_LABEL
        SRS_UL.const :SRS_UL_NAUTICAL_MILE_CONV, '%s', nil, :METER_TO_NAUTICAL_MILE, floater
        SRS_UL.const :SRS_UL_LINK,               '%s', nil, :LINK_LABEL
        SRS_UL.const :SRS_UL_LINK_CONV,          '%s', nil, :METER_TO_LINK, floater
        SRS_UL.const :SRS_UL_CHAIN,              '%s', nil, :CHAIN_LABEL
        SRS_UL.const :SRS_UL_CHAIN_CONV,         '%s', nil, :METER_TO_CHAIN, floater
        SRS_UL.const :SRS_UL_ROD,                '%s', nil, :ROD_LABEL
        SRS_UL.const :SRS_UL_ROD_CONV,           '%s', nil, :METER_TO_ROD, floater
        SRS_UL.const :SRS_UL_LINK_Clarke,        '%s', nil, :LINK_CLARKE_LABEL
        SRS_UL.const :SRS_UL_LINK_Clarke_CONV,   '%s', nil, :METER_TO_LINK_CLARKE, floater
        SRS_UL.const :SRS_UL_KILOMETER,          '%s', nil, :KILOMETER_LABEL
        SRS_UL.const :SRS_UL_KILOMETER_CONV,     '%s', nil, :METER_TO_KILOMETER, floater
        SRS_UL.const :SRS_UL_DECIMETER,          '%s', nil, :DECIMETER_LABEL
        SRS_UL.const :SRS_UL_DECIMETER_CONV,     '%s', nil, :METER_TO_DECIMETER, floater
        SRS_UL.const :SRS_UL_CENTIMETER,         '%s', nil, :CENTIMETER_LABEL
        SRS_UL.const :SRS_UL_CENTIMETER_CONV,    '%s', nil, :METER_TO_CENTIMETER, floater
        SRS_UL.const :SRS_UL_MILLIMETER,         '%s', nil, :MILLIMETER_LABEL
        SRS_UL.const :SRS_UL_MILLIMETER_CONV,    '%s', nil, :METER_TO_MILLIMETER, floater
        SRS_UL.const :SRS_UL_INTL_NAUT_MILE,     '%s', nil, :INTL_NAUTICAL_MILE_LABEL
        SRS_UL.const :SRS_UL_INTL_NAUT_MILE_CONV, '%s', nil, :METER_TO_INTL_NAUTICAL_MILE, floater
        SRS_UL.const :SRS_UL_INTL_INCH,          '%s', nil, :INTL_INCH_LABEL
        SRS_UL.const :SRS_UL_INTL_INCH_CONV,     '%s', nil, :METER_TO_INTL_INCH, floater
        SRS_UL.const :SRS_UL_INTL_FOOT,          '%s', nil, :INTL_FOOT_LABEL
        SRS_UL.const :SRS_UL_INTL_FOOT_CONV,     '%s', nil, :METER_TO_INTL_FOOT, floater
        SRS_UL.const :SRS_UL_INTL_YARD,          '%s', nil, :INTL_YARD_LABEL
        SRS_UL.const :SRS_UL_INTL_YARD_CONV,     '%s', nil, :METER_TO_INTL_YARD, floater
        SRS_UL.const :SRS_UL_INTL_STAT_MILE,     '%s', nil, :INTL_STATUTE_MILE_LABEL
        SRS_UL.const :SRS_UL_INTL_STAT_MILE_CONV, '%s', nil, :METER_TO_INTL_STATUTE_MILE, floater
        SRS_UL.const :SRS_UL_INTL_FATHOM,        '%s', nil, :INTL_FATHOM_LABEL
        SRS_UL.const :SRS_UL_INTL_FATHOM_CONV,   '%s', nil, :METER_TO_INTL_FATHOM, floater
        SRS_UL.const :SRS_UL_INTL_CHAIN,         '%s', nil, :INTL_CHAIN_LABEL
        SRS_UL.const :SRS_UL_INTL_CHAIN_CONV,    '%s', nil, :METER_TO_INTL_CHAIN, floater
        SRS_UL.const :SRS_UL_INTL_LINK,          '%s', nil, :INTL_LINK_LABEL
        SRS_UL.const :SRS_UL_INTL_LINK_CONV,     '%s', nil, :METER_TO_INTL_LINK, floater
        SRS_UL.const :SRS_UL_US_INCH,            '%s', nil, :US_INCH_LABEL
        SRS_UL.const :SRS_UL_US_INCH_CONV,       '%s', nil, :METER_TO_US_INCH, floater
        SRS_UL.const :SRS_UL_US_FOOT,            '%s', nil, :US_FOOT_LABEL
        SRS_UL.const :SRS_UL_US_FOOT_CONV,       '%s', nil, :METER_TO_US_FOOT, floater
        SRS_UL.const :SRS_UL_US_YARD,            '%s', nil, :US_YARD_LABEL
        SRS_UL.const :SRS_UL_US_YARD_CONV,       '%s', nil, :METER_TO_US_YARD, floater
        SRS_UL.const :SRS_UL_US_CHAIN,           '%s', nil, :US_CHAIN_LABEL
        SRS_UL.const :SRS_UL_US_CHAIN_CONV,      '%s', nil, :METER_TO_US_CHAIN, floater
        SRS_UL.const :SRS_UL_US_STAT_MILE,       '%s', nil, :US_STATUTE_MILE_LABEL
        SRS_UL.const :SRS_UL_US_STAT_MILE_CONV,  '%s', nil, :METER_TO_US_STATUTE_MILE, floater
        SRS_UL.const :SRS_UL_INDIAN_YARD,        '%s', nil, :INDIAN_YARD_LABEL
        SRS_UL.const :SRS_UL_INDIAN_YARD_CONV,   '%s', nil, :METER_TO_INDIAN_YARD, floater
        SRS_UL.const :SRS_UL_INDIAN_FOOT,        '%s', nil, :INDIAN_FOOT_LABEL
        SRS_UL.const :SRS_UL_INDIAN_FOOT_CONV,   '%s', nil, :METER_TO_INDIAN_FOOT, floater
        SRS_UL.const :SRS_UL_INDIAN_CHAIN,       '%s', nil, :INDIAN_CHAIN_LABEL
        SRS_UL.const :SRS_UL_INDIAN_CHAIN_CONV,  '%s', nil, :METER_TO_INDIAN_CHAIN, floater
      end

      # Intentionally not using block form here to save loading constants until
      # they're needed.
      SRS_UA = ::FFI::ConstGenerator.new('SRS_UL')

      if (path = FFI::GDAL._file_with_constants('ogr_srs_api.h'))
        SRS_UA.include(path)
        SRS_UA.const :SRS_UA_DEGREE,       '%s', nil, :DEGREE_LABEL
        SRS_UA.const :SRS_UA_DEGREE_CONV,  '%s', nil, :RADIAN_TO_DEGREE, ->(thing) { thing.to_f }
        SRS_UA.const :SRS_UA_RADIAN,       '%s', nil, :RADIAN_LABEL
      end

      # -----------------------------------------------------------------------
      # Typedefs
      # -----------------------------------------------------------------------
      typedef :pointer, :OGRSpatialReferenceH
      typedef :pointer, :OGRCoordinateTransformationH

      # -----------------------------------------------------------------------
      # Functions
      # -----------------------------------------------------------------------
      # ~~~~~~~~~~~~~
      # AxisOrientations
      # ~~~~~~~~~~~~~
      attach_gdal_function :OSRAxisEnumToName, [AxisOrientation], :strptr

      # ~~~~~~~~~~~~~
      # SpatialReference
      # ~~~~~~~~~~~~~
      attach_gdal_function :OSRNewSpatialReference, %i[string], :OGRSpatialReferenceH
      attach_gdal_function :OSRCloneGeogCS, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
      attach_gdal_function :OSRClone, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
      attach_gdal_function :OSRDestroySpatialReference, %i[OGRSpatialReferenceH], :void
      attach_gdal_function :OSRReference, %i[OGRSpatialReferenceH], :int
      attach_gdal_function :OSRDereference, %i[OGRSpatialReferenceH], :int
      attach_gdal_function :OSRRelease, %i[OGRSpatialReferenceH], :void

      attach_gdal_function :OSRValidate, %i[OGRSpatialReferenceH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRFixupOrdering, %i[OGRSpatialReferenceH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRFixup, %i[OGRSpatialReferenceH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRStripCTParms, %i[OGRSpatialReferenceH], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OSRImportFromEPSG, %i[OGRSpatialReferenceH int], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromEPSGA, %i[OGRSpatialReferenceH int], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromWkt, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromProj4, %i[OGRSpatialReferenceH string], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromESRI, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromPCI,
                           %i[OGRSpatialReferenceH string string pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromUSGS,
                           %i[OGRSpatialReferenceH long long pointer long],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromXML, %i[OGRSpatialReferenceH string], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromMICoordSys, %i[OGRSpatialReferenceH string], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromERM,
                           %i[OGRSpatialReferenceH string string string],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRImportFromUrl, %i[OGRSpatialReferenceH string], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OSRExportToWkt, %i[OGRSpatialReferenceH buffer_out], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRExportToPrettyWkt, %i[OGRSpatialReferenceH buffer_out bool],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRExportToProj4, %i[OGRSpatialReferenceH buffer_out], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRExportToPCI,
                           %i[OGRSpatialReferenceH buffer_out buffer_out buffer_out],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRExportToUSGS,
                           %i[OGRSpatialReferenceH buffer_out buffer_out buffer_out buffer_out],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRExportToXML, %i[OGRSpatialReferenceH buffer_out pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRExportToMICoordSys, %i[OGRSpatialReferenceH buffer_out],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRExportToERM,
                           %i[OGRSpatialReferenceH buffer_out buffer_out buffer_out],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRMorphToESRI, %i[OGRSpatialReferenceH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRMorphFromESRI, %i[OGRSpatialReferenceH], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OSRSetAttrValue, %i[OGRSpatialReferenceH string string], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetAttrValue, %i[OGRSpatialReferenceH string int], :string
      attach_gdal_function :OSRSetAngularUnits, %i[OGRSpatialReferenceH string double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetAngularUnits, %i[OGRSpatialReferenceH pointer], :double
      attach_gdal_function :OSRSetLinearUnits, %i[OGRSpatialReferenceH string double], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetLinearUnits, %i[OGRSpatialReferenceH pointer], :double
      attach_gdal_function :OSRSetTargetLinearUnits, %i[OGRSpatialReferenceH string string double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetTargetLinearUnits, %i[OGRSpatialReferenceH string pointer], :double
      attach_gdal_function :OSRGetPrimeMeridian, %i[OGRSpatialReferenceH pointer], :double
      attach_gdal_function :OSRSetLinearUnitsAndUpdateParameters,
                           %i[OGRSpatialReferenceH string double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetSemiMajor, %i[OGRSpatialReferenceH pointer], :double
      attach_gdal_function :OSRGetSemiMinor, %i[OGRSpatialReferenceH pointer], :double
      attach_gdal_function :OSRGetInvFlattening, %i[OGRSpatialReferenceH pointer], :double
      attach_gdal_function :OSRSetAuthority,
                           %i[OGRSpatialReferenceH string string int],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetAuthorityCode, %i[OGRSpatialReferenceH string], :strptr
      attach_gdal_function :OSRGetAuthorityName, %i[OGRSpatialReferenceH string], :strptr
      attach_gdal_function :OSRSetProjection, %i[OGRSpatialReferenceH string], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetProjParm, %i[OGRSpatialReferenceH string double], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetProjParm,
                           %i[OGRSpatialReferenceH string double pointer],
                           :double
      attach_gdal_function :OSRSetNormProjParm, %i[OGRSpatialReferenceH string double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetNormProjParm,
                           %i[OGRSpatialReferenceH string double pointer],
                           :double
      attach_gdal_function :OSRSetUTM, %i[OGRSpatialReferenceH int bool], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetUTMZone, %i[OGRSpatialReferenceH pointer], :int
      attach_gdal_function :OSRSetStatePlane, %i[OGRSpatialReferenceH int bool], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetStatePlaneWithUnits,
                           %i[OGRSpatialReferenceH int int string double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRAutoIdentifyEPSG, %i[OGRSpatialReferenceH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSREPSGTreatsAsLatLong, %i[OGRSpatialReferenceH], :bool
      attach_gdal_function :OSREPSGTreatsAsNorthingEasting, %i[OGRSpatialReferenceH], :bool
      attach_gdal_function :OSRGetAxis,
                           %i[OGRSpatialReferenceH string int pointer],
                           :string

      attach_gdal_function :OSRSetACEA,
                           %i[OGRSpatialReferenceH double double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetAE,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetBonne,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetCEA,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetCS,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetEC,
                           %i[OGRSpatialReferenceH double double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetEckert,
                           %i[OGRSpatialReferenceH int double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetEckertIV,
                           %i[OGRSpatialReferenceH double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetEckertVI,
                           %i[OGRSpatialReferenceH double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetEquirectangular,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetEquirectangular2,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetGS,
                           %i[OGRSpatialReferenceH double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetGH,
                           %i[OGRSpatialReferenceH double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetIGH,
                           %i[OGRSpatialReferenceH],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetGEOS,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetGaussSchreiberTMercator,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetGnomonic,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetHOM,
                           %i[OGRSpatialReferenceH double double double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetHOM2PNO,
                           %i[OGRSpatialReferenceH double double double double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetIWMPolyconic,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetKrovak,
                           %i[OGRSpatialReferenceH double double double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetLAEA,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetLCC,
                           %i[OGRSpatialReferenceH double double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetLCC1SP,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetLCCB,
                           %i[OGRSpatialReferenceH double double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetMC,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetMercator,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetMollweide,
                           %i[OGRSpatialReferenceH double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetNZMG,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetOS,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetOrthographic,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetPolyconic,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetPS,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetRobinson,
                           %i[OGRSpatialReferenceH double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetSinusoidal,
                           %i[OGRSpatialReferenceH double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetStereographic,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetSOC,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetTM,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetTMVariant,
                           %i[OGRSpatialReferenceH string double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetTMG,
                           %i[OGRSpatialReferenceH double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetTMSO,
                           %i[OGRSpatialReferenceH double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetVDG,
                           %i[OGRSpatialReferenceH double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetWagner,
                           %i[OGRSpatialReferenceH int double double],
                           FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OSRIsCompound, %i[OGRSpatialReferenceH], :bool
      attach_gdal_function :OSRIsGeocentric, %i[OGRSpatialReferenceH], :bool
      attach_gdal_function :OSRIsGeographic, %i[OGRSpatialReferenceH], :bool
      attach_gdal_function :OSRIsLocal, %i[OGRSpatialReferenceH], :bool
      attach_gdal_function :OSRIsProjected, %i[OGRSpatialReferenceH], :bool
      attach_gdal_function :OSRIsSame, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool
      attach_gdal_function :OSRIsSameGeogCS, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool
      attach_gdal_function :OSRIsSameVertCS, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool
      attach_gdal_function :OSRIsVertical, %i[OGRSpatialReferenceH], :bool

      attach_gdal_function :OSRSetLocalCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetProjCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetGeocCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetGeogCS,
                           %i[OGRSpatialReferenceH
                              string string string
                              double double string
                              double string double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetWellKnownGeogCS, %i[OGRSpatialReferenceH string],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetFromUserInput, %i[OGRSpatialReferenceH string],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRCopyGeogCSFrom, %i[OGRSpatialReferenceH OGRSpatialReferenceH],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetTOWGS84,
                           %i[OGRSpatialReferenceH double double double double double double double],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRGetTOWGS84, %i[OGRSpatialReferenceH pointer int], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetVertCS, %i[OGRSpatialReferenceH string string int], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OSRSetCompoundCS,
                           %i[OGRSpatialReferenceH string OGRSpatialReferenceH OGRSpatialReferenceH],
                           FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OSRCleanup, [], :void

      # ~~~~~~~~~~~~~
      # CoordinateTransformations
      # ~~~~~~~~~~~~~
      attach_gdal_function :OCTDestroyCoordinateTransformation,
                           %i[OGRCoordinateTransformationH],
                           :void
      attach_gdal_function :OCTNewCoordinateTransformation,
                           %i[OGRSpatialReferenceH OGRSpatialReferenceH],
                           :OGRCoordinateTransformationH
      attach_gdal_function :OCTTransform,
                           %i[OGRCoordinateTransformationH int pointer pointer pointer],
                           :bool
      attach_gdal_function :OCTTransformEx,
                           %i[OGRCoordinateTransformationH int pointer pointer pointer pointer],
                           :bool

      # ~~~~~~~~~~~~~
      # Parameters
      # ~~~~~~~~~~~~~
      attach_gdal_function :OPTGetProjectionMethods, %i[], :pointer
      attach_gdal_function :OPTGetParameterList, %i[string pointer], :pointer
      attach_gdal_function :OPTGetParameterInfo,
                           %i[string string pointer pointer pointer],
                           :int
    end
  end
end
