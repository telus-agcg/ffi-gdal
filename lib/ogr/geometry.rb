require_relative 'envelope'
require_relative 'geometry_extensions'
require_relative '../gdal/options'

module OGR
  module Geometry
    module ClassMethods
      def create(type)
        geometry_pointer = FFI::OGR::API.OGR_G_CreateGeometry(type)
        return nil if geometry_pointer.null?
        geometry_pointer.autorelease = false

        factory(geometry_pointer)
      end

      # Creates a new Geometry using the class of the geometry that the type
      # represents.
      #
      # @param [OGR::Geometry, FFI::Pointer]
      # @return [OGR::Geometry]
      def factory(geometry)
        geometry =
          if geometry.is_a?(OGR::Geometry)
            geometry
          else
            OGR::UnknownGeometry.new(geometry)
          end

        new_pointer = geometry.c_pointer
        geometry.c_pointer.autorelease = true

        _ = case geometry.type
        when :wkbPoint, :wkbPoint25D
          OGR::Point.new(new_pointer)
        when :wkbLineString, :wkbLineString25D
          OGR::LineString.new(new_pointer)
        when :wkbLinearRing
          OGR::LinearRing.new(new_pointer)
        when :wkbPolygon, :wkbPolygon25D
          OGR::Polygon.new(new_pointer)
        when :wkbMultiPoint, :wkbMultiPoint25D
          OGR::MultiPoint.new(new_pointer)
        when :wkbMultiLineString, :wkbMultiLineString25D
          OGR::MultiLineString.new(new_pointer)
        when :wkbMultiPolygon, :wkbMultiPolygon25D
          OGR::MultiPolygon.new(new_pointer)
        when :wkbGeometryCollection
          OGR::GeometryCollection.new(new_pointer)
        when :wkbNone
          OGR::NoneGeometry.new(new_pointer)
        else
          geometry
        end
      end

      def base
        @base ||= nil
      end

      # @return [OGR::Geometry]
      # @param wkt_data [String]
      # @param spatial_reference [FFI::Pointer] Optional spatial reference
      #   to assign to the new geometry.
      # @return [OGR::Geometry]
      def create_from_wkt(wkt_data, spatial_reference = nil)
        wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
        wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
        wkt_pointer_pointer.write_pointer(wkt_data_pointer)

        spatial_ref_pointer =
          if spatial_reference
            GDAL._pointer(OGR::SpatialReference, spatial_reference)
          else
            nil
          end

        geometry_ptr = FFI::MemoryPointer.new(:pointer)

        geometry_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        geometry_ptr_ptr.write_pointer(geometry_ptr)

        FFI::OGR::API.OGR_G_CreateFromWkt(wkt_pointer_pointer,
          spatial_ref_pointer, geometry_ptr_ptr)

        return nil if geometry_ptr_ptr.null? ||
                      geometry_ptr_ptr.read_pointer.null?
        geometry_ptr_ptr.read_pointer.nil?

        geometry = factory(geometry_ptr_ptr.read_pointer)

        ObjectSpace.define_finalizer(geometry) { destroy! }

        geometry
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

      # @return [String]
      def type_to_name(type)
        FFI::OGR::Core.OGRGeometryTypeToName(type)
      end
    end

    extend ClassMethods

    def self.included(base)
      @base = base
      base.send(:include, GDAL::Logger)
      base.send(:include, GeometryExtensions)
    end

    #--------------------------------------------------------------------------
    # Instance Methods
    #--------------------------------------------------------------------------

    # @return [FFI::Pointer]
    def c_pointer
      @geometry_pointer
    end

    def destroy!
      return unless @geometry_pointer

      FFI::OGR::API.OGR_G_DestroyGeometry(@geometry_pointer)
      @geometry_pointer = nil
    end

    # @param value [Boolean]
    def read_only=(value)
      @read_only = value
    end

    def read_only?
      @read_only
    end

    # Clears all information from the geometry.
    #
    # @return nil
    def empty!
      FFI::OGR::API.OGR_G_Empty(@geometry_pointer)
    end

    # @return [Fixnum] 0 for points, 1 for lines, 2 for surfaces.
    def dimension
      FFI::OGR::API.OGR_G_GetDimension(@geometry_pointer)
    end

    # The dimension of coordinates in this geometry (i.e. 2d vs 3d).
    #
    # @return [Fixnum] 2 or 3, but 0 in the case of an empty point.
    def coordinate_dimension
      FFI::OGR::API.OGR_G_GetCoordinateDimension(@geometry_pointer)
    end

    # @param new_coordinate_dimension [Fixnum]
    def coordinate_dimension=(new_coordinate_dimension)
      unless [2, 3].include?(new_coordinate_dimension)
        fail "Can't set coordinate to #{new_coordinate_dimension}.  Must be 2 or 3."
      end

      FFI::OGR::API.OGR_G_SetCoordinateDimension(@geometry_pointer, new_coordinate_dimension)
    end

    # @return [OGR::Envelope]
    def envelope
      case coordinate_dimension
      when 2
        envelope = FFI::OGR::Envelope.new
        FFI::OGR::API.OGR_G_GetEnvelope(@geometry_pointer, envelope)
      when 3
        envelope = FFI::OGR::Envelope3D.new
        FFI::OGR::API.OGR_G_GetEnvelope3D(@geometry_pointer, envelope)
      when 0
        return nil
      else
        fail 'Unknown envelope dimension.'
      end

      return nil if envelope.null?

      OGR::Envelope.new(envelope)
    end

    # @return [FFI::OGR::API::WKBGeometryType]
    def type
      FFI::OGR::API.OGR_G_GetGeometryType(@geometry_pointer)
    end

    # @return [String]
    def type_to_name
      FFI::OGR::Core.OGRGeometryTypeToName(type)
    end

    # @return [String]
    def name
      FFI::OGR::API.OGR_G_GetGeometryName(@geometry_pointer)
    end

    # @return [Fixnum]
    def geometry_count
      FFI::OGR::API.OGR_G_GetGeometryCount(@geometry_pointer)
    end

    # @return [Fixnum]
    def point_count
      return 0 if empty?

      FFI::OGR::API.OGR_G_GetPointCount(@geometry_pointer)
    end

    # @return [Fixnum]
    # @todo This regularly crashes, so disabling it.
    def centroid
      fail NotImplementedError, '#centroid not yet implemented.'

      point = OGR::Geometry.create(:wkbPoint)
      FFI::OGR::API.OGR_G_Centroid(@geometry_pointer, point.c_pointer)
      return nil if point.c_pointer.null?

      point
    end

    # # Dump as WKT to the give +file+.
    #
    # @param file [String] The text file to write to.
    # @param prefix [String] The prefix to put on each line of output.
    # @return [String]
    def dump_readable(file, prefix = nil)
      FFI::OGR::API.OGR_G_DumpReadable(@geometry_pointer, file, prefix)
    end

    # Converts this geometry to a 2D geometry.
    def flatten_to_2d!
      FFI::OGR::API.OGR_G_FlattenTo2D(@geometry_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def intersects?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Intersects(@geometry_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def equals?(geometry)
      return false unless geometry.is_a? OGR::Geometry

      FFI::OGR::API.OGR_G_Equals(@geometry_pointer, geometry.c_pointer)
    end
    alias_method :==, :equals?

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def disjoint?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Disjoint(@geometry_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def touches?(geometry)
      FFI::OGR::API.OGR_G_Touches(@geometry_pointer, geometry.c_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def crosses?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Crosses(@geometry_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def within?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Within(@geometry_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def contains?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Contains(@geometry_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def overlaps?(geometry)
      geometry_ptr = GDAL._pointer(OGR::Geometry, geometry)
      FFI::OGR::API.OGR_G_Overlaps(@geometry_pointer, geometry_ptr)
    end

    # @return [Boolean]
    def empty?
      FFI::OGR::API.OGR_G_IsEmpty(@geometry_pointer)
    end

    # @return [Boolean]
    def valid?
      FFI::OGR::API.OGR_G_IsValid(@geometry_pointer)
    rescue GDAL::Error
      false
    end

    # Returns TRUE if the geometry has no anomalous geometric points, such as
    # self intersection or self tangency. The description of each instantiable
    # geometric class will include the specific conditions that cause an
    # instance of that class to be classified as not simple.
    #
    # @return [Boolean]
    def simple?
      FFI::OGR::API.OGR_G_IsSimple(@geometry_pointer)
    end

    # TRUE if the geometry has no points, otherwise FALSE.
    #
    # @return [Boolean]
    def ring?
      FFI::OGR::API.OGR_G_IsRing(@geometry_pointer)
    rescue GDAL::Error => ex
      if ex.message.include? 'IllegalArgumentException'
        false
      else
        raise
      end
    end

    # @param other_geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    # @todo This regularly crashes, so disabling it.
    def intersection(other_geometry)
      fail NotImplementedError, '#intersection not yet implemented.'

      return nil unless intersects?(other_geometry)

      build_geometry do |ptr|
        FFI::OGR::API.OGR_G_Intersection(ptr, other_geometry.c_pointer)
      end
    end

    # @param other_geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def union(other_geometry)
      build_geometry do |ptr|
        FFI::OGR::API.OGR_G_Union(ptr, other_geometry.c_pointer)
      end
    end

    # If this or any contained geometries has polygon rings that aren't closed,
    # this closes them by adding the starting point at the end.
    def close_rings!
      FFI::OGR::API.OGR_G_CloseRings(@geometry_pointer)
    end

    # Creates a polygon from a set of sparse edges.  The newly created geometry
    # will contain a collection of reassembled Polygons.
    #
    # @return [OGR::Geometry] nil if the current geometry isn't a
    #   MultiLineString or if it's impossible to reassemble due to topological
    #   inconsistencies.
    def polygonize
      build_geometry { |ptr| FFI::OGR::API.OGR_G_Polygonize(ptr) }
    end

    # @param geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def difference(geometry)
      new_geometry_ptr = FFI::OGR::API.OGR_G_Difference(@geometry_pointer, geometry.c_pointer)
      return nil if new_geometry_ptr.null?

      self.class.factory(new_geometry_ptr)
    end
    alias_method :-, :difference

    # @param geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def symmetric_difference(geometry)
      new_geometry_ptr = FFI::OGR::API.OGR_G_SymDifference(@geometry_pointer, geometry.c_pointer)
      return nil if new_geometry_ptr.null?

      self.class.factory(new_geometry_ptr)
    end

    # The shortest distance between the two geometries.
    #
    # @param geometry [OGR::Geometry]
    # @return [Float] -1 if an error occurs.
    def distance_to(geometry)
      FFI::OGR::API.OGR_G_Distance(@geometry_pointer, geometry.c_pointer)
    end

    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_ptr = FFI::OGR::API.OGR_G_GetSpatialReference(@geometry_pointer)
      return nil if spatial_ref_ptr.null?

      OGR::SpatialReference.new(spatial_ref_ptr)
    end

    # Assigns a spatial reference to this geometry.  Any existing spatial
    # reference is replaced, but this does not reproject the geometry.
    #
    # @param new_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    def spatial_reference=(new_spatial_ref)
      new_spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, new_spatial_ref)

      FFI::OGR::API.OGR_G_AssignSpatialReference(@geometry_pointer, new_spatial_ref_ptr)
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

      return if coord_trans_ptr.nil? || coord_trans_ptr.null?

      ogr_err = FFI::OGR::API.OGR_G_Transform(@geometry_pointer, coord_trans_ptr)

      ogr_err.handle_result
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

      ogr_err = FFI::OGR::API.OGR_G_TransformTo(@geometry_pointer, new_spatial_ref_ptr)

      ogr_err.handle_result
    end

    # Computes and returns a new, simplified geometry.
    #
    # @param distance_tolerance [Float]
    # @param preserve_topology [Boolean]
    # @return [OGR::Geometry]
    def simplify(distance_tolerance, preserve_topology: false)
      build_geometry do |ptr|
        if preserve_topology
          FFI::OGR::API.OGR_G_SimplifyPreserveTopology(ptr, distance_tolerance)
        else
          FFI::OGR::API.OGR_G_Simplify(ptr, distance_tolerance)
        end
      end
    end

    # Modify the geometry so that it has no segments longer than +max_length+.
    #
    # @param max_length [Float]
    def segmentize!(max_length)
      FFI::OGR::API.OGR_G_Segmentize(@geometry_pointer, max_length)
    end

    # @return [OGR::Geometry]
    def boundary
      build_geometry { |ptr| FFI::OGR::API.OGR_G_Boundary(ptr) }
    end

    # Computes the buffer of the geometry by building a new geometry that
    # contains the buffer region around the geometry that this was called on.
    #
    # @param distance [Float] The buffer distance to be applied.
    # @param quad_segments [Fixnum] The number of segments to use to approximate
    #   a 90 degree (quadrant) of curvature.
    # @return [OGR::Polygon]
    def buffer(distance, quad_segments)
      build_geometry do |ptr|
        FFI::OGR::API.OGR_G_Buffer(ptr, distance, quad_segments)
      end
    end

    # @return [OGR::Geometry]
    def convex_hull
      build_geometry { |ptr| FFI::OGR::API.OGR_G_ConvexHull(ptr) }
    end

    # @param wkb_data [String] Binary WKB data.
    # @return +true+ if successful, otherwise raises an OGR exception.
    def import_from_wkb(wkb_data)
      ogr_err = FFI::OGR::API.OGR_G_ImportFromWkb(@geometry_pointer, wkb_data, wkb_data.length)

      ogr_err.handle_result
    end

    # The exact number of bytes required to hold the WKB of this object.
    #
    # @return [Fixnum]
    def wkb_size
      FFI::OGR::API.OGR_G_WkbSize(@geometry_pointer)
    end

    # @return [String]
    def to_wkb(byte_order = :wkbXDR)
      output = FFI::MemoryPointer.new(:uchar, wkb_size)
      ogr_err = FFI::OGR::API.OGR_G_ExportToWkb(@geometry_pointer, byte_order, output)
      ogr_err.handle_result 'Unable to export geometry to WKB'

      output.read_bytes(wkb_size)
    end

    # @param wkt_data [String]
    def import_from_wkt(wkt_data)
      wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
      wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
      wkt_pointer_pointer.write_pointer(wkt_data_pointer)
      ogr_err = FFI::OGR::API.OGR_G_ImportFromWkt(@geometry_pointer, wkt_pointer_pointer)

      ogr_err.handle_result "Unable to import: #{wkt_data}"
    end

    # @return [String]
    def to_wkt
      output = FFI::MemoryPointer.new(:string)
      ogr_err = FFI::OGR::API.OGR_G_ExportToWkt(@geometry_pointer, output)
      ogr_err.handle_result

      output.read_pointer.read_string
    end

    # This geometry expressed as GML in GML basic data types.
    #
    # @param [Hash] options
    # @option options [String] :format "GML3" is really the only "option" here,
    #   since without passing this in, GDAL defaults to "GML2.1.2" (as of 1.8.0).
    # @option options [String] :gml3_linestring_element "curve" is the only
    #   option here, which only pertains a) to LineString geometries, and b)
    #   when +:format+ is set to GML3.
    # @option options [String] :gml3_longsrs Defaults to "YES", which prefixes
    #   the EPSG authority with "urn:ogc:def:crs:EPSG::".  If "NO", the EPSG
    #   authority is prefixed with "EPSG:".
    # @option options [String] :gmlid Use this to write a gml:id attribute at
    #   the top level of the geometry.
    # @return [String]
    def to_gml(**options)
      options_ptr = GDAL::Options.pointer(options)
      FFI::OGR::API.OGR_G_ExportToGMLEx(@geometry_pointer, options_ptr)
    end

    # @param altitude_mode [String] Value to write in the +altitudeMode+
    #   element.
    # @return [String]
    def to_kml(altitude_mode = nil)
      FFI::OGR::API.OGR_G_ExportToKML(@geometry_pointer, altitude_mode)
    end

    # @return [String]
    def to_geo_json
      FFI::OGR::API.OGR_G_ExportToJson(@geometry_pointer)
    end

    # Converts the current geometry to a LineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_line_string
      build_geometry { |ptr| FFI::OGR::API.OGR_G_ForceToLineString(ptr) }
    end

    # Converts the current geometry to a Polygon geometry.  The returned object
    # is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_polygon
      build_geometry { |ptr| FFI::OGR::API.OGR_G_ForceToPolygon(ptr) }
    end

    # Converts the current geometry to a MultiPoint geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_point
      build_geometry { |ptr| FFI::OGR::API.OGR_G_ForceToMultiPoint(ptr) }
    end

    # Converts the current geometry to a MultiLineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_line_string
      build_geometry { |ptr| FFI::OGR::API.OGR_G_ForceToMultiLineString(ptr) }
    end

    # Converts the current geometry to a MultiPolygon geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::MultiPolygon]
    def to_multi_polygon
      build_geometry { |ptr| FFI::OGR::API.OGR_G_ForceToMultiPolygon(ptr) }
    end

    private

    # @param geometry_ptr [OGR::Geometry, FFI::Pointer]
    def initialize_from_pointer(geometry_ptr)
      fail OGR::InvalidHandle, "Must initialize with a valid pointer: #{geometry_ptr}" if geometry_ptr.nil?
      @geometry_pointer = GDAL._pointer(OGR::Geometry, geometry_ptr)
      @read_only = false
    end

    def build_geometry
      new_geometry_ptr = yield(@geometry_pointer)
      return nil if new_geometry_ptr.nil? || new_geometry_ptr.null?

      OGR::Geometry.factory(new_geometry_ptr)
    end
  end
end

require_relative 'geometries/geometry_collection'
require_relative 'geometries/line_string'
require_relative 'geometries/linear_ring'
require_relative 'geometries/multi_line_string'
require_relative 'geometries/multi_point'
require_relative 'geometries/multi_polygon'
require_relative 'geometries/none_geometry'
require_relative 'geometries/point'
require_relative 'geometries/polygon'
require_relative 'geometries/unknown_geometry'
