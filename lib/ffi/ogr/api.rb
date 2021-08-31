# frozen_string_literal: true

require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'
require_relative 'api/field_definition'
require_relative 'api/geometry'
require_relative 'api/geometry_field_definition'
require_relative 'api/feature_definition'
require_relative 'api/style_table'
require_relative 'api/feature'
require_relative 'api/style_tool'
require_relative 'api/style_manager'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      # -----------------------------------------------------------------------
      # Typedefs
      # -----------------------------------------------------------------------
      # TODO: Use the typedefs for creating pointers throughout the app.
      typedef :pointer, :OGRLayerH
      typedef :pointer, :OGRDataSourceH
      typedef :pointer, :OGRSFDriverH

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
