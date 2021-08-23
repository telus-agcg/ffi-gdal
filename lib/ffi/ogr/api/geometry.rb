# frozen_string_literal: true

require 'ffi/library'

module FFI
  module OGR
    module API
      extend ::FFI::Library
      @ffi_libs ||= FFI::GDAL.loaded_ffi_libs

      typedef :pointer, :OGRGeometryH

      attach_function :OGR_G_CreateFromWkb,
                      [:pointer, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH), :pointer, :int],
                      FFI::OGR::Core::Err
      attach_function :OGR_G_CreateFromWkt,
                      [:pointer, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH), :pointer],
                      FFI::OGR::Core::Err
      # TODO: wrap
      attach_function :OGR_G_CreateFromFgf,
                      [:string, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH), :pointer, :int, :pointer],
                      FFI::OGR::Core::Err
      # ~~~~~~~~~~~~~~~~
      # Geometry-related
      # ~~~~~~~~~~~~~~~~
      attach_function :OGR_G_DestroyGeometry, %i[OGRGeometryH], :void
      attach_function :OGR_G_CreateGeometry, [FFI::OGR::Core::WKBGeometryType], :OGRGeometryH
      attach_function :OGR_G_ApproximateArcAngles,
                      [
                        :double, :double, :double,    # X, Y, Z
                        :double, :double, :double,    # primary radius, 2nd Axis, rotation
                        :double, :double, :double     # start angle, end angle, max angle step size
                      ],
                      :OGRGeometryH

      attach_function :OGR_G_ForceToLineString, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_ForceToMultiLineString, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_ForceToMultiPoint, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_ForceToMultiPolygon, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_ForceToPolygon, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_ForceTo, [:OGRGeometryH, FFI::OGR::Core::WKBGeometryType, :pointer],
                      :OGRGeometryH

      attach_function :OGR_G_GetDimension, %i[OGRGeometryH], :int
      attach_function :OGR_G_GetCoordinateDimension, %i[OGRGeometryH], :int
      attach_function :OGR_G_SetCoordinateDimension, %i[OGRGeometryH int], :void
      attach_function :OGR_G_Clone, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_GetEnvelope,
                      [:OGRGeometryH, FFI::OGR::Envelope.by_ref],
                      :void
      attach_function :OGR_G_GetEnvelope3D,
                      [:OGRGeometryH, FFI::OGR::Envelope3D.by_ref],
                      :void

      attach_function :OGR_G_ImportFromWkb,
                      %i[OGRGeometryH string int],
                      FFI::OGR::Core::Err
      attach_function :OGR_G_ExportToWkb,
                      [:OGRGeometryH, FFI::OGR::Core::WKBByteOrder, :buffer_out],
                      FFI::OGR::Core::Err
      attach_function :OGR_G_ExportToIsoWkb,
                      [:OGRGeometryH, FFI::OGR::Core::WKBByteOrder, :buffer_out],
                      FFI::OGR::Core::Err
      attach_function :OGR_G_WkbSize, %i[OGRGeometryH], :int

      attach_function :OGR_G_ImportFromWkt, %i[OGRGeometryH pointer], FFI::OGR::Core::Err
      attach_function :OGR_G_ExportToWkt, %i[OGRGeometryH pointer], FFI::OGR::Core::Err
      attach_function :OGR_G_ExportToIsoWkt, %i[OGRGeometryH pointer], FFI::OGR::Core::Err

      attach_function :OGR_G_GetGeometryType, %i[OGRGeometryH], FFI::OGR::Core::WKBGeometryType
      attach_function :OGR_G_GetGeometryName, %i[OGRGeometryH], :string
      attach_function :OGR_G_DumpReadable,
                      %i[OGRGeometryH pointer string],
                      :void
      attach_function :OGR_G_FlattenTo2D, %i[OGRGeometryH], :void
      attach_function :OGR_G_CloseRings, %i[OGRGeometryH], :void

      attach_function :OGR_G_CreateFromGML, %i[string], :OGRGeometryH
      attach_function :OGR_G_ExportToGML, %i[OGRGeometryH], :strptr
      attach_function :OGR_G_ExportToGMLEx, %i[OGRGeometryH pointer], :strptr
      attach_function :OGR_G_CreateFromGMLTree,
                      [FFI::CPL::XMLNode.ptr],
                      :OGRGeometryH
      # TODO: wrap
      attach_function :OGR_G_ExportToGMLTree,
                      %i[OGRGeometryH],
                      FFI::CPL::XMLNode.ptr
      # TODO: wrap
      attach_function :OGR_G_ExportEnvelopeToGMLTree,
                      %i[OGRGeometryH],
                      FFI::CPL::XMLNode.ptr

      attach_function :OGR_G_ExportToKML, %i[OGRGeometryH string], :strptr
      attach_function :OGR_G_ExportToJson, %i[OGRGeometryH], :strptr
      attach_function :OGR_G_ExportToJsonEx, %i[OGRGeometryH pointer], :strptr
      attach_function :OGR_G_CreateGeometryFromJson, %i[string], :OGRGeometryH

      attach_function :OGR_G_AssignSpatialReference,
                      [:OGRGeometryH, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)],
                      :void
      attach_function :OGR_G_GetSpatialReference,
                      %i[OGRGeometryH],
                      FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)

      attach_function :OGR_G_Transform,
                      [:OGRGeometryH, FFI::OGR::SRSAPI.find_type(:OGRCoordinateTransformationH)],
                      FFI::OGR::Core::Err
      attach_function :OGR_G_TransformTo,
                      [:OGRGeometryH, FFI::OGR::SRSAPI.find_type(:OGRSpatialReferenceH)],
                      FFI::OGR::Core::Err
      attach_function :OGR_G_Simplify, %i[OGRGeometryH double], :OGRGeometryH
      attach_function :OGR_G_SimplifyPreserveTopology,
                      %i[OGRGeometryH double],
                      :OGRGeometryH
      attach_function :OGR_G_Segmentize, %i[OGRGeometryH double], :void
      attach_function :OGR_G_Intersects, %i[OGRGeometryH OGRGeometryH], :bool
      attach_function :OGR_G_Equals, %i[OGRGeometryH OGRGeometryH], :bool
      attach_function :OGR_G_Disjoint, %i[OGRGeometryH OGRGeometryH], :bool
      attach_function :OGR_G_Touches, %i[OGRGeometryH OGRGeometryH], :bool
      attach_function :OGR_G_Crosses, %i[OGRGeometryH OGRGeometryH], :bool
      attach_function :OGR_G_Within, %i[OGRGeometryH OGRGeometryH], :bool
      attach_function :OGR_G_Contains, %i[OGRGeometryH OGRGeometryH], :bool
      attach_function :OGR_G_Overlaps, %i[OGRGeometryH OGRGeometryH], :bool

      attach_function :OGR_G_Boundary, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_ConvexHull, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_Buffer, %i[OGRGeometryH double int], :OGRGeometryH
      attach_function :OGR_G_Intersection,
                      %i[OGRGeometryH OGRGeometryH],
                      :OGRGeometryH
      attach_function :OGR_G_Union,
                      %i[OGRGeometryH OGRGeometryH],
                      :OGRGeometryH
      attach_function :OGR_G_UnionCascaded, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_PointOnSurface, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_Difference,
                      %i[OGRGeometryH OGRGeometryH],
                      :OGRGeometryH
      attach_function :OGR_G_SymDifference,
                      %i[OGRGeometryH OGRGeometryH],
                      :OGRGeometryH
      attach_function :OGR_G_Distance,
                      %i[OGRGeometryH OGRGeometryH],
                      :double
      attach_function :OGR_G_Length,
                      %i[OGRGeometryH],
                      :double
      attach_function :OGR_G_Area,
                      %i[OGRGeometryH],
                      :double
      attach_function :OGR_G_Centroid,
                      %i[OGRGeometryH OGRGeometryH],
                      :int
      attach_function :OGR_G_Empty, %i[OGRGeometryH], :void
      attach_function :OGR_G_IsEmpty, %i[OGRGeometryH], :bool
      attach_function :OGR_G_IsValid, %i[OGRGeometryH], :bool
      attach_function :OGR_G_IsSimple, %i[OGRGeometryH], :bool
      attach_function :OGR_G_IsRing, %i[OGRGeometryH], :bool

      attach_function :OGR_G_Polygonize, %i[OGRGeometryH], :OGRGeometryH
      attach_function :OGR_G_GetPointCount, %i[OGRGeometryH], :int
      attach_function :OGR_G_GetPoints,
                      %i[OGRGeometryH buffer_out int buffer_out int buffer_out int],
                      :int
      attach_function :OGR_G_GetX, %i[OGRGeometryH int], :double
      attach_function :OGR_G_GetY, %i[OGRGeometryH int], :double
      attach_function :OGR_G_GetZ, %i[OGRGeometryH int], :double
      attach_function :OGR_G_GetPoint,
                      %i[OGRGeometryH int pointer pointer pointer],
                      :double
      attach_function :OGR_G_SetPointCount,
                      %i[OGRGeometryH int],
                      :void
      attach_function :OGR_G_SetPoint,
                      %i[OGRGeometryH int double double double],
                      :void
      attach_function :OGR_G_SetPoint_2D,
                      %i[OGRGeometryH int double double],
                      :void
      attach_function :OGR_G_AddPoint,
                      %i[OGRGeometryH double double double],
                      :void
      attach_function :OGR_G_AddPoint_2D,
                      %i[OGRGeometryH double double],
                      :void
      attach_function :OGR_G_SetPoints,
                      %i[OGRGeometryH int pointer int pointer int pointer int],
                      :void

      attach_function :OGR_G_GetGeometryCount, %i[OGRGeometryH], :int
      attach_function :OGR_G_GetGeometryRef, %i[OGRGeometryH int], :OGRGeometryH

      attach_function :OGR_G_AddGeometry, %i[OGRGeometryH OGRGeometryH], FFI::OGR::Core::Err
      attach_function :OGR_G_AddGeometryDirectly, %i[OGRGeometryH OGRGeometryH], FFI::OGR::Core::Err
      attach_function :OGR_G_RemoveGeometry, %i[OGRGeometryH int bool], FFI::OGR::Core::Err

      attach_function :OGRBuildPolygonFromEdges,
                      %i[OGRGeometryH bool bool double pointer],
                      :OGRGeometryH
    end
  end
end
