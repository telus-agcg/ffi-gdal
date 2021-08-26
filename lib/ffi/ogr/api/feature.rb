# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRFeatureH

      attach_function :OGR_F_Create, %i[OGRFeatureDefnH], :OGRFeatureH
      attach_function :OGR_F_Destroy, %i[OGRFeatureH], :void
      attach_function :OGR_F_GetDefnRef, %i[OGRFeatureH], :OGRFeatureDefnH
      attach_function :OGR_F_SetGeometry,
                      %i[OGRFeatureH OGRGeometryH],
                      FFI::OGR::Core::Err
      attach_function :OGR_F_GetGeometryRef, %i[OGRFeatureH], :OGRGeometryH
      attach_function :OGR_F_StealGeometry, %i[OGRFeatureH], :OGRGeometryH

      attach_function :OGR_F_Clone, %i[OGRFeatureH], :OGRFeatureH
      attach_function :OGR_F_Equal, %i[OGRFeatureH OGRFeatureH], :bool
      attach_function :OGR_F_GetFieldCount, %i[OGRFeatureH], :int
      attach_function :OGR_F_GetFieldDefnRef, %i[OGRFeatureH int], :OGRFieldDefnH
      attach_function :OGR_F_GetFieldIndex, %i[OGRFeatureH string], :int
      attach_function :OGR_F_IsFieldSet, %i[OGRFeatureH int], :bool
      attach_function :OGR_F_UnsetField, %i[OGRFeatureH int], :void

      attach_function :OGR_F_GetFieldAsInteger, %i[OGRFeatureH int], :int
      attach_function :OGR_F_GetFieldAsDouble, %i[OGRFeatureH int], :double
      attach_function :OGR_F_GetFieldAsString, %i[OGRFeatureH int], :strptr
      attach_function :OGR_F_GetFieldAsIntegerList, %i[OGRFeatureH int pointer], :pointer
      attach_function :OGR_F_GetFieldAsDoubleList, %i[OGRFeatureH int pointer], :pointer
      attach_function :OGR_F_GetFieldAsStringList, %i[OGRFeatureH int], :pointer
      attach_function :OGR_F_GetFieldAsBinary, %i[OGRFeatureH int pointer], :pointer
      attach_function :OGR_F_GetFieldAsDateTime,
                      %i[OGRFeatureH int pointer pointer pointer pointer pointer pointer pointer],
                      :int
      attach_function :OGR_F_SetFieldInteger, %i[OGRFeatureH int int], :void
      attach_function :OGR_F_SetFieldDouble, %i[OGRFeatureH int double], :void
      attach_function :OGR_F_SetFieldString, %i[OGRFeatureH int string], :void
      attach_function :OGR_F_SetFieldIntegerList, %i[OGRFeatureH int int pointer], :void
      attach_function :OGR_F_SetFieldDoubleList, %i[OGRFeatureH int int pointer], :void
      attach_function :OGR_F_SetFieldStringList, %i[OGRFeatureH int pointer], :void
      attach_function :OGR_F_SetFieldRaw, [:OGRFeatureH, :int, FFI::OGR::Field.ptr], :void
      attach_function :OGR_F_SetFieldBinary, %i[OGRFeatureH int int pointer], :void
      attach_function :OGR_F_SetFieldDateTime,
                      %i[OGRFeatureH int int int int int int int int],
                      :void

      attach_function :OGR_F_GetGeomFieldCount, %i[OGRFeatureH], :int
      attach_function :OGR_F_GetGeomFieldDefnRef, %i[OGRFeatureH int], :OGRGeomFieldDefnH
      attach_function :OGR_F_GetGeomFieldIndex, %i[OGRFeatureH string], :int
      attach_function :OGR_F_GetGeomFieldRef, %i[OGRFeatureH int], :OGRGeometryH
      attach_function :OGR_F_SetGeomField, %i[OGRFeatureH int OGRGeometryH], FFI::OGR::Core::Err

      attach_function :OGR_F_GetFID, %i[OGRFeatureH], :long
      attach_function :OGR_F_SetFID, %i[OGRFeatureH long], FFI::OGR::Core::Err
      attach_function :OGR_F_DumpReadable, %i[OGRFeatureH pointer], :void
      attach_function :OGR_F_SetFrom, %i[OGRFeatureH OGRFeatureH int], FFI::OGR::Core::Err
      attach_function :OGR_F_SetFromWithMap, %i[OGRFeatureH OGRFeatureH int pointer], FFI::OGR::Core::Err

      attach_function :OGR_F_GetStyleString, %i[OGRFeatureH], :string
      attach_function :OGR_F_SetStyleString, %i[OGRFeatureH string], :void
      attach_function :OGR_F_GetStyleTable, %i[OGRFeatureH], :OGRStyleTableH
      attach_function :OGR_F_SetStyleTable, %i[OGRFeatureH OGRStyleTableH], :void
    end
  end
end
