# frozen_string_literal: true

module OGR
  class Geometry
    module ClassMethods
      def build_geometry
        new_geometry_ptr = yield
        return if new_geometry_ptr.nil? || new_geometry_ptr.null? || new_geometry_ptr == @c_pointer

        factory(new_geometry_ptr)
      end

      # @param geometry_ptr [OGR::Geometry, FFI::Pointer]
      # @raise [FFI::GDAL::InvalidPointer]
      def new_from_pointer(geometry_ptr)
        raise OGR::InvalidHandle, "Must initialize with a valid pointer: #{geometry_ptr}" if geometry_ptr.nil?

        @c_pointer = GDAL._pointer(geometry_ptr, autorelease: false)
      end

      def create(type)
        geometry_pointer = FFI::OGR::API.OGR_G_CreateGeometry(type)
        return if geometry_pointer.null?

        geometry_pointer.autorelease = false

        factory(geometry_pointer)
      end

      # Creates a new Geometry using the class of the geometry that the type
      # represents.
      #
      # @param geometry_handle [FFI::Pointer]
      # @return [OGR::Geometry]
      def factory(geometry_handle)
        geometry = OGR::Geometry.new(geometry_handle)

        new_pointer = geometry.c_pointer
        return if new_pointer.nil? || new_pointer.null?

        case geometry.type
        when :wkbPoint then OGR::Point.new(new_pointer)
        when :wkbPoint25D then OGR::Point25D.new(new_pointer)
        when :wkbLineString
          if /^LINEARRING/.match?(geometry.to_wkt)
            OGR::LinearRing.new(new_pointer)
          else
            OGR::LineString.new(new_pointer)
          end
        when :wkbLineString25D then OGR::LineString25D.new(new_pointer)
        when :wkbLinearRing then OGR::LinearRing.new(new_pointer)
        when :wkbPolygon then OGR::Polygon.new(new_pointer)
        when :wkbPolygon25D then OGR::Polygon25D.new(new_pointer)
        when :wkbMultiPoint then OGR::MultiPoint.new(new_pointer)
        when :wkbMultiPoint25D then OGR::MultiPoint25D.new(new_pointer)
        when :wkbMultiLineString then OGR::MultiLineString.new(new_pointer)
        when :wkbMultiLineString25D then OGR::MultiLineString25D.new(new_pointer)
        when :wkbMultiPolygon then OGR::MultiPolygon.new(new_pointer)
        when :wkbMultiPolygon25D then OGR::MultiPolygon25D.new(new_pointer)
        when :wkbGeometryCollection then OGR::GeometryCollection.new(new_pointer)
        when :wkbGeometryCollection25D then OGR::GeometryCollection25D.new(new_pointer)
        when :wkbNone then OGR::NoneGeometry.new(new_pointer)
        else
          geometry
        end
      end

      # @param wkt_data [String]
      # @param spatial_ref [OGR::SpatialReference]
      # @return [OGR::Geometry]
      def create_from_wkt(wkt_data, spatial_ref = nil)
        wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
        wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
        wkt_pointer_pointer.write_pointer(wkt_data_pointer)

        spatial_ref_pointer = (GDAL._maybe_pointer(spatial_ref) if spatial_ref)
        geometry_ptr_ptr = GDAL._buffer_out_pointer_pointer(:pointer)

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
        wkb_data_pointer.write_bytes(wkb_data)

        spatial_ref_pointer = (GDAL._maybe_pointer(spatial_ref) if spatial_ref)
        geometry_ptr_ptr = GDAL._buffer_out_pointer_pointer(:pointer)

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
        FFI::OGR::Core.OGRGeometryTypeToName(type).freeze
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
