# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module SRSAPI
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRSpatialReferenceH

      attach_function :OSRNewSpatialReference, %i[pointer], :OGRSpatialReferenceH
      attach_function :OSRCloneGeogCS, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
      attach_function :OSRClone, %i[OGRSpatialReferenceH], :OGRSpatialReferenceH
      attach_function :OSRDestroySpatialReference, %i[OGRSpatialReferenceH], :void
      attach_function :OSRRelease, %i[OGRSpatialReferenceH], :void

      attach_function :OSRValidate, %i[OGRSpatialReferenceH], FFI::OGR::Core::Err

      attach_function :OSRImportFromEPSG, %i[OGRSpatialReferenceH int], FFI::OGR::Core::Err
      attach_function :OSRImportFromEPSGA, %i[OGRSpatialReferenceH int], FFI::OGR::Core::Err
      attach_function :OSRImportFromWkt, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRImportFromProj4, %i[OGRSpatialReferenceH string], FFI::OGR::Core::Err
      attach_function :OSRImportFromESRI, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
      attach_function :OSRImportFromOzi, %i[OGRSpatialReferenceH pointer], FFI::OGR::Core::Err
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
      attach_function :OSRExportToPanorama,
                      %i[OGRSpatialReferenceH pointer pointer pointer pointer pointer],
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
      attach_function :OSRGetAuthorityCode, %i[OGRSpatialReferenceH string], :string
      attach_function :OSRGetAuthorityName, %i[OGRSpatialReferenceH string], :string
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
                         string string string double double
                         string double string double],
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
    end
  end
end
