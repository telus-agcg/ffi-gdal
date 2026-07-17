# frozen_string_literal: true

module OGR
  module Geometry
    # Class-level factory and creation helpers for OGR::Geometry. Extended onto
    # OGR::Geometry itself and onto every class that includes it.
    module ClassMethods
      def create(type)
        geometry_pointer = FFI::OGR::API.OGR_G_CreateGeometry(type)
        return if geometry_pointer.null?

        geometry_pointer.autorelease = false

        factory(geometry_pointer)
      end

      # Maps each WKB geometry type to the name of the OGR::Geometry subclass
      # that wraps it. Class names (not the classes themselves) are stored so
      # they can be resolved lazily -- the subclasses load after this file.
      # wkbLineString is intentionally absent: it resolves to LinearRing or
      # LineString based on the WKT, handled in #factory.
      WKB_TYPE_TO_GEOMETRY_CLASS_NAME = {
        wkbPoint: :Point,
        wkbPoint25D: :Point25D,
        wkbLineString25D: :LineString25D,
        wkbLinearRing: :LinearRing,
        wkbPolygon: :Polygon,
        wkbPolygon25D: :Polygon25D,
        wkbMultiPoint: :MultiPoint,
        wkbMultiPoint25D: :MultiPoint25D,
        wkbMultiLineString: :MultiLineString,
        wkbMultiLineString25D: :MultiLineString25D,
        wkbMultiPolygon: :MultiPolygon,
        wkbMultiPolygon25D: :MultiPolygon25D,
        wkbGeometryCollection: :GeometryCollection,
        wkbGeometryCollection25D: :GeometryCollection25D,
        wkbNone: :NoneGeometry
      }.freeze

      # Creates a new Geometry using the class of the geometry that the type
      # represents.
      #
      # @param geometry [OGR::Geometry, FFI::Pointer]
      # @return [OGR::Geometry]
      def factory(geometry)
        geometry = OGR::UnknownGeometry.new(geometry) unless geometry.is_a?(OGR::Geometry)

        new_pointer = geometry.c_pointer
        return if new_pointer.nil? || new_pointer.null?

        geometry_type = geometry.type

        # wkbLineString wraps either a LinearRing or a plain LineString.
        if geometry_type == :wkbLineString
          class_name = /^LINEARRING/.match?(geometry.to_wkt) ? :LinearRing : :LineString
          return OGR.const_get(class_name).new(new_pointer)
        end

        class_name = WKB_TYPE_TO_GEOMETRY_CLASS_NAME[geometry_type]
        return geometry unless class_name

        OGR.const_get(class_name).new(new_pointer)
      end

      # @param wkt_data [String]
      # @param spatial_ref [FFI::Pointer] Optional spatial reference
      #   to assign to the new geometry.
      # @return [OGR::Geometry]
      def create_from_wkt(wkt_data, spatial_ref = nil)
        wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
        wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
        wkt_pointer_pointer.write_pointer(wkt_data_pointer)

        spatial_ref_pointer = GDAL._pointer(OGR::SpatialReference, spatial_ref) if spatial_ref

        geometry_ptr = FFI::MemoryPointer.new(:pointer)
        geometry_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        geometry_ptr_ptr.write_pointer(geometry_ptr)

        FFI::OGR::API.OGR_G_CreateFromWkt(wkt_pointer_pointer,
                                          spatial_ref_pointer, geometry_ptr_ptr)

        return if geometry_ptr_ptr.null? || geometry_ptr_ptr.read_pointer.null?

        factory(geometry_ptr_ptr.read_pointer)
      end

      # @param wkb_data [String] Binary string of WKB.
      # @param spatial_ref [OGR::SpatialReference]
      # @return [OGR::Geometry]
      def create_from_wkb(wkb_data, spatial_ref = nil)
        wkb_data_pointer = FFI::MemoryPointer.new(:char, wkb_data.length)
        wkb_data_pointer.put_bytes(0, wkb_data)

        spatial_ref_pointer = GDAL._pointer(OGR::SpatialReference, spatial_ref) if spatial_ref

        geometry_ptr_ptr = GDAL._pointer_pointer(:pointer)

        byte_count = wkb_data.length
        FFI::OGR::API.OGR_G_CreateFromWkb(wkb_data_pointer, spatial_ref_pointer, geometry_ptr_ptr, byte_count)

        return if geometry_ptr_ptr.null? || geometry_ptr_ptr.read_pointer.null?

        factory(geometry_ptr_ptr.read_pointer)
      end

      # @param gml_data [String]
      # @return [OGR::Geometry]
      def create_from_gml(gml_data)
        geometry_pointer = FFI::OGR::API.OGR_G_CreateFromGML(gml_data)

        _ = factory(geometry_pointer)
      end

      # @param json_data [String]
      # @return [OGR::Geometry]
      def create_from_json(json_data)
        geometry_pointer = FFI::OGR::API.OGR_G_CreateGeometryFromJson(json_data)

        factory(geometry_pointer)
      end

      # The human-readable string for the geometry type.
      #
      # @param type [FFI::OGR::WKBGeometryType]
      # @return [String]
      def type_to_name(type)
        name, ptr = FFI::OGR::Core.OGRGeometryTypeToName(type)
        ptr.autorelease = false

        name
      end

      # Finds the most specific common geometry type from the two given types.
      # Useful when trying to figure out what geometry type to report for an
      # entire layer, when the layer uses multiple types.
      #
      # @param main [FFI::OGR::WKBGeometryType]
      # @param extra [FFI::OGR::WKBGeometryType]
      # @return [FFI::OGR::WKBGeometryType] Returns :wkbUnknown when there is
      #   no type in common.
      def merge_geometry_types(main, extra)
        FFI::OGR::Core.OGRMergeGeometryTypes(main, extra)
      end

      # @param pointer [FFI::Pointer]
      def release(pointer)
        return unless pointer && !pointer.null?

        FFI::OGR::API.OGR_G_DestroyGeometry(pointer)
      end
    end
  end
end
