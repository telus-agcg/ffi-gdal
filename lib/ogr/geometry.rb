# frozen_string_literal: true

require_relative '../ogr'
require_relative '../gdal'
require_relative 'geometry/class_methods'

module OGR
  class Geometry
    extend ClassMethods

    # @return [FFI::Pointer]
    attr_reader :c_pointer

    # OGR::Geometry is really an abstract class, so this shouldn't really need
    # to be called directly.
    #
    # @param geometry_pointer [FFI::Pointer]
    # @param spatial_reference [OGR::SpatialReference, nil]
    def initialize(c_pointer, spatial_reference = nil)
      @c_pointer = c_pointer

      self.spatial_reference = spatial_reference if spatial_reference
    end

    def destroy!
      self.class.release(@c_pointer)

      @c_pointer = nil
    end

    # @return [OGR::Geometry]
    def clone
      new_geometry_ptr = FFI::OGR::API.OGR_G_Clone(@c_pointer)

      OGR::Geometry.factory(new_geometry_ptr)
    end

    # Clears all information from the geometry.
    #
    # @return nil
    def empty!
      FFI::OGR::API.OGR_G_Empty(@c_pointer)
    end

    # @return [Integer] 0 for points, 1 for lines, 2 for surfaces.
    def dimension
      FFI::OGR::API.OGR_G_GetDimension(@c_pointer)
    end

    # The dimension of coordinates in this geometry (i.e. 2d vs 3d).
    #
    # @return [Integer] 2 or 3, but 0 in the case of an empty point.
    def coordinate_dimension
      FFI::OGR::API.OGR_G_GetCoordinateDimension(@c_pointer)
    end

    # @param new_coordinate_dimension [Integer]
    def coordinate_dimension=(new_coordinate_dimension)
      unless [2, 3].include?(new_coordinate_dimension)
        raise "Can't set coordinate to #{new_coordinate_dimension}.  Must be 2 or 3."
      end

      FFI::OGR::API.OGR_G_SetCoordinateDimension(@c_pointer, new_coordinate_dimension)
    end

    # @return [OGR::Envelope]
    def envelope
      raise 'child class must include `OGR::HasTwoCoordinateDimensions` or ' \
        '`OGR::HasThreeCoordinateDimensions`'
    end

    # @return [FFI::OGR::API::WKBGeometryType]
    def type
      FFI::OGR::API.OGR_G_GetGeometryType(@c_pointer)
    end

    # @return [String]
    def type_to_name
      self.class.type_to_name(type)
    end

    # @return [String]
    def name
      # The returned pointer is to a static internal string and should not be modified or freed.
      name, ptr = FFI::OGR::API.OGR_G_GetGeometryName(@c_pointer)
      ptr.autorelease = false

      name
    end

    # @return [Integer]
    def centroid
      raise 'child class must include `OGR::HasTwoCoordinateDimensions` or ' \
        '`OGR::HasThreeCoordinateDimensions`'
    end

    # Dump as WKT to the given +file_path+; dumps to STDOUT if none is given.
    #
    # @param file_path [String] The text file to write to.
    # @param prefix [String] The prefix to put on each line of output.
    def dump_readable(file_path = nil, prefix: nil)
      file_ptr = file_path ? FFI::CPL::Conv.CPLOpenShared(file_path, 'w', false) : nil
      FFI::OGR::API.OGR_G_DumpReadable(@c_pointer, file_ptr, prefix)
      FFI::CPL::Conv.CPLCloseShared(file_ptr) if file_ptr
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    # @raise [FFI::GDAL::InvalidPointer]
    def intersects?(geometry)
      geometry_ptr = GDAL._pointer(geometry)
      FFI::OGR::API.OGR_G_Intersects(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def equals?(geometry)
      return false unless geometry.is_a? OGR::Geometry

      FFI::OGR::API.OGR_G_Equals(@c_pointer, geometry.c_pointer)
    end
    alias == equals?

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    # @raise [FFI::GDAL::InvalidPointer]
    def disjoint?(geometry)
      geometry_ptr = GDAL._pointer(geometry)
      FFI::OGR::API.OGR_G_Disjoint(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    def touches?(geometry)
      FFI::OGR::API.OGR_G_Touches(@c_pointer, geometry.c_pointer)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    # @raise [FFI::GDAL::InvalidPointer]
    def crosses?(geometry)
      geometry_ptr = GDAL._pointer(geometry)
      FFI::OGR::API.OGR_G_Crosses(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    # @raise [FFI::GDAL::InvalidPointer]
    def within?(geometry)
      geometry_ptr = GDAL._pointer(geometry)
      FFI::OGR::API.OGR_G_Within(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    # @raise [FFI::GDAL::InvalidPointer]
    def contains?(geometry)
      geometry_ptr = GDAL._pointer(geometry)
      FFI::OGR::API.OGR_G_Contains(@c_pointer, geometry_ptr)
    end

    # @param geometry [OGR::Geometry, FFI::Pointer]
    # @return [Boolean]
    # @raise [FFI::GDAL::InvalidPointer]
    def overlaps?(geometry)
      geometry_ptr = GDAL._pointer(geometry)
      FFI::OGR::API.OGR_G_Overlaps(@c_pointer, geometry_ptr)
    end

    # @return [Boolean]
    def empty?
      FFI::OGR::API.OGR_G_IsEmpty(@c_pointer)
    end

    # @return [Boolean]
    def valid?
      FFI::OGR::API.OGR_G_IsValid(@c_pointer)
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
      FFI::OGR::API.OGR_G_IsSimple(@c_pointer)
    end

    # TRUE if the geometry has no points, otherwise FALSE.
    #
    # @return [Boolean]
    def ring?
      FFI::OGR::API.OGR_G_IsRing(@c_pointer)
    rescue GDAL::Error => e
      return false if e.message.include? 'IllegalArgumentException'

      raise
    end

    # @param other_geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def intersection(other_geometry)
      OGR::Geometry.build_geometry do
        FFI::OGR::API.OGR_G_Intersection(@c_pointer, other_geometry.c_pointer)
      end
    end

    # @param other_geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def union(other_geometry)
      OGR::Geometry.build_geometry do
        FFI::OGR::API.OGR_G_Union(@c_pointer, other_geometry.c_pointer)
      end
    end

    # If this or any contained geometries has polygon rings that aren't closed,
    # this closes them by adding the starting point at the end.
    def close_rings!
      FFI::OGR::API.OGR_G_CloseRings(@c_pointer)
    end

    # @param geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def difference(geometry)
      new_geometry_ptr = FFI::OGR::API.OGR_G_Difference(@c_pointer, geometry.c_pointer)
      return if new_geometry_ptr.null?

      OGR::Geometry.factory(new_geometry_ptr)
    end
    alias - difference

    # @param geometry [OGR::Geometry]
    # @return [OGR::Geometry]
    def symmetric_difference(geometry)
      new_geometry_ptr = FFI::OGR::API.OGR_G_SymDifference(@c_pointer, geometry.c_pointer)
      return if new_geometry_ptr.null?

      OGR::Geometry.factory(new_geometry_ptr)
    end

    # The shortest distance between the two geometries.
    #
    # @param geometry [OGR::Geometry]
    # @return [Float] -1 if an error occurs.
    def distance_to(geometry)
      FFI::OGR::API.OGR_G_Distance(@c_pointer, geometry.c_pointer)
    end

    # NOTE: The returned object may be shared with many geometries, and should
    # thus not be modified.
    #
    # @return [OGR::SpatialReference]
    def spatial_reference
      spatial_ref_ptr = FFI::OGR::API.OGR_G_GetSpatialReference(@c_pointer)
      return if spatial_ref_ptr.null?

      spatial_ref_ptr.autorelease = false

      OGR::SpatialReference.new(spatial_ref_ptr).freeze
    end

    # Assigns a spatial reference to this geometry.  Any existing spatial
    # reference is replaced, but this does not reproject the geometry.
    #
    # @param new_spatial_ref [OGR::SpatialReference]
    # @raise [FFI::GDAL::InvalidPointer]
    def spatial_reference=(new_spatial_ref)
      #  Note that assigning a spatial reference increments the reference count
      #  on the OGRSpatialReference, but does not copy it.
      new_spatial_ref.c_pointer.autorelease = false

      FFI::OGR::API.OGR_G_AssignSpatialReference(@c_pointer, new_spatial_ref.c_pointer)
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
    # @raise [FFI::GDAL::InvalidPointer]
    # @raise [OGR::Failure]
    def transform!(coordinate_transformation)
      coord_trans_ptr = GDAL._pointer(coordinate_transformation)

      OGR::ErrorHandling.handle_ogr_err('Unable to transform geometry') do
        FFI::OGR::API.OGR_G_Transform(@c_pointer, coord_trans_ptr)
      end
    end

    # Similar to +#transform+, but this only works if the geometry already has an
    # assigned spatial reference system _and_ is transformable to the target
    # coordinate system.
    #
    # Because this function requires internal creation and initialization of an
    # OGRCoordinateTransformation object it is significantly more expensive to
    # use this function to transform many geometries than it is to create the
    # OGRCoordinateTransformation in advance, and call transform() with that
    # transformation. This function exists primarily for convenience when only
    # transforming a single geometry.
    #
    # @param new_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    # @raise [FFI::GDAL::InvalidPointer]
    # @raise [OGR::Failure]
    def transform_to!(new_spatial_ref)
      new_spatial_ref_ptr = GDAL._pointer(new_spatial_ref, autorelease: false)

      OGR::ErrorHandling.handle_ogr_err('Unable to transform geometry') do
        FFI::OGR::API.OGR_G_TransformTo(@c_pointer, new_spatial_ref_ptr)
      end
    end

    # Computes and returns a new, simplified geometry.
    #
    # @param distance_tolerance [Float]
    # @param preserve_topology [Boolean]
    # @return [OGR::Geometry]
    def simplify(distance_tolerance, preserve_topology: false)
      OGR::Geometry.build_geometry do
        if preserve_topology
          FFI::OGR::API.OGR_G_SimplifyPreserveTopology(@c_pointer, distance_tolerance)
        else
          FFI::OGR::API.OGR_G_Simplify(@c_pointer, distance_tolerance)
        end
      end
    end

    # Modify the geometry so that it has no segments longer than +max_length+.
    #
    # @param max_length [Float]
    # @return [OGR::Geometry] Returns self that's been segmentized.
    def segmentize!(max_length)
      FFI::OGR::API.OGR_G_Segmentize(@c_pointer, max_length)

      self
    end

    # @return [OGR::Geometry]
    def boundary
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_Boundary(@c_pointer) }
    end

    # Computes the buffer of the geometry by building a new geometry that
    # contains the buffer region around the geometry that this was called on.
    #
    # @param distance [Float] The buffer distance to be applied.
    # @param quad_segments [Integer] The number of segments to use to approximate
    #   a 90 degree (quadrant) of curvature.
    # @return [OGR::Polygon]
    def buffer(distance, quad_segments = 30)
      OGR::Geometry.build_geometry do
        FFI::OGR::API.OGR_G_Buffer(@c_pointer, distance, quad_segments)
      end
    end

    # @return [OGR::Geometry]
    def convex_hull
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_ConvexHull(@c_pointer) }
    end

    # @param wkb_data [String] Binary WKB data.
    # @raise [OGR::Failure]
    def import_from_wkb(wkb_data)
      OGR::ErrorHandling.handle_ogr_err('Unable to import geometry from WKB') do
        FFI::OGR::API.OGR_G_ImportFromWkb(@c_pointer, wkb_data, wkb_data.length)
      end
    end

    # The exact number of bytes required to hold the WKB of this object.
    #
    # @return [Integer]
    def wkb_size
      FFI::OGR::API.OGR_G_WkbSize(@c_pointer)
    end

    # @return [String]
    # @raise [OGR::Failure]
    def to_wkb(byte_order = :wkbXDR)
      output = FFI::MemoryPointer.new(:uchar, wkb_size)

      OGR::ErrorHandling.handle_ogr_err("Unable to export geometry to WKB (using byte order #{byte_order})") do
        FFI::OGR::API.OGR_G_ExportToWkb(@c_pointer, byte_order, output)
      end

      output.read_bytes(wkb_size)
    end

    # @param wkt_data [String]
    # @raise [OGR::Failure]
    def import_from_wkt(wkt_data)
      wkt_data_pointer = FFI::MemoryPointer.from_string(wkt_data)
      wkt_pointer_pointer = FFI::MemoryPointer.new(:pointer)
      wkt_pointer_pointer.write_pointer(wkt_data_pointer)

      OGR::ErrorHandling.handle_ogr_err("Unable to import from WKT: #{wkt_data}") do
        FFI::OGR::API.OGR_G_ImportFromWkt(@c_pointer, wkt_pointer_pointer)
      end
    end

    # @return [String]
    # @raise [OGR::Failure]
    def to_wkt
      OGR::Geometry.to_wkt(@c_pointer)
    end

    # @return [String]
    # @raise [OGR::Failure]
    def to_iso_wkt
      GDAL._cpl_read_and_free_string do |output_ptr|
        OGR::ErrorHandling.handle_ogr_err('Unable to export to WKT') do
          FFI::OGR::API.OGR_G_ExportToIsoWkt(@c_pointer, output_ptr)
        end
      end
    end

    # @return [String, nil]
    def to_gml
      GDAL._cpl_read_and_free_strptr do
        FFI::OGR::API.OGR_G_ExportToGML(@c_pointer)
      end
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
    def to_gml_ex(**options)
      options_ptr = GDAL::Options.pointer(options)

      GDAL._cpl_read_and_free_strptr do
        FFI::OGR::API.OGR_G_ExportToGMLEx(@c_pointer, options_ptr)
      end
    end

    # @param altitude_mode [String] Value to write in the +altitudeMode+
    #   element.
    # @return [String]
    def to_kml(altitude_mode = nil)
      GDAL._cpl_read_and_free_strptr do
        FFI::OGR::API.OGR_G_ExportToKML(@c_pointer, altitude_mode)
      end
    end

    # @return [String]
    def to_geo_json
      GDAL._cpl_read_and_free_strptr do
        FFI::OGR::API.OGR_G_ExportToJson(@c_pointer)
      end
    end

    # @param [Hash] options
    # @option options [String] :coordinate_precision Maximum number of figures
    #   after decimal separate to write in coordinates.
    # @option options [String] :significant_figures Maximum number of
    #   significant figures.
    # @return [String]
    def to_geo_json_ex(**options)
      options_ptr = GDAL::Options.pointer(options)

      GDAL._cpl_read_and_free_strptr do
        FFI::OGR::API.OGR_G_ExportToJsonEx(@c_pointer, options_ptr)
      end
    end

    # Converts the current geometry to a LineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_line_string
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_ForceToLineString(clone.c_pointer) }
    end

    # Since GDAL doesn't provide converting to a LinearRing, this is a hackish
    # method for doing so.
    #
    # @return [OGR::LinearRing]
    def to_linear_ring(close_rings: false)
      line_string = to_line_string

      return line_string unless line_string.is_a?(OGR::LineString)

      linear_ring = OGR::LinearRing.new

      linear_ring.spatial_reference = line_string.spatial_reference.clone if line_string.spatial_reference

      linear_ring.import_from_wkt(line_string.to_wkt.tr('LINESTRING', 'LINEARRING'))
      linear_ring.close_rings! if close_rings

      linear_ring
    end

    # Converts the current geometry to a Polygon geometry.  The returned object
    # is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_polygon
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_ForceToPolygon(clone.c_pointer) }
    end

    # Converts the current geometry to a MultiPoint geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_point
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_ForceToMultiPoint(clone.c_pointer) }
    end

    # Converts the current geometry to a MultiLineString geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::Geometry]
    def to_multi_line_string
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_ForceToMultiLineString(clone.c_pointer) }
    end

    # Converts the current geometry to a MultiPolygon geometry.  The returned
    # object is a new OGR::Geometry instance.
    #
    # @return [OGR::MultiPolygon]
    def to_multi_polygon
      OGR::Geometry.build_geometry { FFI::OGR::API.OGR_G_ForceToMultiPolygon(@c_pointer) }
    end
  end
end
