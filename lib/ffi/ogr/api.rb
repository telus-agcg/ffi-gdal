# frozen_string_literal: true

require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      # -----------------------------------------------------------------------
      # Typedefs
      # -----------------------------------------------------------------------
      # TODO: Use the typedefs for creating pointers throughout the app.
      typedef :pointer, :OGRGeometryH
      typedef :pointer, :OGRFieldDefnH
      typedef :pointer, :OGRFeatureDefnH
      typedef :pointer, :OGRFeatureH
      typedef :pointer, :OGRStyleTableH
      typedef :pointer, :OGRGeomFieldDefnH
      typedef :pointer, :OGRLayerH
      typedef :pointer, :OGRDataSourceH
      typedef :pointer, :OGRSFDriverH
      typedef :pointer, :OGRStyleMgrH
      typedef :pointer, :OGRStyleToolH

      # -----------------------------------------------------------------------
      # Functions
      # -----------------------------------------------------------------------
      # ~~~~~~~~~~~~~~~~
      # Geometry-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_G_ApproximateArcAngles,
                           [
                             :double, :double, :double,    # X, Y, Z
                             :double, :double, :double,    # primary radius, 2nd Axis, rotation
                             :double, :double, :double     # start angle, end angle, max angle step size
                           ],
                           :OGRGeometryH

      # Geometry constructors
      attach_gdal_function :OGRBuildPolygonFromEdges, %i[OGRGeometryH bool bool double pointer], :OGRGeometryH
      attach_gdal_function :OGR_G_CreateFromFgf,
                           [
                             :string,
                             FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH),
                             :pointer,
                             :int,
                             :pointer
                           ], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_CreateFromGML, %i[string], :OGRGeometryH
      attach_gdal_function :OGR_G_CreateFromGMLTree, [FFI::CPL::XMLNode.ptr], :OGRGeometryH
      attach_gdal_function :OGR_G_CreateFromWkb,
                           [:pointer, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH), :pointer, :int],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_CreateFromWkt,
                           [:pointer, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH), :pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_CreateGeometry, [FFI::OGR::Core::WKBGeometryType], :OGRGeometryH
      attach_gdal_function :OGR_G_CreateGeometryFromJson, %i[string], :OGRGeometryH
      attach_gdal_function :OGR_G_ImportFromWkb, %i[OGRGeometryH string int], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_ImportFromWkt, %i[OGRGeometryH pointer], FFI::OGR::Core.enum_type(:OGRErr)

      # Geometry exporters
      attach_gdal_function :OGR_G_ExportEnvelopeToGMLTree, %i[OGRGeometryH], FFI::CPL::XMLNode.ptr
      attach_gdal_function :OGR_G_ExportToGML, %i[OGRGeometryH], :strptr
      attach_gdal_function :OGR_G_ExportToGMLEx, %i[OGRGeometryH pointer], :strptr
      attach_gdal_function :OGR_G_ExportToGMLTree, %i[OGRGeometryH], FFI::CPL::XMLNode.ptr
      attach_gdal_function :OGR_G_ExportToIsoWkt, %i[OGRGeometryH pointer], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_ExportToJson, %i[OGRGeometryH], :strptr
      attach_gdal_function :OGR_G_ExportToJsonEx, %i[OGRGeometryH pointer], :strptr
      attach_gdal_function :OGR_G_ExportToKML, %i[OGRGeometryH string], :strptr
      attach_gdal_function :OGR_G_ExportToWkb, [:OGRGeometryH, FFI::OGR::Core::WKBByteOrder, :buffer_out],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_ExportToWkt, %i[OGRGeometryH pointer], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_G_DestroyGeometry, %i[OGRGeometryH], :void
      attach_gdal_function :OGR_G_Clone, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_DumpReadable, %i[OGRGeometryH pointer string], :void

      # Geometry attribute getter methods
      attach_gdal_function :OGR_G_Area, %i[OGRGeometryH], :double
      attach_gdal_function :OGR_G_Boundary, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_GetCoordinateDimension, %i[OGRGeometryH], :int
      attach_gdal_function :OGR_G_GetDimension, %i[OGRGeometryH], :int
      attach_gdal_function :OGR_G_GetEnvelope, [:OGRGeometryH, FFI::OGR::Envelope.ptr], :void
      attach_gdal_function :OGR_G_GetEnvelope3D, [:OGRGeometryH, FFI::OGR::Envelope3D.ptr], :void
      attach_gdal_function :OGR_G_GetGeometryCount, %i[OGRGeometryH], :int
      attach_gdal_function :OGR_G_GetGeometryName, %i[OGRGeometryH], :strptr
      attach_gdal_function :OGR_G_GetGeometryRef, %i[OGRGeometryH int], :OGRGeometryH
      attach_gdal_function :OGR_G_GetGeometryType, %i[OGRGeometryH], FFI::OGR::Core::WKBGeometryType
      attach_gdal_function :OGR_G_GetPoint, %i[OGRGeometryH int pointer pointer pointer], :double
      attach_gdal_function :OGR_G_GetPointCount, %i[OGRGeometryH], :int
      attach_gdal_function :OGR_G_GetPoints, %i[OGRGeometryH buffer_out int buffer_out int buffer_out int], :int
      attach_gdal_function :OGR_G_GetSpatialReference, %i[OGRGeometryH],
                           FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)
      attach_gdal_function :OGR_G_GetX, %i[OGRGeometryH int], :double
      attach_gdal_function :OGR_G_GetY, %i[OGRGeometryH int], :double
      attach_gdal_function :OGR_G_GetZ, %i[OGRGeometryH int], :double
      attach_gdal_function :OGR_G_IsEmpty, %i[OGRGeometryH], :bool
      attach_gdal_function :OGR_G_IsRing, %i[OGRGeometryH], :bool
      attach_gdal_function :OGR_G_IsSimple, %i[OGRGeometryH], :bool
      attach_gdal_function :OGR_G_IsValid, %i[OGRGeometryH], :bool
      attach_gdal_function :OGR_G_Length, %i[OGRGeometryH], :double
      attach_gdal_function :OGR_G_WkbSize, %i[OGRGeometryH], :int

      # Geometry mutating methods
      attach_gdal_function :OGR_G_AddGeometry, %i[OGRGeometryH OGRGeometryH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_AddGeometryDirectly, %i[OGRGeometryH OGRGeometryH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_AddPoint, %i[OGRGeometryH double double double], :void
      attach_gdal_function :OGR_G_AddPoint_2D, %i[OGRGeometryH double double], :void
      attach_gdal_function :OGR_G_AssignSpatialReference,
                           [:OGRGeometryH, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)], :void
      attach_gdal_function :OGR_G_RemoveGeometry, %i[OGRGeometryH int bool], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_SetCoordinateDimension, %i[OGRGeometryH int], :void
      attach_gdal_function :OGR_G_SetPoint, %i[OGRGeometryH int double double double], :void
      attach_gdal_function :OGR_G_SetPointCount, %i[OGRGeometryH int], :void
      attach_gdal_function :OGR_G_SetPoint_2D, %i[OGRGeometryH int double double], :void
      attach_gdal_function :OGR_G_SetPoints, %i[OGRGeometryH int pointer int pointer int pointer int], :void

      attach_gdal_function :OGR_G_CloseRings, %i[OGRGeometryH], :void
      attach_gdal_function :OGR_G_FlattenTo2D, %i[OGRGeometryH], :void
      attach_gdal_function :OGR_G_ForceToLineString, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_ForceToMultiLineString, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_ForceToMultiPoint, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_ForceToMultiPolygon, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_ForceToPolygon, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_Simplify, %i[OGRGeometryH double], :OGRGeometryH
      attach_gdal_function :OGR_G_SimplifyPreserveTopology, %i[OGRGeometryH double], :OGRGeometryH
      attach_gdal_function :OGR_G_Transform, [:OGRGeometryH, FFI::OGR::SRSAPI.find_type(:OGRCoordinateTransformationH)],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_G_TransformTo, [:OGRGeometryH, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)],
                           FFI::OGR::Core.enum_type(:OGRErr)

      # Geometry boolean-op methods
      attach_gdal_function :OGR_G_Buffer, %i[OGRGeometryH double int], :OGRGeometryH
      attach_gdal_function :OGR_G_Centroid, %i[OGRGeometryH OGRGeometryH], :int
      attach_gdal_function :OGR_G_Contains, %i[OGRGeometryH OGRGeometryH], :bool
      attach_gdal_function :OGR_G_ConvexHull, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_Crosses, %i[OGRGeometryH OGRGeometryH], :bool
      attach_gdal_function :OGR_G_Difference, %i[OGRGeometryH OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_Disjoint, %i[OGRGeometryH OGRGeometryH], :bool
      attach_gdal_function :OGR_G_Distance, %i[OGRGeometryH OGRGeometryH], :double
      attach_gdal_function :OGR_G_Empty, %i[OGRGeometryH], :void
      attach_gdal_function :OGR_G_Equals, %i[OGRGeometryH OGRGeometryH], :bool
      attach_gdal_function :OGR_G_Intersection, %i[OGRGeometryH OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_Intersects, %i[OGRGeometryH OGRGeometryH], :bool
      attach_gdal_function :OGR_G_Overlaps, %i[OGRGeometryH OGRGeometryH], :bool
      attach_gdal_function :OGR_G_PointOnSurface, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_Polygonize, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_Segmentize, %i[OGRGeometryH double], :void
      attach_gdal_function :OGR_G_SymDifference, %i[OGRGeometryH OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_Touches, %i[OGRGeometryH OGRGeometryH], :bool
      attach_gdal_function :OGR_G_Union, %i[OGRGeometryH OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_UnionCascaded, %i[OGRGeometryH], :OGRGeometryH
      attach_gdal_function :OGR_G_Within, %i[OGRGeometryH OGRGeometryH], :bool

      # ~~~~~~~~~~~~~~~~
      # Field-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_Fld_Create, [:string, FFI::OGR::Core::FieldType], :OGRFieldDefnH
      attach_gdal_function :OGR_Fld_Destroy, %i[OGRFieldDefnH], :void
      attach_gdal_function :OGR_Fld_SetName, %i[OGRFieldDefnH string], :void
      attach_gdal_function :OGR_Fld_GetNameRef, %i[OGRFieldDefnH], :strptr
      attach_gdal_function :OGR_Fld_GetType, %i[OGRFieldDefnH], FFI::OGR::Core::FieldType
      attach_gdal_function :OGR_Fld_SetType, [:OGRFieldDefnH, FFI::OGR::Core::FieldType], :void
      attach_gdal_function :OGR_Fld_GetJustify, %i[OGRFieldDefnH], FFI::OGR::Core::Justification
      attach_gdal_function :OGR_Fld_SetJustify, [:OGRFieldDefnH, FFI::OGR::Core::Justification], :void
      attach_gdal_function :OGR_Fld_GetWidth, %i[OGRFieldDefnH], :int
      attach_gdal_function :OGR_Fld_SetWidth, %i[OGRFieldDefnH int], :void
      attach_gdal_function :OGR_Fld_GetPrecision, %i[OGRFieldDefnH], :int
      attach_gdal_function :OGR_Fld_SetPrecision, %i[OGRFieldDefnH int], :void

      attach_gdal_function :OGR_Fld_Set,
                           [:OGRFieldDefnH, :string, FFI::OGR::Core::FieldType, :int, :int,
                            FFI::OGR::Core::Justification],
                           :void
      attach_gdal_function :OGR_Fld_IsIgnored, %i[OGRFieldDefnH], :bool
      attach_gdal_function :OGR_Fld_SetIgnored, %i[OGRFieldDefnH bool], :void

      attach_gdal_function :OGR_GetFieldTypeName, [FFI::OGR::Core::FieldType], :strptr

      # ~~~~~~~~~~~~~~~~
      # Geometry Field-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_GFld_Create,
                           [:string, FFI::OGR::Core::WKBGeometryType],
                           :OGRGeomFieldDefnH
      attach_gdal_function :OGR_GFld_Destroy, %i[OGRGeomFieldDefnH], :void
      attach_gdal_function :OGR_GFld_SetName, %i[OGRGeomFieldDefnH string], :void
      attach_gdal_function :OGR_GFld_GetNameRef, %i[OGRGeomFieldDefnH], :strptr
      attach_gdal_function :OGR_GFld_GetType, %i[OGRGeomFieldDefnH], FFI::OGR::Core::WKBGeometryType
      attach_gdal_function :OGR_GFld_SetType,
                           [:OGRGeomFieldDefnH, FFI::OGR::Core::WKBGeometryType],
                           :void
      attach_gdal_function :OGR_GFld_GetSpatialRef,
                           %i[OGRGeomFieldDefnH],
                           FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)
      attach_gdal_function :OGR_GFld_SetSpatialRef,
                           [:OGRGeomFieldDefnH, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)],
                           :void
      attach_gdal_function :OGR_GFld_IsIgnored, %i[OGRGeomFieldDefnH], :bool
      attach_gdal_function :OGR_GFld_SetIgnored, %i[OGRGeomFieldDefnH bool], :void

      # ~~~~~~~~~~~~~~~~
      # Feature Definition-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_FD_Create, %i[string], :OGRFeatureDefnH
      attach_gdal_function :OGR_FD_Destroy, %i[OGRFeatureDefnH], :void
      attach_gdal_function :OGR_FD_Release, %i[OGRFeatureDefnH], :void
      attach_gdal_function :OGR_FD_GetName, %i[OGRFeatureDefnH], :strptr
      attach_gdal_function :OGR_FD_GetFieldCount, %i[OGRFeatureDefnH], :int
      attach_gdal_function :OGR_FD_GetFieldDefn, %i[OGRFeatureDefnH int], :OGRFieldDefnH
      attach_gdal_function :OGR_FD_GetFieldIndex, %i[OGRFeatureDefnH string], :int
      attach_gdal_function :OGR_FD_AddFieldDefn,
                           %i[OGRFeatureDefnH OGRFieldDefnH],
                           :void
      attach_gdal_function :OGR_FD_DeleteFieldDefn,
                           %i[OGRFeatureDefnH int],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_FD_GetGeomType, %i[OGRFeatureDefnH], FFI::OGR::Core::WKBGeometryType
      attach_gdal_function :OGR_FD_SetGeomType,
                           [:OGRFeatureDefnH, FFI::OGR::Core::WKBGeometryType],
                           :void
      attach_gdal_function :OGR_FD_IsGeometryIgnored, %i[OGRFeatureDefnH], :bool
      attach_gdal_function :OGR_FD_SetGeometryIgnored, %i[OGRFeatureDefnH bool], :void
      attach_gdal_function :OGR_FD_IsStyleIgnored, %i[OGRFeatureDefnH], :bool
      attach_gdal_function :OGR_FD_SetStyleIgnored, %i[OGRFeatureDefnH bool], :void
      attach_gdal_function :OGR_FD_Reference, %i[OGRFeatureDefnH], :int
      attach_gdal_function :OGR_FD_Dereference, %i[OGRFeatureDefnH], :int
      attach_gdal_function :OGR_FD_GetReferenceCount, %i[OGRFeatureDefnH], :int
      attach_gdal_function :OGR_FD_GetGeomFieldCount, %i[OGRFeatureDefnH], :int
      attach_gdal_function :OGR_FD_GetGeomFieldDefn,
                           %i[OGRFeatureDefnH int],
                           :OGRGeomFieldDefnH
      attach_gdal_function :OGR_FD_GetGeomFieldIndex,
                           %i[OGRFeatureDefnH string],
                           :int
      attach_gdal_function :OGR_FD_AddGeomFieldDefn,
                           %i[OGRFeatureDefnH OGRGeomFieldDefnH],
                           :void
      attach_gdal_function :OGR_FD_DeleteGeomFieldDefn,
                           %i[OGRFeatureDefnH int],
                           FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_FD_IsSame,
                           %i[OGRFeatureDefnH OGRFeatureDefnH],
                           :bool

      # ~~~~~~~~~~~~~~~~
      # Feature-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_F_Create, %i[OGRFeatureDefnH], :OGRFeatureH
      attach_gdal_function :OGR_F_Destroy, %i[OGRFeatureH], :void
      attach_gdal_function :OGR_F_GetDefnRef, %i[OGRFeatureH], :OGRFeatureDefnH
      attach_gdal_function :OGR_F_SetGeometryDirectly,
                           %i[OGRFeatureH OGRGeometryH],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_F_SetGeometry,
                           %i[OGRFeatureH OGRGeometryH],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_F_GetGeometryRef, %i[OGRFeatureH], :OGRGeometryH
      attach_gdal_function :OGR_F_StealGeometry, %i[OGRFeatureH], :OGRGeometryH

      attach_gdal_function :OGR_F_Clone, %i[OGRFeatureH], :OGRFeatureH
      attach_gdal_function :OGR_F_Equal, %i[OGRFeatureH OGRFeatureH], :bool
      attach_gdal_function :OGR_F_GetFieldCount, %i[OGRFeatureH], :int
      attach_gdal_function :OGR_F_GetFieldDefnRef, %i[OGRFeatureH int], :OGRFieldDefnH
      attach_gdal_function :OGR_F_GetFieldIndex, %i[OGRFeatureH string], :int
      attach_gdal_function :OGR_F_IsFieldSet, %i[OGRFeatureH int], :bool
      attach_gdal_function :OGR_F_UnsetField, %i[OGRFeatureH int], :void
      attach_gdal_function :OGR_F_GetRawFieldRef, %i[OGRFeatureH int], FFI::OGR::Field.ptr

      attach_gdal_function :OGR_F_GetFieldAsInteger, %i[OGRFeatureH int], :int
      attach_gdal_function :OGR_F_GetFieldAsDouble, %i[OGRFeatureH int], :double
      attach_gdal_function :OGR_F_GetFieldAsString, %i[OGRFeatureH int], :strptr
      attach_gdal_function :OGR_F_GetFieldAsIntegerList, %i[OGRFeatureH int pointer], :pointer
      attach_gdal_function :OGR_F_GetFieldAsDoubleList, %i[OGRFeatureH int pointer], :pointer
      attach_gdal_function :OGR_F_GetFieldAsStringList, %i[OGRFeatureH int], :pointer
      attach_gdal_function :OGR_F_GetFieldAsBinary, %i[OGRFeatureH int pointer], :pointer
      attach_gdal_function :OGR_F_GetFieldAsDateTime,
                           %i[OGRFeatureH int pointer pointer pointer pointer pointer pointer pointer],
                           :int
      attach_gdal_function :OGR_F_SetFieldInteger, %i[OGRFeatureH int int], :void
      attach_gdal_function :OGR_F_SetFieldDouble, %i[OGRFeatureH int double], :void
      attach_gdal_function :OGR_F_SetFieldString, %i[OGRFeatureH int string], :void
      attach_gdal_function :OGR_F_SetFieldIntegerList, %i[OGRFeatureH int int pointer], :void
      attach_gdal_function :OGR_F_SetFieldDoubleList, %i[OGRFeatureH int int pointer], :void
      attach_gdal_function :OGR_F_SetFieldStringList, %i[OGRFeatureH int pointer], :void
      attach_gdal_function :OGR_F_SetFieldRaw, [:OGRFeatureH, :int, FFI::OGR::Field.ptr], :void
      attach_gdal_function :OGR_F_SetFieldBinary, %i[OGRFeatureH int int pointer], :void
      attach_gdal_function :OGR_F_SetFieldDateTime,
                           %i[OGRFeatureH int int int int int int int int],
                           :void

      attach_gdal_function :OGR_F_GetGeomFieldCount, %i[OGRFeatureH], :int
      attach_gdal_function :OGR_F_GetGeomFieldDefnRef, %i[OGRFeatureH int], :OGRGeomFieldDefnH
      attach_gdal_function :OGR_F_GetGeomFieldIndex, %i[OGRFeatureH string], :int
      attach_gdal_function :OGR_F_GetGeomFieldRef, %i[OGRFeatureH int], :OGRGeometryH
      attach_gdal_function :OGR_F_SetGeomFieldDirectly, %i[OGRFeatureH int OGRGeometryH],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_F_SetGeomField, %i[OGRFeatureH int OGRGeometryH], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_F_GetFID, %i[OGRFeatureH], :long
      attach_gdal_function :OGR_F_SetFID, %i[OGRFeatureH long], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_F_DumpReadable, %i[OGRFeatureH pointer], :void
      attach_gdal_function :OGR_F_SetFrom, %i[OGRFeatureH OGRFeatureH int], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_F_SetFromWithMap, %i[OGRFeatureH OGRFeatureH int pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_F_GetStyleString, %i[OGRFeatureH], :strptr
      attach_gdal_function :OGR_F_SetStyleString, %i[OGRFeatureH string], :void
      attach_gdal_function :OGR_F_SetStyleStringDirectly, %i[OGRFeatureH string], :void
      attach_gdal_function :OGR_F_GetStyleTable, %i[OGRFeatureH], :OGRStyleTableH
      attach_gdal_function :OGR_F_SetStyleTableDirectly, %i[OGRFeatureH OGRStyleTableH], :void
      attach_gdal_function :OGR_F_SetStyleTable, %i[OGRFeatureH OGRStyleTableH], :void

      # ~~~~~~~~~~~~~~~~
      # Layer-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_L_GetLayerDefn, %i[OGRLayerH], :OGRFeatureDefnH

      # The resulting pointer is such that the OGR docs say "must not been freed" (which doesn't make sense). For now
      # let's assume OGR maintains ownership and we should thus not free it.
      attach_gdal_function :OGR_L_GetName, %i[OGRLayerH], :strptr
      attach_gdal_function :OGR_L_GetGeomType, %i[OGRLayerH], FFI::OGR::Core::WKBGeometryType
      attach_gdal_function :OGR_L_Dereference, %i[OGRLayerH], :int
      attach_gdal_function :OGR_L_GetRefCount, %i[OGRLayerH], :int
      attach_gdal_function :OGR_L_Reference, %i[OGRLayerH], :int
      attach_gdal_function :OGR_L_SyncToDisk, %i[OGRLayerH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_ResetReading, %i[OGRLayerH], :void
      attach_gdal_function :OGR_L_TestCapability, %i[OGRLayerH string], :bool

      attach_gdal_function :OGR_L_GetSpatialFilter, %i[OGRLayerH], :OGRGeometryH
      attach_gdal_function :OGR_L_GetSpatialRef, %i[OGRLayerH], FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)
      attach_gdal_function :OGR_L_SetSpatialFilter, %i[OGRLayerH OGRGeometryH], :void
      attach_gdal_function :OGR_L_SetSpatialFilterEx, %i[OGRLayerH int OGRGeometryH], :void
      attach_gdal_function :OGR_L_SetSpatialFilterRect, %i[OGRLayerH double double double double], :void
      attach_gdal_function :OGR_L_SetSpatialFilterRectEx, %i[OGRLayerH int double double double double], :void

      attach_gdal_function :OGR_L_SetAttributeFilter, %i[OGRLayerH string], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_L_SetNextByIndex, %i[OGRLayerH long], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_L_CreateFeature, %i[OGRLayerH OGRFeatureH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_DeleteFeature, %i[OGRLayerH long], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_GetFeature, %i[OGRLayerH long], :OGRFeatureH
      attach_gdal_function :OGR_L_GetFeatureCount, %i[OGRLayerH bool], :int
      attach_gdal_function :OGR_L_GetFeaturesRead, %i[OGRLayerH], CPL::Port.find_type(:GIntBig)
      attach_gdal_function :OGR_L_GetNextFeature, %i[OGRLayerH], :OGRFeatureH
      attach_gdal_function :OGR_L_SetFeature, %i[OGRLayerH OGRFeatureH], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_L_GetExtent, [:OGRLayerH, FFI::OGR::Envelope.ptr, :bool],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_GetExtentEx, [:OGRLayerH, :int, FFI::OGR::Envelope.ptr, :bool],
                           FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_L_AlterFieldDefn, %i[OGRLayerH int OGRFieldDefnH int], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_CreateField, %i[OGRLayerH OGRFieldDefnH bool], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_CreateGeomField, %i[OGRLayerH OGRGeomFieldDefnH bool],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_DeleteField, %i[OGRLayerH int], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_FindFieldIndex, %i[OGRLayerH string bool], :int
      attach_gdal_function :OGR_L_ReorderField, %i[OGRLayerH int int], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_ReorderFields, %i[OGRLayerH pointer], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_SetIgnoredFields, %i[OGRLayerH pointer], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_L_CommitTransaction, %i[OGRLayerH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_RollbackTransaction, %i[OGRLayerH], FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_StartTransaction, %i[OGRLayerH], FFI::OGR::Core.enum_type(:OGRErr)

      attach_gdal_function :OGR_L_GetFIDColumn, %i[OGRLayerH], :strptr
      attach_gdal_function :OGR_L_GetGeometryColumn, %i[OGRLayerH], :strptr

      attach_gdal_function :OGR_L_GetStyleTable, %i[OGRLayerH], :OGRStyleTableH
      attach_gdal_function :OGR_L_SetStyleTable, %i[OGRLayerH OGRStyleTableH], :void
      attach_gdal_function :OGR_L_SetStyleTableDirectly, %i[OGRLayerH OGRStyleTableH], :void

      # rubocop:disable Layout/LineLength
      attach_gdal_function :OGR_L_Clip,
                           [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc), :pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_Erase,
                           [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc), :pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_Identity,
                           [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc), :pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_Intersection,
                           [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc), :pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_SymDifference,
                           [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc), :pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_Union,
                           [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc), :pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      attach_gdal_function :OGR_L_Update,
                           [:OGRLayerH, :OGRLayerH, :OGRLayerH, :pointer, FFI::GDAL::GDAL.find_type(:GDALProgressFunc), :pointer],
                           FFI::OGR::Core.enum_type(:OGRErr)
      # rubocop:enable Layout/LineLength

      # ~~~~~~~~~~~~~~~~
      # DataSource-related
      # ~~~~~~~~~~~~~~~~
      # Deprecated in 2.0; use GDALDatasetCopyLayer()
      attach_gdal_function :OGR_DS_CopyLayer, %i[OGRDataSourceH OGRLayerH string pointer], :OGRLayerH
      # Deprecated in 2.0; use GDALDatasetCreateLayer()
      attach_gdal_function :OGR_DS_CreateLayer,
                           [
                             :OGRDataSourceH,
                             :string,
                             FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH),
                             FFI::OGR::Core::WKBGeometryType,
                             :pointer
                           ], :OGRLayerH
      # Deprecated in 2.0; use GDALDatasetDeleteLayer()
      attach_gdal_function :OGR_DS_DeleteLayer, %i[OGRDataSourceH int],
                           FFI::OGR::Core.enum_type(:OGRErr)
      # Deprecated in 2.0; use GDALClose()
      attach_gdal_function :OGR_DS_Destroy, %i[OGRDataSourceH], :void
      # Deprecated in 2.0; use GDALDatasetExecuteSQL()
      attach_gdal_function :OGR_DS_ExecuteSQL, %i[OGRDataSourceH string OGRGeometryH string], :OGRLayerH
      # Deprecated in 2.0; use GDALGetDatasetDriver()
      attach_gdal_function :OGR_DS_GetDriver, %i[OGRDataSourceH], :OGRSFDriverH
      # Deprecated in 2.0; use GDALDatasetGetLayer()
      attach_gdal_function :OGR_DS_GetLayer, %i[OGRDataSourceH int], :OGRLayerH
      # Deprecated in 2.0; use GDALDatasetGetLayerByName()
      attach_gdal_function :OGR_DS_GetLayerByName, %i[OGRDataSourceH string], :OGRLayerH
      # Deprecated in 2.0; use GDALDatasetGetLayerCount()
      attach_gdal_function :OGR_DS_GetLayerCount, %i[OGRDataSourceH], :int
      # Deprecated in 2.0; use GDALGetDescription()
      attach_gdal_function :OGR_DS_GetName, %i[OGRDataSourceH], :string # <- don't free this!
      attach_gdal_function :OGR_DS_GetStyleTable, %i[OGRDataSourceH], :OGRStyleTableH
      # Deprecated in 2.0; use GDALDatasetREleaseResultSet()
      attach_gdal_function :OGR_DS_ReleaseResultSet, %i[OGRDataSourceH OGRLayerH], :void
      attach_gdal_function :OGR_DS_SetStyleTable, %i[OGRDataSourceH OGRStyleTableH], :void
      attach_gdal_function :OGR_DS_SetStyleTableDirectly, %i[OGRDataSourceH OGRStyleTableH], :void
      attach_gdal_function :OGR_DS_SyncToDisk, %i[OGRDataSourceH], FFI::OGR::Core.enum_type(:OGRErr)
      # Deprecated in 2.0; use GDALDatasetTestCapability()
      attach_gdal_function :OGR_DS_TestCapability, %i[OGRDataSourceH string], :bool

      # ~~~~~~~~~~~~~~~~
      # Driver-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_Dr_GetName, %i[OGRSFDriverH], :strptr
      attach_gdal_function :OGR_Dr_Open, %i[OGRSFDriverH string bool], :OGRDataSourceH
      attach_gdal_function :OGR_Dr_TestCapability, %i[OGRSFDriverH string], :bool
      attach_gdal_function :OGR_Dr_CreateDataSource, %i[OGRSFDriverH string pointer], :OGRDataSourceH
      attach_gdal_function :OGR_Dr_CopyDataSource,
                           %i[OGRSFDriverH OGRDataSourceH string pointer],
                           :OGRDataSourceH
      attach_gdal_function :OGR_Dr_DeleteDataSource, %i[OGRSFDriverH string], FFI::OGR::Core.enum_type(:OGRErr)

      # ~~~~~~~~~~~~~~~~
      # Style Manager-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_SM_Create, %i[OGRStyleTableH], :OGRStyleMgrH
      attach_gdal_function :OGR_SM_Destroy, %i[OGRStyleTableH], :void
      attach_gdal_function :OGR_SM_InitFromFeature, %i[OGRStyleTableH OGRFeatureH], :strptr
      attach_gdal_function :OGR_SM_InitStyleString, %i[OGRStyleTableH string], :int
      attach_gdal_function :OGR_SM_GetPartCount, %i[OGRStyleTableH string], :int
      attach_gdal_function :OGR_SM_GetPart,
                           %i[OGRStyleTableH int string],
                           :OGRStyleToolH
      attach_gdal_function :OGR_SM_AddPart, %i[OGRStyleTableH OGRStyleToolH], :int
      attach_gdal_function :OGR_SM_AddStyle, %i[OGRStyleTableH string string], :int

      # ~~~~~~~~~~~~~~~~
      # Style Tool-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_ST_Create, [FFI::OGR::Core::STClassId], :OGRStyleToolH
      attach_gdal_function :OGR_ST_Destroy, %i[OGRStyleToolH], :void
      attach_gdal_function :OGR_ST_GetParamDbl, %i[OGRStyleToolH int pointer], :double
      attach_gdal_function :OGR_ST_GetParamNum, %i[OGRStyleToolH int pointer], :int
      attach_gdal_function :OGR_ST_GetParamStr, %i[OGRStyleToolH int pointer], :strptr
      attach_gdal_function :OGR_ST_GetRGBFromString, %i[OGRStyleToolH string pointer pointer pointer pointer], :bool
      attach_gdal_function :OGR_ST_GetStyleString, %i[OGRStyleToolH], :strptr
      attach_gdal_function :OGR_ST_GetType, %i[OGRStyleToolH], FFI::OGR::Core::STClassId
      attach_gdal_function :OGR_ST_GetUnit, %i[OGRStyleToolH], FFI::OGR::Core::STUnitId
      attach_gdal_function :OGR_ST_SetParamDbl, %i[OGRStyleToolH int double], :void
      attach_gdal_function :OGR_ST_SetParamNum, %i[OGRStyleToolH int int], :void
      attach_gdal_function :OGR_ST_SetParamStr, %i[OGRStyleToolH int string], :double
      attach_gdal_function :OGR_ST_SetUnit, [:OGRStyleToolH, FFI::OGR::Core::STUnitId, :double], :void

      # ~~~~~~~~~~~~~~~~
      # Style Table-related
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGR_STBL_AddStyle, %i[OGRStyleTableH string string], :bool
      attach_gdal_function :OGR_STBL_Create, [], :OGRStyleTableH
      attach_gdal_function :OGR_STBL_Destroy, %i[OGRStyleTableH], :void
      attach_gdal_function :OGR_STBL_Find, %i[OGRStyleTableH string], :string
      attach_gdal_function :OGR_STBL_GetLastStyleName, %i[OGRStyleTableH], :string
      attach_gdal_function :OGR_STBL_GetNextStyle, %i[OGRStyleTableH], :string
      attach_gdal_function :OGR_STBL_LoadStyleTable, %i[OGRStyleTableH string], :bool
      attach_gdal_function :OGR_STBL_ResetStyleStringReading, %i[OGRStyleTableH], :void
      attach_gdal_function :OGR_STBL_SaveStyleTable, %i[OGRStyleTableH string], :bool

      # ~~~~~~~~~~~~~~~~
      # Main functions
      # ~~~~~~~~~~~~~~~~
      attach_gdal_function :OGRCleanupAll, [], :void
      attach_gdal_function :OGRDeregisterDriver, %i[OGRSFDriverH], :void
      attach_gdal_function :OGRGetDriver, %i[int], :OGRSFDriverH
      attach_gdal_function :OGRGetDriverByName, %i[string], :OGRSFDriverH
      attach_gdal_function :OGRGetDriverCount, [], :int
      attach_gdal_function :OGRGetOpenDS, %i[int], :OGRDataSourceH
      attach_gdal_function :OGRGetOpenDSCount, [], :int
      # Deprecated in 2.0; use GDALOpenEx()
      attach_gdal_function :OGROpen, %i[string bool OGRSFDriverH], :OGRDataSourceH
      attach_gdal_function :OGRRegisterAll, [], :void
      attach_gdal_function :OGRRegisterDriver, %i[OGRSFDriverH], :void
      attach_gdal_function :OGRReleaseDataSource, %i[OGRDataSourceH], FFI::OGR::Core.enum_type(:OGRErr)
    end
  end
end
