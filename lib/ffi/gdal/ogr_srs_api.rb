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
    #attach_function :OSRNewSpacialReference, [:string], :OGRSpatialReferenceH
    #
    attach_function :OPTGetProjectionMethods, [:void], :pointer
    attach_function :OPTGetParameterList, [:string, :pointer], :pointer
    attach_function :OPTGetParameterInfo,
      [:string, :string, :pointer, :pointer, :pointer],
      :int
  end
end
