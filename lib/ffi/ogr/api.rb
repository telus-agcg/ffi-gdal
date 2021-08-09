# frozen_string_literal: true

require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'
require_relative 'api/field_definition'
require_relative 'api/geometry'
require_relative 'api/geometry_field_definition'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      # -----------------------------------------------------------------------
      # Typedefs
      # -----------------------------------------------------------------------
      # TODO: Use the typedefs for creating pointers throughout the app.
      typedef :pointer, :OGRFeatureDefnH
      typedef :pointer, :OGRFeatureH
      typedef :pointer, :OGRStyleTableH
      typedef :pointer, :OGRLayerH
      typedef :pointer, :OGRDataSourceH
      typedef :pointer, :OGRSFDriverH
      typedef :pointer, :OGRStyleMgrH
      typedef :pointer, :OGRStyleToolH

      # wrap
      attach_function :OGR_GetFieldTypeName, [FFI::OGR::Core::FieldType], :strptr

      # ~~~~~~~~~~~~~~~~
      # Feature Definition-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_FD_Create, %i[string], :OGRFeatureDefnH
      # TODO: wrap
      attach_function :OGR_FD_Destroy, %i[OGRFeatureDefnH], :void
      attach_function :OGR_FD_Release, %i[OGRFeatureDefnH], :void
      attach_function :OGR_FD_GetName, %i[OGRFeatureDefnH], :strptr
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

      # ~~~~~~~~~~~~~~~~
      # Feature-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_F_Create, %i[OGRFeatureDefnH], :OGRFeatureH
      attach_function :OGR_F_Destroy, %i[OGRFeatureH], :void
      attach_function :OGR_F_GetDefnRef, %i[OGRFeatureH], :OGRFeatureDefnH
      attach_function :OGR_F_SetGeometryDirectly,
                      %i[OGRFeatureH OGRGeometryH],
                      FFI::OGR::Core::Err
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
      attach_function :OGR_F_SetGeomFieldDirectly, %i[OGRFeatureH int OGRGeometryH], FFI::OGR::Core::Err
      attach_function :OGR_F_SetGeomField, %i[OGRFeatureH int OGRGeometryH], FFI::OGR::Core::Err

      attach_function :OGR_F_GetFID, %i[OGRFeatureH], :long
      attach_function :OGR_F_SetFID, %i[OGRFeatureH long], FFI::OGR::Core::Err
      attach_function :OGR_F_DumpReadable, %i[OGRFeatureH pointer], :void
      attach_function :OGR_F_SetFrom, %i[OGRFeatureH OGRFeatureH int], FFI::OGR::Core::Err
      attach_function :OGR_F_SetFromWithMap, %i[OGRFeatureH OGRFeatureH int pointer], FFI::OGR::Core::Err

      attach_function :OGR_F_GetStyleString, %i[OGRFeatureH], :strptr
      attach_function :OGR_F_SetStyleString, %i[OGRFeatureH string], :void
      # TODO: wrap
      attach_function :OGR_F_SetStyleStringDirectly, %i[OGRFeatureH string], :void
      attach_function :OGR_F_GetStyleTable, %i[OGRFeatureH], :OGRStyleTableH
      attach_function :OGR_F_SetStyleTableDirectly, %i[OGRFeatureH OGRStyleTableH], :void
      attach_function :OGR_F_SetStyleTable, %i[OGRFeatureH OGRStyleTableH], :void

      # ~~~~~~~~~~~~~~~~
      # Layer-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_L_GetName, %i[OGRLayerH], :strptr
      attach_function :OGR_L_GetGeomType, %i[OGRLayerH], FFI::OGR::Core::WKBGeometryType
      attach_function :OGR_L_GetSpatialFilter, %i[OGRLayerH], :OGRGeometryH
      attach_function :OGR_L_SetSpatialFilter, %i[OGRLayerH OGRGeometryH], :void
      attach_function :OGR_L_SetSpatialFilterRect,
                      %i[OGRLayerH double double double double],
                      :void
      attach_function :OGR_L_SetSpatialFilterEx, %i[OGRLayerH int OGRGeometryH], :void
      attach_function :OGR_L_SetSpatialFilterRectEx,
                      %i[OGRLayerH int double double double double],
                      :void
      attach_function :OGR_L_SetAttributeFilter, %i[OGRLayerH string], FFI::OGR::Core::Err
      attach_function :OGR_L_ResetReading, %i[OGRLayerH], :void

      attach_function :OGR_L_GetNextFeature, %i[OGRLayerH], :OGRFeatureH
      attach_function :OGR_L_SetNextByIndex, %i[OGRLayerH long], FFI::OGR::Core::Err
      attach_function :OGR_L_GetFeature, %i[OGRLayerH long], :OGRFeatureH
      attach_function :OGR_L_SetFeature, %i[OGRLayerH OGRFeatureH], FFI::OGR::Core::Err
      attach_function :OGR_L_CreateFeature, %i[OGRLayerH OGRFeatureH], FFI::OGR::Core::Err
      attach_function :OGR_L_DeleteFeature, %i[OGRLayerH long], FFI::OGR::Core::Err
      attach_function :OGR_L_GetLayerDefn, %i[OGRLayerH], :OGRFeatureDefnH
      attach_function :OGR_L_GetSpatialRef, %i[OGRLayerH], FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)
      attach_function :OGR_L_FindFieldIndex, %i[OGRLayerH string bool], :int
      attach_function :OGR_L_GetFeatureCount, %i[OGRLayerH bool], :int

      attach_function :OGR_L_GetExtent, [:OGRLayerH, FFI::OGR::Envelope.ptr, :bool], FFI::OGR::Core::Err
      attach_function :OGR_L_GetExtentEx,
                      [:OGRLayerH, :int, FFI::OGR::Envelope.ptr, :bool],
                      FFI::OGR::Core::Err
      attach_function :OGR_L_TestCapability, %i[OGRLayerH string], :bool
      attach_function :OGR_L_CreateField, %i[OGRLayerH OGRFieldDefnH bool], FFI::OGR::Core::Err
      attach_function :OGR_L_CreateGeomField,
                      %i[OGRLayerH OGRGeomFieldDefnH bool],
                      FFI::OGR::Core::Err
      attach_function :OGR_L_DeleteField, %i[OGRLayerH int], FFI::OGR::Core::Err
      attach_function :OGR_L_ReorderFields, %i[OGRLayerH pointer], FFI::OGR::Core::Err
      attach_function :OGR_L_ReorderField, %i[OGRLayerH int int], FFI::OGR::Core::Err
      attach_function :OGR_L_AlterFieldDefn, %i[OGRLayerH int OGRFieldDefnH int], FFI::OGR::Core::Err

      attach_function :OGR_L_StartTransaction, %i[OGRLayerH], FFI::OGR::Core::Err
      attach_function :OGR_L_CommitTransaction, %i[OGRLayerH], FFI::OGR::Core::Err
      attach_function :OGR_L_RollbackTransaction, %i[OGRLayerH], FFI::OGR::Core::Err

      attach_function :OGR_L_SyncToDisk, %i[OGRLayerH], FFI::OGR::Core::Err

      attach_function :OGR_L_GetFeaturesRead, %i[OGRLayerH], CPL::Port.find_type(:GIntBig)
      attach_function :OGR_L_GetFIDColumn, %i[OGRLayerH], :strptr
      attach_function :OGR_L_GetGeometryColumn, %i[OGRLayerH], :strptr
      attach_function :OGR_L_GetStyleTable, %i[OGRLayerH], :OGRStyleTableH
      # TODO: wrap
      attach_function :OGR_L_SetStyleTableDirectly, %i[OGRLayerH OGRStyleTableH], :void
      attach_function :OGR_L_SetStyleTable, %i[OGRLayerH OGRStyleTableH], :void
      attach_function :OGR_L_SetIgnoredFields, %i[OGRLayerH pointer], FFI::OGR::Core::Err

      attach_function :OGR_L_Intersection,
                      [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                       :pointer],
                      FFI::OGR::Core::Err
      attach_function :OGR_L_Union,
                      [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                       :pointer],
                      FFI::OGR::Core::Err
      attach_function :OGR_L_SymDifference,
                      [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                       :pointer],
                      FFI::OGR::Core::Err
      attach_function :OGR_L_Identity,
                      [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                       :pointer],
                      FFI::OGR::Core::Err
      attach_function :OGR_L_Update,
                      [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                       :pointer],
                      FFI::OGR::Core::Err
      attach_function :OGR_L_Clip,
                      [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                       :pointer],
                      FFI::OGR::Core::Err
      attach_function :OGR_L_Erase,
                      [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc),
                       :pointer],
                      FFI::OGR::Core::Err

      # ~~~~~~~~~~~~~~~~
      # DataSource-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_DS_Destroy, %i[OGRDataSourceH], :void
      attach_function :OGR_DS_GetName, %i[OGRDataSourceH], :pointer
      attach_function :OGR_DS_GetLayerCount, %i[OGRDataSourceH], :int
      attach_function :OGR_DS_GetLayer, %i[OGRDataSourceH int], :OGRLayerH
      attach_function :OGR_DS_GetLayerByName, %i[OGRDataSourceH string], :OGRLayerH
      attach_function :OGR_DS_DeleteLayer, %i[OGRDataSourceH int], FFI::OGR::Core::Err
      attach_function :OGR_DS_GetDriver, %i[OGRDataSourceH], :OGRSFDriverH
      attach_function :OGR_DS_CreateLayer,
                      [
                        :OGRDataSourceH,
                        :string,
                        FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH),
                        FFI::OGR::Core::WKBGeometryType, :pointer
                      ],
                      :OGRLayerH
      attach_function :OGR_DS_CopyLayer,
                      %i[OGRDataSourceH OGRLayerH string pointer],
                      :OGRLayerH
      attach_function :OGR_DS_TestCapability, %i[OGRDataSourceH string], :bool
      attach_function :OGR_DS_ExecuteSQL,
                      %i[OGRDataSourceH string OGRGeometryH string],
                      :OGRLayerH
      attach_function :OGR_DS_ReleaseResultSet, %i[OGRDataSourceH OGRLayerH], :void

      attach_function :OGR_DS_SyncToDisk, %i[OGRDataSourceH], FFI::OGR::Core::Err
      attach_function :OGR_DS_GetStyleTable, %i[OGRDataSourceH], :OGRStyleTableH
      # TODO: wrap
      attach_function :OGR_DS_SetStyleTableDirectly,
                      %i[OGRDataSourceH OGRStyleTableH],
                      :void
      attach_function :OGR_DS_SetStyleTable, %i[OGRDataSourceH OGRStyleTableH], :void

      # ~~~~~~~~~~~~~~~~
      # Driver-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_Dr_GetName, %i[OGRSFDriverH], :strptr
      attach_function :OGR_Dr_Open, %i[OGRSFDriverH string bool], :OGRDataSourceH
      attach_function :OGR_Dr_TestCapability, %i[OGRSFDriverH string], :bool
      attach_function :OGR_Dr_CreateDataSource, %i[OGRSFDriverH string pointer], :OGRDataSourceH
      attach_function :OGR_Dr_CopyDataSource,
                      %i[OGRSFDriverH OGRDataSourceH string pointer],
                      :OGRDataSourceH
      attach_function :OGR_Dr_DeleteDataSource, %i[OGRSFDriverH string], FFI::OGR::Core::Err

      # ~~~~~~~~~~~~~~~~
      # Style Manager-related
      # ~~~~~~~~~~~~~~~~
      # TODO: wrap
      attach_function :OGR_SM_Create, %i[OGRStyleTableH], :OGRStyleMgrH
      attach_function :OGR_SM_Destroy, %i[OGRStyleTableH], :void
      attach_function :OGR_SM_InitFromFeature, %i[OGRStyleTableH OGRFeatureH], :strptr
      attach_function :OGR_SM_InitStyleString, %i[OGRStyleTableH string], :int
      attach_function :OGR_SM_GetPartCount, %i[OGRStyleTableH string], :int
      attach_function :OGR_SM_GetPart,
                      %i[OGRStyleTableH int string],
                      :OGRStyleToolH
      attach_function :OGR_SM_AddPart, %i[OGRStyleTableH OGRStyleToolH], :int
      attach_function :OGR_SM_AddStyle, %i[OGRStyleTableH string string], :int

      # ~~~~~~~~~~~~~~~~
      # Style Tool-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_ST_Create, [FFI::OGR::Core::STClassId], :OGRStyleToolH
      attach_function :OGR_ST_Destroy, %i[OGRStyleToolH], :void
      attach_function :OGR_ST_GetType, %i[OGRStyleToolH], FFI::OGR::Core::STClassId
      attach_function :OGR_ST_GetUnit, %i[OGRStyleToolH], FFI::OGR::Core::STUnitId
      attach_function :OGR_ST_SetUnit, [:OGRStyleToolH, FFI::OGR::Core::STUnitId, :double], :void
      attach_function :OGR_ST_GetParamStr, %i[OGRStyleToolH int pointer], :strptr
      attach_function :OGR_ST_GetParamNum, %i[OGRStyleToolH int pointer], :int
      attach_function :OGR_ST_GetParamDbl, %i[OGRStyleToolH int pointer], :double
      attach_function :OGR_ST_SetParamStr, %i[OGRStyleToolH int string], :void
      attach_function :OGR_ST_SetParamNum, %i[OGRStyleToolH int int], :void
      attach_function :OGR_ST_SetParamDbl, %i[OGRStyleToolH int double], :void
      attach_function :OGR_ST_GetStyleString, %i[OGRStyleToolH], :strptr
      attach_function :OGR_ST_GetRGBFromString,
                      %i[OGRStyleToolH string pointer pointer pointer pointer],
                      :bool

      # ~~~~~~~~~~~~~~~~
      # Style Table-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_STBL_Create, [], :OGRStyleTableH
      attach_function :OGR_STBL_Destroy, %i[OGRStyleTableH], :void
      attach_function :OGR_STBL_AddStyle, %i[OGRStyleTableH string string], :bool
      attach_function :OGR_STBL_SaveStyleTable, %i[OGRStyleTableH string], :bool
      attach_function :OGR_STBL_LoadStyleTable, %i[OGRStyleTableH string], :bool
      attach_function :OGR_STBL_Find, %i[OGRStyleTableH string], :string
      attach_function :OGR_STBL_ResetStyleStringReading, %i[OGRStyleTableH], :void
      attach_function :OGR_STBL_GetNextStyle, %i[OGRStyleTableH], :string
      attach_function :OGR_STBL_GetLastStyleName, %i[OGRStyleTableH], :string

      # ~~~~~~~~~~~~~~~~
      # Main functions
      # ~~~~~~~~~~~~~~~~
      attach_function :OGROpen, %i[string bool OGRSFDriverH], :OGRDataSourceH
      attach_function :OGRGetDriverCount, [], :int
      attach_function :OGRGetDriver, %i[int], :OGRSFDriverH
      attach_function :OGRGetDriverByName, %i[string], :OGRSFDriverH

      attach_function :OGRRegisterAll, [], :void
      # TODO: wrap
      attach_function :OGRCleanupAll, [], :void
    end
  end
end
