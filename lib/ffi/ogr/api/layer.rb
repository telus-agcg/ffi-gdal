# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRLayerH

      # ~~~~~~~~~~~~~~~~
      # Layer-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_L_GetName, %i[OGRLayerH], :string
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
      attach_function :OGR_L_GetFeatureCount, %i[OGRLayerH bool], :int64

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
    end
  end
end
