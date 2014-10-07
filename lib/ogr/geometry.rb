require_relative 'envelope'

module OGR
  class Geometry
    include FFI::GDAL

    # @param type [FFI::GDAL::OGRwkbGeometryType]
    # @return [OGR::Geometry]
    def self.create(type)
      geometry_pointer = FFI::GDAL.OGR_G_CreateGeometry(type)

      new(geometry_pointer)
    end

    # @param wkt_data [String]
    # @param spatial_reference_pointer [FFI::Pointer] Optional spatial reference
    #   to assign to the new geometry.
    # @return [OGR::Geometry]
    def self.create_from_wkt(wkt_data, spatial_reference=nil)
      wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
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

      return nil if geometry_ptr_ptr.null? ||
        geometry_ptr_ptr.null? ||
        geometry_ptr_ptr.read_pointer.nil?

      new(geometry_ptr_ptr.read_pointer)
    end

    # @param gml_data [String]
    # @return [OGR::Geometry]
    def self.create_from_gml(gml_data)
      geometry_pointer = FFI::GDAL.OGR_G_CreateFromGML(gml_data)

      new(geometry_pointer)
    end

    # @param json_data [String]
    # @return [OGR::Geometry]
    def self.create_from_json(json_data)
      geometry_pointer = FFI::GDAL.OGR_G_CreateGeometryFromJson(json_data)

      new(geometry_pointer)
    end

    # @param type [FFI::GDAL::OGRwkbGeometryType]
    # @return [OGR::Geometry]
    def self.create(type)
      ogr_geometry_pointer = OGR_G_CreateGeometry(type)

      new(ogr_geometry_pointer)
    end

    # @param ogr_geometry [OGR::Geometry, FFI::Pointer]
    def initialize(geometry)
      @ogr_geometry_pointer = if geometry.is_a? OGR::Geometry
        geometry.c_pointer
      else
        geometry
      end

      close_me = -> { OGR_G_DestroyGeometry(@ogr_geometry_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @ogr_geometry_pointer
    end

    # Uses the C-API function to clone this to a new geometry.
    #
    # @return [OGR::Geometry]
    def clone
      new_geometry_ptr = OGR_G_Clone(@ogr_geometry_pointer)

      self.class.new(new_geometry_ptr)
    end

    # If this geometry is a container, this fetches the geometry at the
    #   sub_geometry_index.
    #
    # @sub_geometry_index [Fixnum]
    # @return [OGR::Geometry]
    def geometry_at(sub_geometry_index)
      build_geometry do
        OGR_G_GetGeometryRef(@ogr_geometry_pointer, sub_geometry_index)
      end
    end

    # If this geometry is a container, this adds +geometry+ to the container.
    # If this is a Polygon, +geometry+ must be a LinearRing.  If the Polygon is
    # empty, the first added +geometry+ will be the exterior ring.  Subsequent
    # geometries added will be interior rings.
    #
    # @param sub_geometry [OGR::Geometry, FFI::Pointer]
    def add(sub_geometry)
      ogr_err = OGR_G_AddGeometry(@ogr_geometry_pointer, geometry_pointer_from(sub_geometry))
    end

    # @param sub_geometry [OGR::Geometry, FFI::Pointer]
    def add_directly(sub_geometry)
      ogr_err = OGR_G_AddGeometryDirectly(@ogr_geometry_pointer, geometry_pointer_from(sub_geometry))
    end

    # @param geometry_index [Fixnum]
    # @param delete [Boolean]
    def remove(geometry_index, delete=true)
      ogr_err = OGR_G_RemoveGeometry(@ogr_geometry_pointer, geometry_index, delete)
    end

    # Clears all information from the geometry.
    def empty!
      OGR_G_Empty(@ogr_geometry_pointer)
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

    # @param new_coordinate_dimension [Fixnum]
    def coordinate_dimension=(new_coordinate_dimension)
      unless [2, 3].include?(new_coordinate_dimension)
        raise "Can't set coordinate to #{new_coordinate_dimension}.  Must be 2 or 3."
      end

      OGR_G_SetCoordinateDimension(@ogr_geometry_pointer, new_coordinate_dimension)
    end

    # @return [OGR::Envelope]
    def envelope
      case coordinate_dimension
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

      OGR::Envelope.new(envelope)
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
    def count
      OGR_G_GetGeometryCount(@ogr_geometry_pointer)
    end

    # @return [Fixnum]
    def point_count
      OGR_G_GetPointCount(@ogr_geometry_pointer)
    end

    # @param new_count [Fixnum]
    def point_count=(new_count)
      OGR_G_SetPointCount(@ogr_geometry_pointer, new_count)
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

    # @return [Array<Float, Float, Float>] [x, y] if 2d or [x, y, z] if 3d.
    def point(number)
      x_ptr = FFI::MemoryPointer.new(:double)
      y_ptr = FFI::MemoryPointer.new(:double)
      z_ptr = FFI::MemoryPointer.new(:double)

      OGR_G_GetPoint(@ogr_geometry_pointer, number, x_ptr, y_ptr, z_ptr)

      if coordinate_dimension == 2
        [x_ptr.read_double, y_ptr.read_double]
      else
        [x_ptr.read_double, y_ptr.read_double, z_ptr.read_double]
      end
    end

    def set_point(index, x, y, z=nil)
      OGR_G_SetPoint(@ogr_geometry_pointer, index, x, y, z)
    end

    # Adds a point to a LineString or Point geometry.
    #
    # @param x [Float]
    # @param y [Float]
    # @param z [Float]
    def add_point(x, y, z=nil)
      OGR_G_AddPoint(@ogr_geometry_pointer, x, y, z)
    end

    def points_array
      0.upto(point_count - 1).map do |i|
        point(i)
      end
    end

    # def points
    #   OGR_G_GetPoints(@ogr_geometry_pointer,
    #   )
    # end

    # Computes the length for this geometry.  Computes area for Curve or
    # MultiCurve objects.
    #
    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Float] 0.0 for unsupported geometry types.
    def length
      OGR_G_Length(@ogr_geometry_pointer)
    end

    # Computes area for a LinearRing, Polygon, or MultiPolygon.
    #
    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Float] 0.0 for unsupported geometry types.
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
    alias_method :==, :equals?

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

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [OGR::Geometry]
    def union_cascadded
      build_geometry { OGR_G_UnionCascaded(@ogr_geometry_pointer) }
    end

    # Creates a polygon from a set of sparse edges.  The newly created geometry
    # will contain a collection of reassembled Polygons.
    #
    # @return [OGR::Geometry] nil if the current geometry isn't a
    #   MultiLineString or if it's impossible to reassemble due to topological
    #   inconsistencies.
    def polygonize
      build_geometry { OGR_G_Polygonize(@ogr_geometry_pointer) }
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [OGR::Geometry]
    def difference(geometry)
      build_geometry do
        OGR_G_Difference(@ogr_geometry_pointer, geometry_pointer_from(geometry))
      end
    end
    alias_method :-, :difference

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [OGR::Geometry]
    def symmetric_difference(geometry)
      build_geometry do
        OGR_G_SymDifference(@ogr_geometry_pointer, geometry_pointer_from(geometry))
      end
    end

    # The shortest distance between the two geometries.
    #
    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Float] -1 if an error occurs.
    def distance(geometry)
      OGR_G_Distance(@ogr_geometry_pointer, geometry_pointer_from(geometry))
    end

    # Returns a point that's guaranteed to lie on the surface.
    #
    # @return [OGR::Geometry]
    def point_on_surface
      build_geometry { OGR_G_PointOnSurface(@ogr_geometry_pointer) }
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_ptr = OGR_G_GetSpatialReference(@ogr_geometry_pointer)
      return nil if spatial_ref_ptr.null?

      OGR::SpatialReference.new(spatial_ref_ptr)
    end

    # Assigns a spatial reference to this geometry.  Any existing spatial
    # refernce is replace, but this does not reproject the geometry.
    #
    # @param new_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    def spatial_reference=(new_spatial_ref)
      new_spatial_ref_ptr = if new_spatial_ref.is_a?(OGR::SpatialReference)
        new_spatial_ref.c_pointer
      elsif new_spatial_ref.kind_of?(FFI::Pointer)
        new_spatial_ref
      end

      OGR_G_AssignSpatialReference(@ogr_geometry_pointer, new_spatial_ref_ptr)
    end

    # Transforms the coordinates of this geometry in its current spatial
    # reference system to a new spatial reference system.  Normally this means
    # reprojecting the vectors, but it could also include datum shifts, and
    # changes of units.
    #
    # Note that this doesn't require the geometry to have an existing spatial
    # reference system.
    #
    # @param coordinate_transformation [OGR::CoordinateTransformation,
    #   FFI::Pointer]
    def transform(coordinate_transformation)
      coord_trans_ptr = if coordinate_transformation.is_a?(OGR::CoordinateTransformation)
        coordinate_transformation.c_pointer
      elsif coordinate_transformation.kind_of?(FFI::Pointer)
        coordinate_transformation
      end

      return if coord_trans_ptr.nil? or coord_trans_ptr.null?

      ogr_err = OGR_G_Transform(@ogr_geometry_pointer, coord_trans_ptr)
    end

    # Similar to +#transform+, but this only works if the geometry alread has an
    # assigned spatial reference system _and_ is transformable to the target
    # coordinate system.
    #
    # @param new_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    def transform_to(new_spatial_ref)
      new_spatial_ref_ptr = if new_spatial_ref.is_a?(OGR::SpatialReference)
        new_spatial_ref.c_pointer
      elsif new_spatial_ref.kind_of?(FFI::Pointer)
        new_spatial_ref
      end

      ogr_err = OGR_G_TransformTo(@ogr_geometry_pointer, new_spatial_ref_ptr)
    end

    # Computes and returns a new, simplified geometry.
    #
    # NOTE: this relies on GDAL having been built against GEOS.  If it wasn't,
    # this will fail.
    #
    # @param distance_tolerance [Float]
    # @return [OGR::Geometry]
    def simplify(distance_tolerance)
      build_geometry do
        OGR_G_Simplify(@ogr_geometry_pointer, distance_tolerance)
      end
    end

    # Like +#simplify+, but preserves the geometry's topology.
    #
    # @param distance_tolerance [Float]
    # @return [OGR::Geometry]
    def simplify_preserve_topology(distance_tolerance)
      build_geometry do
        OGR_G_SimplifyPreserveTopology(@ogr_geometry_pointer, distance_tolerance)
      end
    end

    # Modfiy the geometry so that it has no segments longer than +max_length+.
    #
    # @param max_length [Float]
    def segmentize!(max_length)
      OGR_G_Segmentize(@ogr_geometry_pointer, max_length)
    end

    # @return [OGR::Geometry]
    def boundary
      build_geometry { OGR_G_Boundary(@ogr_geometry_pointer) }
    end

    # @param distance [Float] The buffer distance to be applied.
    # @param quad_segments [Fixnum] The number of segments to use to approximate
    #   a 90 degree (quadrant) of curvature.
    # @return [OGR::Geometry]
    def buffer(distance, quad_segments)
      build_geometry do
        OGR_G_Buffer(@ogr_geometry_pointer, distance, quad_segments)
      end
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
      output = FFI::MemoryPointer.new(:uchar, wkb_size)
      ogr_err = OGR_G_ExportToWkb(@ogr_geometry_pointer, byte_order, output)

      output.read_bytes(wkb_size)
    end

    # TODO: should this be a class method?
    # @param wkt_data [String]
    def from_wkt(wkt_data)
      ogr_err = OGR_G_ImportFromWkt(@ogr_geometry_pointer, wkt_data)
    end

    # @return [String]
    def to_wkt
      output = FFI::MemoryPointer.new(:string)
      ogr_err = OGR_G_ExportToWkt(@ogr_geometry_pointer, output)

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

      self.class.new(geometry_pointer)
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
