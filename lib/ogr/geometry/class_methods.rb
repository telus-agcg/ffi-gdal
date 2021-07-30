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

      # @param type [FFI::OGR::Core::WKBGeometryType]
      # @return [FFI::Pointer]
      # @raise [FFI::GDAL::InvalidPointer]
      def create(type)
        geometry_pointer = FFI::OGR::API.OGR_G_CreateGeometry(type)
        raise FFI::GDAL::InvalidPointer, "Unable to instantiate Geometry from type '#{type}'" if geometry_pointer.null?

        geometry_pointer.autorelease = false

        geometry_pointer
      end

      # Creates a new Geometry using the class of the geometry that the type
      # represents.
      #
      # @param c_pointer [FFI::Pointer]
      # @return [OGR::Geometry]
      # @raise [RuntimeError]
      # rubocop: disable Metrics/CyclomaticComplexity
      def factory(c_pointer)
        geom_type = FFI::OGR::API.OGR_G_GetGeometryType(c_pointer)

        klass = case geom_type
                when :wkbPoint then OGR::Point
                when :wkbPoint25D then OGR::Point25D
                when :wkbLineString25D then OGR::LineString25D
                when :wkbLinearRing then OGR::LinearRing
                when :wkbPolygon then OGR::Polygon
                when :wkbPolygon25D then OGR::Polygon25D
                when :wkbMultiPoint then OGR::MultiPoint
                when :wkbMultiPoint25D then OGR::MultiPoint25D
                when :wkbMultiLineString then OGR::MultiLineString
                when :wkbMultiLineString25D then OGR::MultiLineString25D
                when :wkbMultiPolygon then OGR::MultiPolygon
                when :wkbMultiPolygon25D then OGR::MultiPolygon25D
                when :wkbGeometryCollection then OGR::GeometryCollection
                when :wkbGeometryCollection25D then OGR::GeometryCollection25D
                when :wkbLineString
                  # Putting this down low in the logic gate due to the performance hit
                  # on converting to WKT.
                  if /^LINEARRING/.match?(to_wkt(c_pointer))
                    OGR::LinearRing
                  else
                    OGR::LineString
                  end
                when :wkbCircularString then OGR::CircularString
                when :wkbCompoundCurve then OGR::CompoundCurve
                when :wkbCurvePolygon then OGR::CurvePolygon
                when :wkbMultiCurve then OGR::MultiCurve
                when :wkbNone then return OGR::NoneGeometry.new(c_pointer)
                when :wkbUnknown then return OGR::UnknownGeometry.new(c_pointer)
                else
                  raise "Unknown geometry type '#{geom_type}'"
                end

        klass.new(c_pointer: c_pointer)
      end
      # rubocop: enable Metrics/CyclomaticComplexity

      # @param wkt_data [String]
      # @param spatial_ref [OGR::SpatialReference]
      # @return [OGR::Geometry]
      def create_from_wkt(wkt_data, spatial_ref = nil)
        wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
        wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
        wkt_pointer_pointer.write_pointer(wkt_data_pointer)

        spatial_ref_pointer = (GDAL._maybe_pointer(spatial_ref) if spatial_ref)
        geometry_ptr_ptr = GDAL._pointer_pointer(:pointer)

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

      # @return [String]
      # @raise [OGR::Failure]
      def to_wkt(c_pointer)
        GDAL._cpl_read_and_free_string do |output_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to WKT') do
            FFI::OGR::API.OGR_G_ExportToWkt(c_pointer, output_ptr)
          end
        end
      end
    end
  end
end
