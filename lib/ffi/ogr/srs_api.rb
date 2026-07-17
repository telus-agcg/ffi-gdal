# frozen_string_literal: true

require "ffi"
require_relative "../gdal"
require_relative "../../ext/ffi_library_function_checks"

module FFI
  module OGR
    module SRSAPI
      extend ::FFI::Library

      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

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

      # https://gdal.org/api/ogr_srs_api.html#_CPPv422OSRAxisMappingStrategy
      OSRAxisMappingStrategy = enum(
        :OAMS_TRADITIONAL_GIS_ORDER, 0,
        :OAMS_AUTHORITY_COMPLIANT, 1,
        :OAMS_CUSTOM, 2
      )

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
      attach_function :OSRAxisEnumToName, [AxisOrientation], :strptr

      # ~~~~~~~~~~~~~
      # SpatialReference
      # ~~~~~~~~~~~~~

      # https://gdal.org/api/ogr_srs_api.html#_CPPv417OSRGetPROJVersionPiPiPi
      attach_function :OSRGetPROJVersion, %i[pointer pointer pointer], :void

      attach_function :OSRNewSpatialReference, %i[string], :OGRSpatialReferenceH
      attach_function :OSRCloneGeogCS, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
      attach_function :OSRClone, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
      attach_function :OSRDestroySpatialReference, %i[OGRSpatialReferenceH], :void
      attach_function :OSRReference, %i[OGRSpatialReferenceH], :int
      attach_function :OSRDereference, %i[OGRSpatialReferenceH], :int
      attach_function :OSRRelease, %i[OGRSpatialReferenceH], :void

      attach_function :OSRValidate, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRFixupOrdering, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRFixup, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRStripCTParms, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err

      attach_function :OSRImportFromEPSG, %i[OGRSpatialReferenceH int], FFI::OGR::Core::Err
      attach_function :OSRImportFromEPSGA, %i[OGRSpatialReferenceH int], FFI::OGR::Core::Err
      attach_function :OSRImportFromWkt, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRImportFromProj4, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRImportFromESRI, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRImportFromPCI,
                      %i[OGRSpatialReferenceH string string pointer],
                      FFI::OGR::Core::Err
      attach_function :OSRImportFromUSGS,
                      %i[OGRSpatialReferenceH long long pointer long],
                      FFI::OGR::Core::Err
      attach_function :OSRImportFromXML, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRImportFromMICoordSys, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRImportFromERM,
                      %i[OGRSpatialReferenceH string string string],
                      FFI::OGR::Core::Err
      attach_function :OSRImportFromUrl, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err

      attach_function :OSRExportToWkt, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRExportToPrettyWkt, %i[OGRSpatialReferenceH pointer bool], FFI::OGR::Core::Err
      attach_function :OSRExportToProj4, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRExportToPCI,
                      %i[OGRSpatialReferenceH pointer pointer pointer],
                      FFI::OGR::Core::Err
      attach_function :OSRExportToUSGS,
                      %i[OGRSpatialReferenceH pointer pointer pointer pointer],
                      FFI::OGR::Core::Err
      attach_function :OSRExportToXML, %i[OGRSpatialReferenceH pointer buffer_out], FFI::OGR::Core::Err
      attach_function :OSRExportToMICoordSys, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRExportToERM,
                      %i[OGRSpatialReferenceH buffer_out buffer_out buffer_out],
                      FFI::OGR::Core::Err
      attach_function :OSRMorphToESRI, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRMorphFromESRI, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err

      attach_function :OSRSetAttrValue, %i[OGRSpatialReferenceH string string], FFI::OGR::Core::Err
      attach_function :OSRGetAttrValue, %i[OGRSpatialReferenceH string int], :string
      attach_function :OSRSetAngularUnits, %i[OGRSpatialReferenceH string double], FFI::OGR::Core::Err
      attach_function :OSRGetAngularUnits, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRSetLinearUnits, %i[OGRSpatialReferenceH string double], FFI::OGR::Core::Err
      attach_function :OSRGetLinearUnits, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRSetTargetLinearUnits, %i[OGRSpatialReferenceH string string double], FFI::OGR::Core::Err
      attach_function :OSRGetTargetLinearUnits, %i[OGRSpatialReferenceH string pointer], :double
      attach_function :OSRGetPrimeMeridian, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRSetLinearUnitsAndUpdateParameters,
                      %i[OGRSpatialReferenceH string double],
                      FFI::OGR::Core::Err
      attach_function :OSRGetSemiMajor, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRGetSemiMinor, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRGetInvFlattening, %i[OGRSpatialReferenceH pointer], :double
      attach_function :OSRSetAuthority,
                      %i[OGRSpatialReferenceH string string int],
                      FFI::OGR::Core::Err
      attach_function :OSRGetAuthorityCode, %i[OGRSpatialReferenceH string], :strptr
      attach_function :OSRGetAuthorityName, %i[OGRSpatialReferenceH string], :strptr
      attach_function :OSRSetProjection, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetProjParm, %i[OGRSpatialReferenceH string double], FFI::OGR::Core::Err
      attach_function :OSRGetProjParm,
                      %i[OGRSpatialReferenceH string double pointer],
                      :double
      attach_function :OSRSetNormProjParm, %i[OGRSpatialReferenceH string double], FFI::OGR::Core::Err
      attach_function :OSRGetNormProjParm,
                      %i[OGRSpatialReferenceH string double pointer],
                      :double
      attach_function :OSRSetUTM, %i[OGRSpatialReferenceH int bool], FFI::OGR::Core::Err
      attach_function :OSRGetUTMZone, %i[OGRSpatialReferenceH pointer], :int
      attach_function :OSRSetStatePlane, %i[OGRSpatialReferenceH int bool], FFI::OGR::Core::Err
      attach_function :OSRSetStatePlaneWithUnits,
                      %i[OGRSpatialReferenceH int int string double],
                      FFI::OGR::Core::Err
      attach_function :OSRAutoIdentifyEPSG, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSREPSGTreatsAsLatLong, %i[OGRSpatialReferenceH], :bool
      attach_function :OSREPSGTreatsAsNorthingEasting, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRGetAxis,
                      %i[OGRSpatialReferenceH string int pointer],
                      :string

      # https://gdal.org/api/ogr_srs_api.html#_CPPv425OSRGetAxisMappingStrategy20OGRSpatialReferenceH
      attach_function :OSRGetAxisMappingStrategy, %i[OGRSpatialReferenceH], OSRAxisMappingStrategy

      # https://gdal.org/api/ogr_srs_api.html#_CPPv425OSRGetAxisMappingStrategy20OGRSpatialReferenceH
      attach_function :OSRSetAxisMappingStrategy, [:OGRSpatialReferenceH, OSRAxisMappingStrategy], :void

      attach_function :OSRSetACEA,
                      %i[OGRSpatialReferenceH double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetAE,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetBonne,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetCEA,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetCS,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEC,
                      %i[OGRSpatialReferenceH double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEckert,
                      %i[OGRSpatialReferenceH int double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEckertIV,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEckertVI,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEquirectangular,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetEquirectangular2,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGS,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGH,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetIGH,
                      %i[OGRSpatialReferenceH],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGEOS,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGaussSchreiberTMercator,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetGnomonic,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetHOM,
                      %i[OGRSpatialReferenceH double double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetHOM2PNO,
                      %i[OGRSpatialReferenceH double double double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetIWMPolyconic,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetKrovak,
                      %i[OGRSpatialReferenceH double double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetLAEA,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetLCC,
                      %i[OGRSpatialReferenceH double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetLCC1SP,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetLCCB,
                      %i[OGRSpatialReferenceH double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetMC,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetMercator,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetMollweide,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetNZMG,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetOS,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetOrthographic,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetPolyconic,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetPS,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetRobinson,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetSinusoidal,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetStereographic,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetSOC,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetTM,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetTMVariant,
                      %i[OGRSpatialReferenceH string double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetTMG,
                      %i[OGRSpatialReferenceH double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetTMSO,
                      %i[OGRSpatialReferenceH double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetVDG,
                      %i[OGRSpatialReferenceH double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetWagner,
                      %i[OGRSpatialReferenceH int double double],
                      FFI::OGR::Core::Err

      attach_function :OSRIsGeographic, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsLocal, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsProjected, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsCompound, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsGeocentric, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsVertical, %i[OGRSpatialReferenceH], :bool
      attach_function :OSRIsSameGeogCS, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool
      attach_function :OSRIsSameVertCS, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool
      attach_function :OSRIsSame, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool

      attach_function :OSRSetLocalCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetProjCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetGeocCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetGeogCS,
                      %i[OGRSpatialReferenceH
                         string string string
                         double double string
                         double string double],
                      FFI::OGR::Core::Err
      attach_function :OSRSetWellKnownGeogCS, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRSetFromUserInput, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRCopyGeogCSFrom, %i[OGRSpatialReferenceH OGRSpatialReferenceH], FFI::OGR::Core::Err
      attach_function :OSRSetTOWGS84,
                      %i[OGRSpatialReferenceH double double double double double double double],
                      FFI::OGR::Core::Err
      attach_function :OSRGetTOWGS84, %i[OGRSpatialReferenceH pointer int], FFI::OGR::Core::Err
      attach_function :OSRSetVertCS, %i[OGRSpatialReferenceH string string int], FFI::OGR::Core::Err
      attach_function :OSRSetCompoundCS,
                      %i[OGRSpatialReferenceH string OGRSpatialReferenceH OGRSpatialReferenceH],
                      FFI::OGR::Core::Err

      attach_function :OSRCleanup, [], :void

      # ~~~~~~~~~~~~~
      # CoordinateTransformations
      # ~~~~~~~~~~~~~
      attach_function :OCTDestroyCoordinateTransformation,
                      %i[OGRCoordinateTransformationH],
                      :void
      attach_function :OCTNewCoordinateTransformation,
                      %i[OGRSpatialReferenceH OGRSpatialReferenceH],
                      :OGRCoordinateTransformationH
      attach_function :OCTTransform,
                      %i[OGRCoordinateTransformationH int pointer pointer pointer],
                      :bool
      attach_function :OCTTransformEx,
                      %i[OGRCoordinateTransformationH int pointer pointer pointer pointer],
                      :bool

      # ~~~~~~~~~~~~~
      # Parameters
      # ~~~~~~~~~~~~~
      attach_function :OPTGetProjectionMethods, %i[], :pointer
      attach_function :OPTGetParameterList, %i[string pointer], :pointer
      attach_function :OPTGetParameterInfo,
                      %i[string string pointer pointer pointer],
                      :int
    end
  end
end
