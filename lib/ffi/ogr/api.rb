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
require_relative 'api/layer'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      # -----------------------------------------------------------------------
      # Typedefs
      # -----------------------------------------------------------------------
      # TODO: Use the typedefs for creating pointers throughout the app.
      typedef :pointer, :OGRDataSourceH
      typedef :pointer, :OGRSFDriverH

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
