# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRGeomFieldDefnH

      attach_function :OGR_GFld_Create,
                      [:string, FFI::OGR::Core::WKBGeometryType],
                      :OGRGeomFieldDefnH
      attach_function :OGR_GFld_Destroy, %i[OGRGeomFieldDefnH], :void
      attach_function :OGR_GFld_SetName, %i[OGRGeomFieldDefnH string], :void
      attach_function :OGR_GFld_GetNameRef, %i[OGRGeomFieldDefnH], :string
      attach_function :OGR_GFld_GetType, %i[OGRGeomFieldDefnH], FFI::OGR::Core::WKBGeometryType
      attach_function :OGR_GFld_SetType,
                      [:OGRGeomFieldDefnH, FFI::OGR::Core::WKBGeometryType],
                      :void
      attach_function :OGR_GFld_GetSpatialRef,
                      %i[OGRGeomFieldDefnH],
                      FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)
      attach_function :OGR_GFld_SetSpatialRef,
                      [:OGRGeomFieldDefnH, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)],
                      :void
      attach_function :OGR_GFld_IsIgnored, %i[OGRGeomFieldDefnH], :bool
      attach_function :OGR_GFld_SetIgnored, %i[OGRGeomFieldDefnH bool], :void
    end
  end
end
