module FFI
  module GDAL

    #------------------------------------------------------------------------
    # Enums
    #------------------------------------------------------------------------
    OGRAxisOrientation = enum :oao_other, 0,
      :oao_north, 1,
      :oao_south, 2,
      :oao_east, 3,
      :oao_west, 4,
      :oao_up, 5,
      :oao_down, 6

    OGRDatumType = enum :odt_hd_min, 1000,
      :odt_hd_other, 1000,
      :odt_hd_classic, 1001,
      :odt_hd_geocentric, 1002,
      :odt_hd_max, 1999,
      :odt_vd_min, 2000,
      :odt_vd_other, 2000,
      :odt_vd_orthometric, 2001,
      :odt_vd_ellipsoidal, 2002,
      :odt_vd_altitude_barometric, 2003,
      :odt_vd_normal, 2004,
      :odt_vd_geoid_model_derived, 2005,
      :odt_vd_depth, 2006,
      :odt_vd_max, 2999,
      :odt_ld_min, 10000,
      :odt_ld_max, 32767

    #------------------------------------------------------------------------
    # Functions
    #------------------------------------------------------------------------
    attach_function :OSRAxisEnumToName, [OGRAxisOrientation], :string
    attach_function :OSRNewSpatialReference, [:string], :OGRSpatialReferenceH
    attach_function :OSRValidate, %i[OGRSpatialReferenceH], :OGRErr
    attach_function :OSRFixupOrdering, %i[OGRSpatialReferenceH], :OGRErr
    attach_function :OSRFixup, %i[OGRSpatialReferenceH], :OGRErr
    attach_function :OSRStripCTParms, %i[OGRSpatialReferenceH], :OGRErr
    attach_function :OSRImportFromEPSG, %i[OGRSpatialReferenceH int], :OGRErr
    attach_function :OSRImportFromEPSGA, %i[OGRSpatialReferenceH int], :OGRErr
    attach_function :OSRImportFromWkt, %i[OGRSpatialReferenceH pointer], :OGRErr
    attach_function :OSRImportFromProj4, %i[OGRSpatialReferenceH string], :OGRErr
    attach_function :OSRImportFromESRI, %i[OGRSpatialReferenceH pointer], :OGRErr
    attach_function :OSRImportFromPCI,
      %i[OGRSpatialReferenceH string string pointer],
      :OGRErr
    attach_function :OSRImportFromUSGS,
      %i[OGRSpatialReferenceH long long pointer long],
      :OGRErr
    attach_function :OSRImportFromXML, %i[OGRSpatialReferenceH string], :OGRErr
    attach_function :OSRImportFromMICoordSys, %i[OGRSpatialReferenceH string], :OGRErr
    attach_function :OSRImportFromERM,
      %i[OGRSpatialReferenceH string string string],
      :OGRErr
    attach_function :OSRImportFromUrl, %i[OGRSpatialReferenceH string], :OGRErr

    attach_function :OSRExportToWkt, %i[OGRSpatialReferenceH pointer], :OGRErr
    attach_function :OSRExportToPrettyWkt, %i[OGRSpatialReferenceH pointer int], :OGRErr
    attach_function :OSRExportToProj4, %i[OGRSpatialReferenceH pointer], :OGRErr
    attach_function :OSRExportToPCI,
      %i[OGRSpatialReferenceH pointer pointer pointer],
      :OGRErr
    attach_function :OSRExportToUSGS,
      %i[OGRSpatialReferenceH pointer pointer pointer pointer],
      :OGRErr
    attach_function :OSRExportToXML, %i[OGRSpatialReferenceH pointer string], :OGRErr
    attach_function :OSRExportToMICoordSys, %i[OGRSpatialReferenceH pointer], :OGRErr
    attach_function :OSRExportToERM,
      %i[OGRSpatialReferenceH string string string],
      :OGRErr
    attach_function :OSRMorphToESRI,
      %i[OGRSpatialReferenceH],
      :OGRErr

    attach_function :OSRIsGeographic, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsLocal, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsProjected, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsCompound, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsGeocentric, %i[OGRSpatialReferenceH], :bool
    attach_function :OSRIsVertical, %i[OGRSpatialReferenceH], :bool

    attach_function :OPTGetProjectionMethods, [:void], :pointer
    attach_function :OPTGetParameterList, [:string, :pointer], :pointer
    attach_function :OPTGetParameterInfo,
      [:string, :string, :pointer, :pointer, :pointer],
      :int
  end
end
