require_relative 'envelope'
require_relative 'geometry_extensions'

module OGR
  class Geometry
    include GDAL::Logger
    include GeometryExtensions

    # @param type [FFI::GDAL::OGRwkbGeometryType]
    # @return [OGR::Geometry]
    def self.create(type)
      geometry_pointer = FFI::GDAL.OGR_G_CreateGeometry(type)
      return nil if geometry_pointer.null?
      geometry_pointer.autorelease = false

      _to_geometry_type(geometry_pointer)
    end

    def self._to_geometry_type(geometry)
      geometry = if geometry.kind_of?(OGR::Geometry)
        geometry
      else
        new(geometry)
      end
      case geometry.name
      when 'POINT' then OGR::Point.new(geometry.c_pointer)
      when 'LINESTRING' then OGR::LineString.new(geometry.c_pointer)
      when 'LINEARRING' then OGR::LinearRing.new(geometry.c_pointer)
      when 'POLYGON' then OGR::Polygon.new(geometry.c_pointer)
      when 'MULTIPOINT' then OGR::MultiPoint.new(geometry.c_pointer)
      when 'MULTILINESTRING' then OGR::MultiLineString.new(geometry.c_pointer)
      when 'MULTIPOLYGON' then OGR::MultiPolygon.new(geometry.c_pointer)
      else
        geometry
      end
    end

    # @param wkt_data [String]
    # @param spatial_reference [FFI::Pointer] Optional spatial reference
    #   to assign to the new geometry.
    # @return [OGR::Geometry]
    def self.create_from_wkt(wkt_data, spatial_reference=nil)
      wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
      wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
      wkt_pointer_pointer.write_pointer(wkt_data_pointer)

      spatial_ref_pointer = if spatial_reference
        GDAL._pointer(OGR::SpatialReference, spatial_reference)
      else
        FFI::MemoryPointer.new(:pointer)
      end

      geometry_ptr = FFI::MemoryPointer.new(:pointer)
      geometry_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      geometry_ptr_ptr.write_pointer(geometry_ptr)

      FFI::GDAL.OGR_G_CreateFromWkt(wkt_pointer_pointer,
        spatial_ref_pointer, geometry_ptr_ptr)

      return nil if geometry_ptr_ptr.null? ||
        geometry_ptr_ptr.read_pointer.null?
        geometry_ptr_ptr.read_pointer.nil?

      # Not assigning here makes tests crash when using a #let.
      geometry = _to_geometry_type(geometry_ptr_ptr.read_pointer)
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

    # @return [String]
    def self.type_to_name(type)
      FFI::GDAL.OGRGeometryTypeToName(type)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    def initialize(geometry)
      @geometry_pointer = GDAL._pointer(OGR::Geometry, geometry)
      @geometry_pointer.autorelease = false

      close_me = -> {
        puts "CLOSING!"
        if @geometry_pointer && !@geometry_pointer.null?
          FFI::GDAL.OGR_G_DestroyGeometry(@geometry_pointer)
        end
      }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @geometry_pointer
    end

    # If this geometry is a container, this adds +geometry+ to the container.
    # If this is a Polygon, +geometry+ must be a LinearRing.  If the Polygon is
    # empty, the first added +geometry+ will be the exterior ring.  Subsequent
    # geometries added will be interior rings.
    #
    # @param sub_geometry [OGR::Geometry, FFI::Pointer]
    def add_geometry(sub_geometry)
      ogr_err = FFI::GDAL.OGR_G_AddGeometry(@geometry_pointer, pointer_from(sub_geometry))
    end

    # @param sub_geometry [OGR::Geometry, FFI::Pointer]
    def add_directly(sub_geometry)
      ogr_err = FFI::GDAL.OGR_G_AddGeometryDirectly(@geometry_pointer, pointer_from(sub_geometry))
    end

    # @param geometry_index [Fixnum]
    # @param delete [Boolean]
    def remove!(geometry_index, delete=true)
      ogr_err = FFI::GDAL.OGR_G_RemoveGeometry(@geometry_pointer, geometry_index, delete)
    end

    # Clears all information from the geometry.
    def empty!
      FFI::GDAL.OGR_G_Empty(@geometry_pointer)
    end

    # @return [Fixnum] 0 for points, 1 for lines, 2 for surfaces.
    def dimension
      FFI::GDAL.OGR_G_GetDimension(@geometry_pointer)
    end

    # The dimension of coordinates in this geometry (i.e. 2d vs 3d).
    #
    # @return [Fixnum] 2 or 3, but 0 in the case of an empty point.
    def coordinate_dimension
      FFI::GDAL.OGR_G_GetCoordinateDimension(@geometry_pointer)
    end

    # @param new_coordinate_dimension [Fixnum]
    def coordinate_dimension=(new_coordinate_dimension)
      unless [2, 3].include?(new_coordinate_dimension)
        raise "Can't set coordinate to #{new_coordinate_dimension}.  Must be 2 or 3."
      end

      FFI::GDAL.OGR_G_SetCoordinateDimension(@geometry_pointer, new_coordinate_dimension)
    end

    # @return [OGR::Envelope]
    def envelope
      return @envelope if @envelope

      case coordinate_dimension
      when 2
        envelope = FFI::GDAL::OGREnvelope.new
        FFI::GDAL.OGR_G_GetEnvelope(@geometry_pointer, envelope)
      when 3
        envelope = FFI::GDAL::OGREnvelope3D.new
        FFI::GDAL.OGR_G_GetEnvelope3D(@geometry_pointer, envelope)
      when 0
        return nil
      else
        raise 'Unknown envelope dimension.'
      end

      return nil if envelope.null?

      @envelope = OGR::Envelope.new(envelope)
    end

    # @return [FFI::GDAL::OGRwkbGeometryType]
    def type
      FFI::GDAL.OGR_G_GetGeometryType(@geometry_pointer)
    end

    # @return [String]
    def type_to_name
      FFI::GDAL.OGRGeometryTypeToName(type)
    end

    # @return [String]
    def name
      FFI::GDAL.OGR_G_GetGeometryName(@geometry_pointer)
    end

    # @return [Fixnum]
    def count
      FFI::GDAL.OGR_G_GetGeometryCount(@geometry_pointer)
    end

    # @return [Fixnum]
    def point_count
      return 0 if empty?

      FFI::GDAL.OGR_G_GetPointCount(@geometry_pointer)
    end

    # @param point_geometry [OGR::Geometry, FFI::Pointer]
    # @return [Fixnum]
    # def centroid
    #   point = OGR::Geometry.create(:wkbPoint)
    #   FFI::GDAL.OGR_G_Centroid(@geometry_pointer, point.c_pointer)
    #   return nil if point.c_pointer.null?
    #
    #   point
    # end
    #
    # # Dump as WKT to the give +file+.
    #
    # @param file [String] The text file to write to.
    # @param prefix [String] The prefix to put on each line of output.
    # @return [String]
    def dump_readable(file, prefix=nil)
      FFI::GDAL.OGR_G_DumpReadable(@geometry_pointer, file, prefix)
    end

    # Converts this geometry to a 2D geometry.
    def flatten_to_2d!
      FFI::GDAL.OGR_G_FlattenTo2D(@geometry_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def intersects?(geometry)
      FFI::GDAL.OGR_G_Intersects(@geometry_pointer, pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def equals?(geometry)
      FFI::GDAL.OGR_G_Equals(@geometry_pointer, pointer_from(geometry))
    end
    alias_method :==, :equals?

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def disjoint?(geometry)
      FFI::GDAL.OGR_G_Disjoint(@geometry_pointer, pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def touches?(geometry)
      FFI::GDAL.OGR_G_Touches(@geometry_pointer, geometry.c_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def crosses?(geometry)
      FFI::GDAL.OGR_G_Crosses(@geometry_pointer, pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def within?(geometry)
      FFI::GDAL.OGR_G_Within(@geometry_pointer, pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def contains?(geometry)
      FFI::GDAL.OGR_G_Contains(@geometry_pointer, pointer_from(geometry))
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def overlaps?(geometry)
      FFI::GDAL.OGR_G_Overlaps(@geometry_pointer, pointer_from(geometry))
    end

    # @return [Boolean]
    def empty?
      FFI::GDAL.OGR_G_IsEmpty(@geometry_pointer)
    end

    # @return [Boolean]
    def valid?
      FFI::GDAL.OGR_G_IsValid(@geometry_pointer)
    end

    # Returns TRUE if the geometry has no anomalous geometric points, such as
    # self intersection or self tangency. The description of each instantiable
    # geometric class will include the specific conditions that cause an
    # instance of that class to be classified as not simple.
    #
    # @return [Boolean]
    def simple?
      FFI::GDAL.OGR_G_IsSimple(@geometry_pointer)
    end

    # TRUE if the geometry has no points, otherwise FALSE.
    #
    # @return [Boolean]
    def ring?
      FFI::GDAL.OGR_G_IsRing(@geometry_pointer)
    end

    # @param other_geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    # def intersection(other_geometry)
    #   return nil unless intersects?(other_geometry)
    #
    #   build_geometry do |ptr|
    #     FFI::GDAL.OGR_G_Intersection(ptr, other_geometry.c_pointer)
    #   end
    # end

    # @param other_geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def union(other_geometry)
      build_geometry do |ptr|
        FFI::GDAL.OGR_G_Union(ptr, other_geometry.c_pointer)
      end
    end

    # If this or any contained geometries has polygon rings that aren't closed,
    # this closes them by adding the starting point at the end.
    def close_rings!
      FFI::GDAL.OGR_G_CloseRings(@geometry_pointer)
    end

    # Creates a polygon from a set of sparse edges.  The newly created geometry
    # will contain a collection of reassembled Polygons.
    #
    # @return [OGR::Geometry] nil if the current geometry isn't a
    #   MultiLineString or if it's impossible to reassemble due to topological
    #   inconsistencies.
    def polygonize
      build_geometry { |ptr| FFI::GDAL.OGR_G_Polygonize(ptr) }
    end

    # @param geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def difference(geometry)
      new_geometry_ptr = FFI::GDAL.OGR_G_Difference(@geometry_pointer, geometry.c_pointer)
      return nil if new_geometry_ptr.null?

      self.class._to_geometry_type(new_geometry_ptr)
    end
    alias_method :-, :difference

    # @param geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def symmetric_difference(geometry)
      new_geometry_ptr = FFI::GDAL.OGR_G_SymDifference(@geometry_pointer, geometry.c_pointer)
      return nil if new_geometry_ptr.null?

      self.class._to_geometry_type(new_geometry_ptr)
    end

    # The shortest distance between the two geometries.
    #
    # @param geometry [OGR::Geometry]
    # @return [Float] -1 if an error occurs.
    def distance_to(geometry)
      FFI::GDAL.OGR_G_Distance(@geometry_pointer, geometry.c_pointer)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      return @spatial_reference if @spatial_reference

      spatial_ref_ptr = FFI::GDAL.OGR_G_GetSpatialReference(@geometry_pointer)
      return nil if spatial_ref_ptr.null?

      @spatial_reference = OGR::SpatialReference.new(spatial_ref_ptr)
    end

    # Assigns a spatial reference to this geometry.  Any existing spatial
    # refernce is replace, but this does not reproject the geometry.
    #
    # @param new_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    def spatial_reference=(new_spatial_ref)
      new_spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, new_spatial_ref)

      FFI::GDAL.OGR_G_AssignSpatialReference(@geometry_pointer, new_spatial_ref_ptr)
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
    # @return [Boolean]
    def transform!(coordinate_transformation)
      coord_trans_ptr = GDAL._pointer(OGR::CoordinateTransformation,
        coordinate_transformation)

      return if coord_trans_ptr.nil? or coord_trans_ptr.null?

      ogr_err = FFI::GDAL.OGR_G_Transform(@geometry_pointer, coord_trans_ptr)
    end

    # Similar to +#transform+, but this only works if the geometry already has an
    # assigned spatial reference system _and_ is transformable to the target
    # coordinate system.
    #
    # @param new_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    # @return [Boolean]
    def transform_to!(new_spatial_ref)
      new_spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, new_spatial_ref)
      return nil if new_spatial_ref_ptr.null?

      ogr_err = FFI::GDAL.OGR_G_TransformTo(@geometry_pointer, new_spatial_ref_ptr)
    end

    # Computes and returns a new, simplified geometry.
    #
    # NOTE: this relies on GDAL having been built against GEOS.  If it wasn't,
    # this will fail.
    #
    # @param distance_tolerance [Float]
    # @return [OGR::Geometry]
    def simplify(distance_tolerance)
      build_geometry do |ptr|
        FFI::GDAL.OGR_G_Simplify(ptr, distance_tolerance)
      end
    end

    # Like +#simplify+, but preserves the geometry's topology.
    #
    # @param distance_tolerance [Float]
    # @return [OGR::Geometry]
    def simplify_preserve_topology(distance_tolerance)
      build_geometry do |ptr|
        FFI::GDAL.OGR_G_SimplifyPreserveTopology(ptr, distance_tolerance)
      end
    end

    # Modify the geometry so that it has no segments longer than +max_length+.
    #
    # @param max_length [Float]
    def segmentize!(max_length)
      FFI::GDAL.OGR_G_Segmentize(@geometry_pointer, max_length)
    end

    # @return [OGR::Geometry]
    def boundary
      build_geometry { |ptr| FFI::GDAL.OGR_G_Boundary(ptr) }
    end

    # @param distance [Float] The buffer distance to be applied.
    # @param quad_segments [Fixnum] The number of segments to use to approximate
    #   a 90 degree (quadrant) of curvature.
    # @return [OGR::Geometry]
    def buffer(distance, quad_segments)
      build_geometry do |ptr|
        FFI::GDAL.OGR_G_Buffer(ptr, distance, quad_segments)
      end
    end

    # @return [OGR::Geometry]
    def convex_hull
      build_geometry { |ptr| FFI::GDAL.OGR_G_ConvexHull(ptr) }
    end

    # TODO: should this be a class method?
    # @param wkb_data [String] Binary WKB data.
    def from_wkb(wkb_data)
      ogr_err = FFI::GDAL.OGR_G_ImportFromWkb(@geometry_pointer, wkb_data, wkb_data.length)
    end

    # The exact number of bytes required to hold the WKB of this object.
    #
    # @return [Fixnum]
    def wkb_size
      FFI::GDAL.OGR_G_WkbSize(@geometry_pointer)
    end

    # @return [String]
    def to_wkb(byte_order=:wkbXDR)
      output = FFI::MemoryPointer.new(:uchar, wkb_size)
      ogr_err = FFI::GDAL.OGR_G_ExportToWkb(@geometry_pointer, byte_order, output)

      output.read_bytes(wkb_size)
    end

    # TODO: should this be a class method?
    # @param wkt_data [String]
    def from_wkt(wkt_data)
      wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
      wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
      wkt_pointer_pointer.write_pointer(wkt_data_pointer)

      ogr_err = FFI::GDAL.OGR_G_ImportFromWkt(@geometry_pointer, wkt_pointer_pointer)
    end

    # @return [String]
    def to_wkt
      output = FFI::MemoryPointer.new(:string)
      ogr_err = FFI::GDAL.OGR_G_ExportToWkt(@geometry_pointer, output)

      output.read_pointer.read_string
    end

    # This geometry expressed as GML in GML basic data types.
    #
    # @return [String]
    def to_gml
      FFI::GDAL.OGR_G_ExportToGML(@geometry_pointer)
    end

    # @param altitude_mode [String] Value to write in the +altitudeMode+
    #   element.
    # @return [String]
    def to_kml(altitude_mode=nil)
      FFI::GDAL.OGR_G_ExportToKML(@geometry_pointer, altitude_mode)
    end

    # @return [String]
    def to_geo_json
      FFI::GDAL.OGR_G_ExportToJson(@geometry_pointer)
    end

    # Converts the current geometry to a Polygon geometry.  The returned object
    # is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_polygon
      build_geometry { |ptr| FFI::GDAL.OGR_G_ForceToPolygon(ptr) }
    end

    # Converts the current geometry to a LineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_line_string
      build_geometry { |ptr| FFI::GDAL.OGR_G_ForceToLineString(ptr) }
    end

    # Converts the current geometry to a MultiPolygon geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_polygon
      build_geometry { |ptr| FFI::GDAL.OGR_G_ForceToMultiPolygon(ptr) }
    end

    # Converts the current geometry to a MultiPoint geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_point
      build_geometry { |ptr| FFI::GDAL.OGR_G_ForceToMultiPoint(ptr) }
    end

    # Converts the current geometry to a MultiLineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_line_string
      build_geometry { |ptr| FFI::GDAL.OGR_G_ForceToMultiLineString(ptr) }
    end

    private

    def build_geometry
      geometry_ptr = yield(@geometry_pointer)
      return nil if geometry_ptr.null?

      if geometry_ptr == @geometry_pointer
        log 'Newly created geometry and current geometry are the same.'
      end

      self.class._to_geometry_type(geometry_ptr)
    end

    def pointer_from(geometry)
      if geometry.is_a? OGR::Geometry
        geometry.c_pointer
      elsif geometry.kind_of? FFI::Pointer
        geometry
      end
    end

    def object_from(geometry)
      if geometry.is_a? OGR::Geometry
        geometry
      elsif geometry.kind_of? FFI::Pointer
        geometry.c_pointer
      end
    end
  end
end
