# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRFeatureDefnH

      # ~~~~~~~~~~~~~~~~
      # Feature Definition-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_FD_Create, %i[string], :OGRFeatureDefnH
      # TODO: wrap
      attach_function :OGR_FD_Destroy, %i[OGRFeatureDefnH], :void
      attach_function :OGR_FD_Release, %i[OGRFeatureDefnH], :void
      attach_function :OGR_FD_GetName, %i[OGRFeatureDefnH], :string
      attach_function :OGR_FD_GetFieldCount, %i[OGRFeatureDefnH], :int
      attach_function :OGR_FD_GetFieldDefn, %i[OGRFeatureDefnH int], :OGRFieldDefnH
      attach_function :OGR_FD_GetFieldIndex, %i[OGRFeatureDefnH string], :int
      attach_function :OGR_FD_AddFieldDefn,
                      %i[OGRFeatureDefnH OGRFieldDefnH],
                      :void
      attach_function :OGR_FD_DeleteFieldDefn,
                      %i[OGRFeatureDefnH int],
                      FFI::OGR::Core::Err
      attach_function :OGR_FD_GetGeomType, %i[OGRFeatureDefnH], FFI::OGR::Core::WKBGeometryType
      attach_function :OGR_FD_SetGeomType,
                      [:OGRFeatureDefnH, FFI::OGR::Core::WKBGeometryType],
                      :void
      attach_function :OGR_FD_IsGeometryIgnored, %i[OGRFeatureDefnH], :bool
      attach_function :OGR_FD_SetGeometryIgnored, %i[OGRFeatureDefnH bool], :void
      attach_function :OGR_FD_IsStyleIgnored, %i[OGRFeatureDefnH], :bool
      attach_function :OGR_FD_SetStyleIgnored, %i[OGRFeatureDefnH bool], :void
      attach_function :OGR_FD_GetGeomFieldCount, %i[OGRFeatureDefnH], :int
      attach_function :OGR_FD_GetGeomFieldDefn,
                      %i[OGRFeatureDefnH int],
                      :OGRGeomFieldDefnH
      attach_function :OGR_FD_GetGeomFieldIndex,
                      %i[OGRFeatureDefnH string],
                      :int
      attach_function :OGR_FD_AddGeomFieldDefn,
                      %i[OGRFeatureDefnH OGRGeomFieldDefnH],
                      :void
      attach_function :OGR_FD_DeleteGeomFieldDefn,
                      %i[OGRFeatureDefnH int],
                      FFI::OGR::Core::Err

      attach_function :OGR_FD_IsSame,
                      %i[OGRFeatureDefnH OGRFeatureDefnH],
                      :bool
    end
  end
end
