module FFI
  module GDAL

    #------------------------------------------------------------------------
    # Enums
    #------------------------------------------------------------------------
    OGRAxisOrientation = enum :OAO_Other, 0,
      :OAO_North, 1,
      :OAO_South, 2,
      :OAO_East, 3,
      :OAO_West, 4,
      :OAO_Up, 5,
      :OAO_Down, 6

    OGRDatumType = enum :ODT_HD_Min, 1000,
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
      :ODT_LD_Min, 10000,
      :ODT_LD_Max, 32767

    #------------------------------------------------------------------------
    # Typedefs
    #------------------------------------------------------------------------
    typedef :pointer, :OGRSpatialReferenceH
    typedef :pointer, :OGRCoordinateTransformationH

    #------------------------------------------------------------------------
    # Functions
    #------------------------------------------------------------------------
    #~~~~~~~~~~~~~~
    # AxisOrientations
    #~~~~~~~~~~~~~~
    attach_function :OSRAxisEnumToName, [OGRAxisOrientation], :string

    #~~~~~~~~~~~~~~
    # SpatialReference
    #~~~~~~~~~~~~~~
    attach_function :OSRNewSpatialReference, %i[string], :OGRSpatialReferenceH
    attach_function :OSRCloneGeogCS, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
    attach_function :OSRClone, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
    attach_function :OSRDestroySpatialReference, %i[OGRSpatialReferenceH], :void
    attach_function :OSRReference, %i[OGRSpatialReferenceH], :int
    attach_function :OSRDereference, %i[OGRSpatialReferenceH], :int
    attach_function :OSRRelease, %i[OGRSpatialReferenceH], :void

    attach_function :OSRValidate, %i[OGRSpatialReferenceH], OGRErr
    attach_function :OSRFixupOrdering, %i[OGRSpatialReferenceH], OGRErr
    attach_function :OSRFixup, %i[OGRSpatialReferenceH], OGRErr
    attach_function :OSRStripCTParms, %i[OGRSpatialReferenceH], OGRErr

    attach_function :OSRImportFromEPSG, %i[OGRSpatialReferenceH int], OGRErr
    attach_function :OSRImportFromEPSGA, %i[OGRSpatialReferenceH int], OGRErr
    attach_function :OSRImportFromWkt, %i[OGRSpatialReferenceH pointer], OGRErr
    attach_function :OSRImportFromProj4, %i[OGRSpatialReferenceH string], OGRErr
    attach_function :OSRImportFromESRI, %i[OGRSpatialReferenceH pointer], OGRErr
    attach_function :OSRImportFromPCI,
      %i[OGRSpatialReferenceH string string pointer],
      OGRErr
    attach_function :OSRImportFromUSGS,
      %i[OGRSpatialReferenceH long long pointer long],
      OGRErr
    attach_function :OSRImportFromXML, %i[OGRSpatialReferenceH string], OGRErr
    attach_function :OSRImportFromMICoordSys, %i[OGRSpatialReferenceH string], OGRErr
    attach_function :OSRImportFromERM,
      %i[OGRSpatialReferenceH string string string],
      OGRErr
    attach_function :OSRImportFromUrl, %i[OGRSpatialReferenceH string], OGRErr

    attach_function :OSRExportToWkt, %i[OGRSpatialReferenceH pointer], OGRErr
    attach_function :OSRExportToPrettyWkt, %i[OGRSpatialReferenceH pointer bool], OGRErr
    attach_function :OSRExportToProj4, %i[OGRSpatialReferenceH pointer], OGRErr
    attach_function :OSRExportToPCI,
      %i[OGRSpatialReferenceH pointer pointer pointer],
      OGRErr
    attach_function :OSRExportToUSGS,
      %i[OGRSpatialReferenceH pointer pointer pointer pointer],
      OGRErr
    attach_function :OSRExportToXML, %i[OGRSpatialReferenceH pointer buffer_out], OGRErr
    attach_function :OSRExportToMICoordSys, %i[OGRSpatialReferenceH pointer], OGRErr
    attach_function :OSRExportToERM,
      %i[OGRSpatialReferenceH buffer_out buffer_out buffer_out],
      OGRErr
    attach_function :OSRMorphToESRI, %i[OGRSpatialReferenceH], OGRErr
    attach_function :OSRMorphFromESRI, %i[OGRSpatialReferenceH], OGRErr

    attach_function :OSRSetAttrValue, %i[OGRSpatialReferenceH string string], OGRErr
    attach_function :OSRGetAttrValue, %i[OGRSpatialReferenceH string int], :string
    attach_function :OSRSetAngularUnits, %i[OGRSpatialReferenceH string double], OGRErr
    attach_function :OSRGetAngularUnits, %i[OGRSpatialReferenceH pointer], :double
    attach_function :OSRSetLinearUnits, %i[OGRSpatialReferenceH string double], OGRErr
    attach_function :OSRGetLinearUnits, %i[OGRSpatialReferenceH pointer], :double
    attach_function :OSRSetTargetLinearUnits, %i[OGRSpatialReferenceH string string double], OGRErr
    attach_function :OSRGetTargetLinearUnits, %i[OGRSpatialReferenceH string pointer], :double
    attach_function :OSRGetPrimeMeridian, %i[OGRSpatialReferenceH pointer], :double
    attach_function :OSRSetLinearUnitsAndUpdateParameters,
      %i[OGRSpatialReferenceH string double],
      OGRErr
    attach_function :OSRGetSemiMajor, %i[OGRSpatialReferenceH pointer], :double
    attach_function :OSRGetSemiMinor, %i[OGRSpatialReferenceH pointer], :double
    attach_function :OSRGetInvFlattening, %i[OGRSpatialReferenceH pointer], :double
    attach_function :OSRSetAuthority,
      %i[OGRSpatialReferenceH string string int],
      OGRErr
    attach_function :OSRGetAuthorityCode, %i[OGRSpatialReferenceH string], :string
    attach_function :OSRGetAuthorityName, %i[OGRSpatialReferenceH string], :string
    attach_function :OSRSetProjection, %i[OGRSpatialReferenceH string], OGRErr
    attach_function :OSRSetProjParm, %i[OGRSpatialReferenceH string double], OGRErr
    attach_function :OSRGetProjParm,
      %i[OGRSpatialReferenceH string double pointer],
      :double
    attach_function :OSRSetNormProjParm, %i[OGRSpatialReferenceH string double], OGRErr
    attach_function :OSRGetNormProjParm,
      %i[OGRSpatialReferenceH string double pointer],
      :double
    attach_function :OSRSetUTM, %i[OGRSpatialReferenceH int int], OGRErr
    attach_function :OSRGetUTMZone, %i[OGRSpatialReferenceH pointer], :int
    attach_function :OSRSetStatePlane, %i[OGRSpatialReferenceH int int], OGRErr
    attach_function :OSRSetStatePlaneWithUnits,
      %i[OGRSpatialReferenceH int int string double],
      OGRErr
    attach_function :OSRAutoIdentifyEPSG, %i[OGRSpatialReferenceH], OGRErr
    attach_function :OSREPSGTreatsAsLatLong, %i[OGRSpatialReferenceH], :bool
    attach_function :OSREPSGTreatsAsNorthingEasting, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRGetAxis,
      [:OGRSpatialReferenceH, :string, :int, :pointer],
      :string

    attach_function :OSRSetACEA,
      %i[OGRSpatialReferenceH double double double double double double],
      OGRErr
    attach_function :OSRSetAE,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetBonne,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetCEA,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetCS,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetEC,
      %i[OGRSpatialReferenceH double double double double double double],
      OGRErr
    attach_function :OSRSetEckert,
      %i[OGRSpatialReferenceH int double double double],
      OGRErr
    attach_function :OSRSetEckertIV,
      %i[OGRSpatialReferenceH double double double],
      OGRErr
    attach_function :OSRSetEckertVI,
      %i[OGRSpatialReferenceH double double double],
      OGRErr
    attach_function :OSRSetEquirectangular,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetEquirectangular2,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetGS,
      %i[OGRSpatialReferenceH double double double],
      OGRErr
    attach_function :OSRSetGH,
      %i[OGRSpatialReferenceH double double double],
      OGRErr
    attach_function :OSRSetIGH,
      %i[OGRSpatialReferenceH],
      OGRErr
    attach_function :OSRSetGEOS,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetGaussSchreiberTMercator,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetGnomonic,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetOM,
      %i[OGRSpatialReferenceH double double double double double double double],
      OGRErr
      OGRErr
    attach_function :OSRSetHOM,
      %i[OGRSpatialReferenceH double double double double double double double],
      OGRErr
    attach_function :OSRSetHOM2PNO,
      %i[OGRSpatialReferenceH double double double double double double double double],
      OGRErr
    attach_function :OSRSetIWMPolyconic,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetKrovak,
      %i[OGRSpatialReferenceH double double double double double double double],
      OGRErr
    attach_function :OSRSetLAEA,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetLCC,
      %i[OGRSpatialReferenceH double double double double double double],
      OGRErr
    attach_function :OSRSetLCC1SP,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetLCCB,
      %i[OGRSpatialReferenceH double double double double double double],
      OGRErr
    attach_function :OSRSetMC,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetMercator,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetMollweide,
      %i[OGRSpatialReferenceH double double double],
      OGRErr
    attach_function :OSRSetNZMG,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetOS,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetOrthographic,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetPolyconic,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetPS,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetRobinson,
      %i[OGRSpatialReferenceH double double double],
      OGRErr
    attach_function :OSRSetSinusoidal,
      %i[OGRSpatialReferenceH double double double],
      OGRErr
    attach_function :OSRSetStereographic,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetSOC,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetTM,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetTMVariant,
      %i[OGRSpatialReferenceH string double double double double double],
      OGRErr
    attach_function :OSRSetTMG,
      %i[OGRSpatialReferenceH double double double double],
      OGRErr
    attach_function :OSRSetTMSO,
      %i[OGRSpatialReferenceH double double double double double],
      OGRErr
    attach_function :OSRSetVDG,
      %i[OGRSpatialReferenceH double double double],
      OGRErr
    attach_function :OSRSetWagner,
      %i[OGRSpatialReferenceH int double double],
      OGRErr

    attach_function :OSRIsGeographic, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsLocal, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsProjected, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsCompound, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsGeocentric, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsVertical, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsSameGeogCS, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool
    attach_function :OSRIsSameVertCS, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool
    attach_function :OSRIsSame, %i[OGRSpatialReferenceH OGRSpatialReferenceH], :bool

    attach_function :OSRSetLocalCS, %i[OGRSpatialReferenceH string], OGRErr
    attach_function :OSRSetProjCS, %i[OGRSpatialReferenceH string], OGRErr
    attach_function :OSRSetGeocCS, %i[OGRSpatialReferenceH string], OGRErr
    attach_function :OSRSetWellKnownGeocCS, %i[OGRSpatialReferenceH string], OGRErr
    attach_function :OSRSetFromUserInput, %i[OGRSpatialReferenceH string], OGRErr
    attach_function :OSRCopyGeogCSFrom, %i[OGRSpatialReferenceH OGRSpatialReferenceH], OGRErr
    attach_function :OSRSetTOWGS84,
      %i[OGRSpatialReferenceH double double double double double double double],
      OGRErr
    attach_function :OSRGetTOWGS84, %i[OGRSpatialReferenceH pointer int], OGRErr
    attach_function :OSRSetCompoundCS,
      %i[OGRSpatialReferenceH string OGRSpatialReferenceH OGRSpatialReferenceH],
      OGRErr

    attach_function :OSRCleanup, [], :void

    #~~~~~~~~~~~~~~
    # CoordinateTransformations
    #~~~~~~~~~~~~~~
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
    attach_function :OCTProj4Normalize, %i[string], :string

    #~~~~~~~~~~~~~~
    # Parameters
    #~~~~~~~~~~~~~~
    attach_function :OPTGetProjectionMethods, %i[], :pointer
    attach_function :OPTGetParameterList, %i[string pointer], :pointer
    attach_function :OPTGetParameterInfo,
      %i[string string pointer pointer pointer],
      :int
  end
end
