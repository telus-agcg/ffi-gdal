module OGR
  class Geometry
    include FFI::GDAL

    # @param type [FFI::GDAL::OGRwkbGeometryType]
    # @return [OGR::Geometry]
    def self.create(type)
      geometry_pointer = FFI::GDAL.OGR_G_CreateGeometry(type)

      new(ogr_geometry_pointer: geometry_pointer)
    end

    # @param wkt_data [String]
    # @param spatial_reference_pointer [FFI::Pointer] Optional spatial reference
    #   to assign to the new geometry.
    # @return [OGR::Geometry]
    def self.create_from_wkt(wkt_data, spatial_reference=nil)
      wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
      return nil if wkt_data_pointer.null?

      wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
      wkt_pointer_pointer.write_pointer(wkt_data_pointer)

      spatial_ref_pointer = if spatial_reference.is_a? FFI::Pointer
        spatial_reference
      elsif spatial_reference.is_a? OGR::SpatialReference
        spatial_reference.c_pointer
      end

      geometry_ptr = FFI::MemoryPointer.new(:pointer)
      geometry_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      geometry_ptr_ptr.write_pointer(geometry_ptr)

      FFI::GDAL.OGR_G_CreateFromWkt(wkt_pointer_pointer,
        spatial_ref_pointer, geometry_ptr_ptr)

      return nil if geometry_ptr_ptr.null?
      return nil if geometry_ptr.null?

      new(ogr_geometry_pointer: geometry_ptr_ptr.read_pointer)
    end

    # @param gml_data [String]
    # @return [OGR::Geometry]
    def self.create_from_gml(gml_data)
      geometry_pointer = FFI::GDAL.OGR_G_CreateFromGML(gml_data)

      new(ogr_geometry_pointer: geometry_pointer)
    end

    # @param json_data [String]
    # @return [OGR::Geometry]
    def self.create_from_json(json_data)
      geometry_pointer = FFI::GDAL.OGR_G_CreateGeometryFromJson(json_data)

      new(ogr_geometry_pointer: geometry_pointer)
    end

    # @param ogr_geometry_pointer [FFI::Pointer]
    def initialize(ogr_geometry_pointer: nil)
      @ogr_geometry_pointer = if ogr_geometry_pointer
        ogr_geometry_pointer
      #else
        #FFI::MemoryPointer.new(:pointer)
      end
    end

    def c_pointer
      @ogr_geometry_pointer
    end

    # @return [Fixnum] 0 for points, 1 for lines, 2 for surfaces.
    def dimension
      OGR_G_GetDimension(@ogr_geometry_pointer)
    end

    # The dimension of coordinates in this geometry (i.e. 2d vs 3d).
    #
    # @return [Fixnum] 2 or 3, but 0 in the case of an empty point.
    def coordinate_dimension
      OGR_G_GetCoordinateDimension(@ogr_geometry_pointer)
    end

    # @return [FFI::GDAL::OGREnvelope, FFI::GDAL::OGREnvelope3D]
    def envelope
      case dimension
      when 2
        envelope = FFI::GDAL::OGREnvelope.new
        OGR_G_GetEnvelope(@ogr_geometry_pointer, envelope)
      when 3
        envelope = FFI::GDAL::OGREnvelope3D.new
        OGR_G_GetEnvelope3D(@ogr_geometry_pointer, envelope)
      else
        raise 'Unknown envelope dimension.'
      end

      return nil if envelope.null?

      envelope
    end

    # @return [FFI::GDAL::OGRwkbGeometryType]
    def type
      OGR_G_GetGeometryType(@ogr_geometry_pointer)
    end

    # @return [String]
    def name
      OGR_G_GetGeometryName(@ogr_geometry_pointer)
    end

    # @return [Fixnum]
    def geometry_count
      OGR_G_GetGeometryCount(@ogr_geometry_pointer)
    end

    # @return [Fixnum]
    def point_count
      OGR_G_GetPointCount(@ogr_geometry_pointer)
    end

    # @return [Float]
    def x(point_number)
      OGR_G_GetX(@ogr_geometry_pointer, point_number)
    end

    # @return [Float]
    def y(point_number)
      OGR_G_GetY(@ogr_geometry_pointer, point_number)
    end

    # @return [Float]
    def z(point_number)
      OGR_G_GetZ(@ogr_geometry_pointer, point_number)
    end

    # @return [Array<Float, Float, Float>] x, y, z
    def point(number)
      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double)

      OGR_G_GetPoint(@ogr_geometry_pointer, number, x_ptr, y_ptr, z_ptr)

      [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
    end

    # def points
    #   OGR_G_GetPoints(@ogr_geometry_pointer,
    #   )
    # end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Float]
    def length
      OGR_G_Length(@ogr_geometry_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Float]
    def area
      OGR_G_Area(@ogr_geometry_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Fixnum]
    def centroid(point_geometry)
      OGR_G_Centroid(@ogr_geometry_pointer, geometry_pointer_from(point_geometry))
    end

    # Dump as WKT to the give +file+.
    #
    # @param file [String] The text file to write to.
    # @param prefix [String] The prefix to put on each line of output.
    # @return [String]
    def dump_readable(file, prefix=nil)
      OGR_G_DumpReadable(@ogr_geometry_pointer, file, prefix)
    end

    # Converts this geometry to a 2D geometry.
    def flatten_to_2d!
      OGR_G_FlattenTo2D(@ogr_geometry_pointer)
    end

    # If this or any contained geometries has polygon rings that aren't closed,
    # this closes them by adding the starting point at the end.
    def close_rings!
      OGR_G_CloseRings(@ogr_geometry_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def intersects?(geometry)
      OGR_G_Intersects(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def equals?(geometry)
      OGR_G_Equals(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def disjoint?(geometry)
      OGR_G_Disjoint(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def touches?(geometry)
      OGR_G_Touches(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def crosses?(geometry)
      OGR_G_Crosses(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def within?(geometry)
      OGR_G_Within(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def contains?(geometry)
      OGR_G_Contains(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def overlaps?(geometry)
      OGR_G_Overlaps(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # @return [Boolean]
    def empty?
      OGR_G_IsEmpty(@ogr_geometry_pointer)
    end

    # @return [Boolean]
    def valid?
      OGR_G_IsValid(@ogr_geometry_pointer)
    end

    # @return [Boolean]
    def simple?
      OGR_G_IsSimple(@ogr_geometry_pointer)
    end

    # @return [Boolean]
    def ring?
      OGR_G_IsRing(@ogr_geometry_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [OGR::Geometry]
    def intersection(geometry)
      build_geometry do
        OGR_G_Intersection(@ogr_geometry_pointer, geometry_pointer_from(geometry))
      end
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [OGR::Geometry]
    def union(geometry)
      build_geometry do
        OGR_G_Union(@ogr_geometry_pointer, geometry_pointer_from(geometry))
      end
    end

    # @return [OGR::Geometry]
    def polygonize
      build_geometry { OGR_G_Polygonize(@ogr_geometry_pointer) }
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [OGR::Geometry]
    def -(geometry)
      build_geometry do
        OGR_G_Difference(@ogr_geometry_pointer, geometry_pointer_from(geometry))
      end
    end
    alias_method :difference, :-

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Float]
    def distance(geometry)
      OGR_G_Distance(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # @return [OGR::Geometry]
    def point_on_surface
      build_geometry { OGR_G_PointOnSurface(@ogr_geometry_pointer) }
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_ptr = OGR_G_GetSpatialReference(@ogr_geometry_pointer)
      return nil if spatial_ref_ptr.null?

      OGR::SpatialReference.new(ogr_spatial_ref_pointer: spatial_ref_ptr)
    end

    # @return [OGR::Geometry]
    def boundary
      build_geometry { OGR_G_Boundary(@ogr_geometry_pointer) }
    end

    # @return [OGR::Geometry]
    def convex_hull
      build_geometry { OGR_G_ConvexHull(@ogr_geometry_pointer) }
    end

    # TODO: should this be a class method?
    # @param wkb_data [String] Binary WKB data.
    def from_wkb(wkb_data)
      ogr_err = OGR_G_ImportFromWkb(@ogr_geometry_pointer, wkb_data, wkb_data.length)
    end

    # The exact number of bytes required to hold the WKB of this object.
    #
    # @return [Fixnum]
    def wkb_size
      OGR_G_WkbSize(@ogr_geometry_pointer)
    end

    # @return [String]
    def to_wkb(byte_order=:wkbXDR)
      output = FFI::MemoryPointer.new(:pointer)
      OGR_G_ExportToWkb(@ogr_geometry_pointer, byte_order, output)

      output.read_string
    end

    # TODO: should this be a class method?
    # @param wkt_data [String]
    def from_wkt(wkt_data)
      ogr_err = OGR_G_ImportFromWkt(@ogr_geometry_pointer, wkt_data)
    end

    # @return [String]
    def to_wkt
      output = FFI::MemoryPointer.new(:string)
      OGR_G_ExportToWkt(@ogr_geometry_pointer, output)

      output.read_pointer.read_string
    end

    # This geometry expressed as GML in GML basic data types.
    #
    # @return [String]
    def to_gml
      OGR_G_ExportToGML(@ogr_geometry_pointer)
    end

    # @param altitude_mode [String] Value to write in the +altitudeMode+
    #   element.
    # @return [String]
    def to_kml(altitude_mode=nil)
      OGR_G_ExportToKML(@ogr_geometry_pointer, altitude_mode)
    end

    # @return [String]
    def to_json
      OGR_G_ExportToJson(@ogr_geometry_pointer)
    end

    # Converts the current geometry to a Polygon geometry.  The returned object
    # is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_polygon
      build_geometry { OGR_G_ForceToPolygon(@ogr_geometry_pointer) }
    end

    # Converts the current geometry to a LineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_line_string
      build_geometry { OGR_G_ForceToLineString(@ogr_geometry_pointer) }
    end

    # Converts the current geometry to a MultiPolygon geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_polygon
      build_geometry { OGR_G_ForceToMultiPolygon(@ogr_geometry_pointer) }
    end

    # Converts the current geometry to a MultiPoint geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_point
      build_geometry { OGR_G_ForceToMultiPoint(@ogr_geometry_pointer) }
    end

    # Converts the current geometry to a MultiLineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_line_string
      build_geometry { OGR_G_ForceToMultiLineString(@ogr_geometry_pointer) }
    end

    private

    def build_geometry
      geometry_pointer = yield
      return nil if geometry_pointer.null?

      self.class.new(ogr_geometry_pointer: geometry_pointer)
    end

    def geometry_pointer_from(geometry)
      if geometry.is_a? OGR::Geometry
        geometry.c_pointer
      elsif geometry.kind_of? FFI::Pointer
        geometry
      end
    end
  end
end
