# frozen_string_literal: true

require_relative '../../ogr'
require_relative '../../gdal'

module OGR
  module Geometry
    # All geometry types have these methods.
    #
    module GeometryMethods
      # @return [OGR::Geometry]
      def clone
        OGR::Geometry.new_borrowed(FFI::OGR::API.OGR_G_Clone(@c_pointer))
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

      # @return [Integer] 2 for XY, 3 for XYZ and XYM, and 4 for XYZM data.
      def coordinate_dimension
        FFI::OGR::API.OGR_G_CoordinateDimension(@c_pointer)
      end

      # @param new_coordinate_dimension [Integer]
      # @raise [OGR::Failure] if +new_coordinate_dimension+ isn't 2, 3 or 4.
      def coordinate_dimension=(new_coordinate_dimension)
        unless [2, 3, 4].include?(new_coordinate_dimension)
          raise OGR::Failure, "Can't set coordinate to #{new_coordinate_dimension}; must be 2, 3, or 4."
        end

        FFI::OGR::API.OGR_G_SetCoordinateDimension(@c_pointer, new_coordinate_dimension)
      end

      # Does this geometry have a Z coordinate?
      #
      # @return [Boolean]
      def is_3d?
        FFI::OGR::API.OGR_G_Is3D(@c_pointer)
      end

      # Does this geometry have an M coordinate?
      #
      # @return [Boolean]
      def measured?
        FFI::OGR::API.OGR_G_IsMeasured(@c_pointer)
      end
      alias is_measured? measured?

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
        OGR::Geometry.type_to_name(type)
      end

      # @return [String]
      def name
        # The returned pointer is to a static internal string and should not be modified or freed.
        FFI::OGR::API.OGR_G_GetGeometryName(@c_pointer).freeze
      end

      # @raise [RuntimeError]
      def centroid
        raise 'child class must include `OGR::HasTwoCoordinateDimensions` or ' \
              '`OGR::HasThreeCoordinateDimensions`'
      end

      # Dump as WKT to the given +file_path+; dumps to STDOUT if none is given.
      #
      # @param file_path [String, nil] The text file to write to.
      # @param prefix [String] The prefix to put on each line of output.
      def dump_readable(file_path = nil, prefix: nil)
        file_ptr = FFI::CPL::Conv.CPLOpenShared(file_path, 'w', false)

        if file_ptr.null?
          output = file_path || 'STDOUT'
          raise FFI::GDAL::InvalidPointer, "Unable to open for write: '#{output}'"
        end

        FFI::OGR::API.OGR_G_DumpReadable(@c_pointer, file_ptr, prefix)
        FFI::CPL::Conv.CPLCloseShared(file_ptr)
      end

      # NOTE: The returned object may be shared with many geometries, and should
      # thus not be modified.
      #
      # @return [OGR::SpatialReference]
      def spatial_reference
        spatial_ref_ptr = FFI::OGR::API.OGR_G_GetSpatialReference(@c_pointer)
        return if spatial_ref_ptr.null?

        OGR::SpatialReference.new_borrowed(spatial_ref_ptr)
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

      # Swaps X and Y coordinates on self.
      #
      def swap_xy!
        FFI::OGR::API.OGR_G_SwapXY(@c_pointer)
      end

      # Transforms the coordinates of this geometry in its current spatial
      # reference system to a new spatial reference system.  Normally this means
      # reprojecting the vectors, but it could also include datum shifts, and
      # changes of units.
      #
      # Note that this doesn't require the geometry to have an existing spatial
      # reference system.
      #
      # @param coordinate_transformation [OGR::CoordinateTransformation]
      # @raise [FFI::GDAL::InvalidPointer]
      # @raise [OGR::Failure]
      def transform!(coordinate_transformation)
        OGR::ErrorHandling.handle_ogr_err('Unable to transform geometry') do
          FFI::OGR::API.OGR_G_Transform(@c_pointer, coordinate_transformation.c_pointer)
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
      # @param new_spatial_ref [OGR::SpatialReference]
      # @raise [FFI::GDAL::InvalidPointer]
      # @raise [OGR::Failure]
      def transform_to!(new_spatial_ref)
        OGR::ErrorHandling.handle_ogr_err('Unable to transform geometry') do
          FFI::OGR::API.OGR_G_TransformTo(@c_pointer, new_spatial_ref.c_pointer)
        end
      end

      # @param other_geometry [OGR::Geometry]
      # @return [Boolean]
      # @raise [FFI::GDAL::InvalidPointer]
      def intersects?(other_geometry)
        FFI::OGR::API.OGR_G_Intersects(@c_pointer, other_geometry.c_pointer)
      end

      # @param other_geometry [OGR::Geometry]
      # @return [Boolean]
      def equals?(other_geometry)
        FFI::OGR::API.OGR_G_Equals(@c_pointer, other_geometry.c_pointer)
      end
      alias == equals?

      # @param other_geometry [OGR::Geometry]
      # @return [Boolean]
      # @raise [FFI::GDAL::InvalidPointer]
      def disjoint?(other_geometry)
        FFI::OGR::API.OGR_G_Disjoint(@c_pointer, other_geometry.c_pointer)
      end

      # @param other_geometry [OGR::Geometry]
      # @return [Boolean]
      def touches?(other_geometry)
        FFI::OGR::API.OGR_G_Touches(@c_pointer, other_geometry.c_pointer)
      end

      # @param other_geometry [OGR::Geometry]
      # @return [Boolean]
      # @raise [FFI::GDAL::InvalidPointer]
      def crosses?(other_geometry)
        FFI::OGR::API.OGR_G_Crosses(@c_pointer, other_geometry.c_pointer)
      end

      # @param other_geometry [OGR::Geometry]
      # @return [Boolean]
      # @raise [FFI::GDAL::InvalidPointer]
      def within?(other_geometry)
        FFI::OGR::API.OGR_G_Within(@c_pointer, other_geometry.c_pointer)
      end

      # @param other_geometry [OGR::Geometry]
      # @return [Boolean]
      # @raise [FFI::GDAL::InvalidPointer]
      def contains?(other_geometry)
        FFI::OGR::API.OGR_G_Contains(@c_pointer, other_geometry.c_pointer)
      end

      # @param other_geometry [OGR::Geometry]
      # @return [Boolean]
      # @raise [FFI::GDAL::InvalidPointer]
      def overlaps?(other_geometry)
        FFI::OGR::API.OGR_G_Overlaps(@c_pointer, other_geometry.c_pointer)
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
      # @return [OGR::Geometry, nil]
      def intersection(other_geometry)
        OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_Intersection(@c_pointer, other_geometry.c_pointer)
        end
      end

      # @param other_geometry [OGR::Geometry]
      # @return [OGR::Geometry, nil]
      def union(other_geometry)
        OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_Union(@c_pointer, other_geometry.c_pointer)
        end
      end

      # If this or any contained geometries has polygon rings that aren't closed,
      # this closes them by adding the starting point at the end.
      def close_rings!
        FFI::OGR::API.OGR_G_CloseRings(@c_pointer)
      end

      # @param other_geometry [OGR::Geometry]
      # @return [OGR::Geometry, nil] Returns nil if the difference is empty, OR
      #   if there was an error (i.e. there's no way to distinguish).
      def difference(other_geometry)
        OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_Difference(@c_pointer, other_geometry.c_pointer)
        end
      end
      alias - difference

      # @param other_geometry [OGR::Geometry]
      # @return [OGR::Geometry, nil]
      def symmetric_difference(other_geometry)
        OGR::Geometry.new_owned(FFI::OGR::API.OGR_G_SymDifference(@c_pointer, other_geometry.c_pointer))
      end

      # The shortest distance between the two geometries.
      #
      # @param other_geometry [OGR::Geometry]
      # @return [Float]
      # @raise [OGR::Failure] If an error occurs during calculation.
      def distance(other_geometry)
        result = FFI::OGR::API.OGR_G_Distance(@c_pointer, other_geometry.c_pointer)

        raise OGR::Failure, 'Unable to calculate distance to other geometry' if result == -1

        result
      end
      alias distance_to distance

      # The shortest distance between the two geometries.
      #
      # @param other_geometry [OGR::Geometry]
      # @return [Float]
      # @raise [OGR::Failure] If an error occurs during calculation.
      def distance3d(other_geometry)
        result = FFI::OGR::API.OGR_G_Distance3D(@c_pointer, other_geometry.c_pointer)

        raise OGR::Failure, 'Unable to calculate distance to other geometry' if result == -1

        result
      end

      # Computes and returns a new, simplified geometry.
      #
      # @param distance_tolerance [Float]
      # @param preserve_topology [Boolean]
      # @return [OGR::Geometry]
      def simplify(distance_tolerance, preserve_topology: false)
        OGR::Geometry.build_owned_geometry do
          if preserve_topology
            FFI::OGR::API.OGR_G_SimplifyPreserveTopology(@c_pointer, distance_tolerance)
          else
            FFI::OGR::API.OGR_G_Simplify(@c_pointer, distance_tolerance)
          end
        end
      end

      # @param only_edges [bool] If +true+, will returns a `MULTILINESTRING`,
      #   otherwise it will return a `GEOMETRYCOLLECTION` containing triangular
      #   `POLYGON`s.
      # @param snapping_tolerance [Float, nil]
      def delaunay_triangulation(only_edges, snapping_tolerance: 0.0)
        OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_DelaunayTriangulation(@c_pointer, snapping_tolerance, only_edges)
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

      # Computes the buffer of the geometry by building a new geometry that
      # contains the buffer region around the geometry that this was called on.
      #
      # @param distance [Float] The buffer distance to be applied.
      # @param quad_segments [Integer] The number of segments to use to approximate
      #   a 90 degree (quadrant) of curvature.
      # @return [Self]
      # @raise [OGR::Failure]
      def buffer(distance, quad_segments = 30)
        result = OGR::Geometry.build_owned_geometry { FFI::OGR::API.OGR_G_Buffer(@c_pointer, distance, quad_segments) }
        raise OGR::Failure, 'Failure computing buffer' unless result

        result
      end

      # @return [OGR::Geometry]
      # @raise [OGR::Failure]
      def convex_hull
        result = OGR::Geometry.build_owned_geometry { FFI::OGR::API.OGR_G_ConvexHull(@c_pointer) }
        raise OGR::Failure, 'Failure computing convex hull' unless result

        result
      end

      # Note that there is no check that the +wkb_data+ actually describes a
      # geometry that correlates to the current class. If you don't know what
      # to expect, you're better off using +OGR::Geometry.create_from_wkb+.
      #
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
        size = wkb_size
        output = FFI::Buffer.new_out(:uchar, size)

        OGR::ErrorHandling.handle_ogr_err("Unable to export geometry to WKB (using byte order #{byte_order})") do
          FFI::OGR::API.OGR_G_ExportToWkb(@c_pointer, byte_order, output)
        end

        output.read_bytes(size)
      end

      # @return [String]
      # @raise [OGR::Failure]
      def to_iso_wkb(byte_order = :wkbXDR)
        size = wkb_size
        output = FFI::Buffer.new_out(:uchar, size)

        OGR::ErrorHandling.handle_ogr_err("Unable to export geometry to WKB (using byte order #{byte_order})") do
          FFI::OGR::API.OGR_G_ExportToIsoWkb(@c_pointer, byte_order, output)
        end

        output.read_bytes(size)
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

      # @return [String]
      def to_gml
        GDAL._cpl_read_and_free_strptr do
          FFI::OGR::API.OGR_G_ExportToGML(@c_pointer)
        end
      end

      # This geometry expressed as GML in GML basic data types.
      #
      # @param format ["GML2", "GML3", "GML32"] Defaults to "GML2.1.2".
      # @param gml3_linestring_element ["curve"] only pertains a) to LineString
      #   geometries, and b) when +:format+ is set to GML3.
      # @param gml3_longsrs ["YES", "NO"] Defaults to "YES", which prefixes
      #   the EPSG authority with "urn:ogc:def:crs:EPSG::".  If "NO", the EPSG
      #   authority is prefixed with "EPSG:".
      # @param gmlid [String] Use this to write a gml:id attribute at the top
      #   level of the geometry.
      # @param namespace_decl ["YES", "NO"]
      # @param srsdimension_loc ["POSLIST", "GEOMETRY", "GEOMETRY,POSLIST"]
      # @param srsname_format ["SHORT", "OGC_URN", "OGC_URL"]
      # @return [String]
      def to_gml_ex(format: nil, gml3_linestring_element: nil, gml3_longsrs: nil,
        gmlid: nil, namespace_decl: nil, srsdimension_loc: nil, srsname_format: nil)
        options_ptr = GDAL::Options.pointer({
          format: format, gml3_linestring_element: gml3_linestring_element,
          gml3_longsrs: gml3_longsrs, gmlid: gmlid, namespace_decl: namespace_decl,
          srsdimension_loc: srsdimension_loc, srsname_format: srsname_format
        }.compact)

        GDAL._cpl_read_and_free_strptr do
          FFI::OGR::API.OGR_G_ExportToGMLEx(@c_pointer, options_ptr)
        end
      end

      # @param altitude_mode [String, nil] Value to write in the +altitudeMode+
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

      # @param coordinate_precision [String, nil] Maximum number of figures after
      #   decimal separate to write in coordinates.
      # @param significant_figures [String, nil] Maximum number of significant figures.
      # @return [String]
      def to_geo_json_ex(coordinate_precision: nil, significant_figures: nil)
        options_ptr = GDAL::Options.pointer({
          coordinate_precision: coordinate_precision,
          significant_figures: significant_figures
        }.compact)

        GDAL._cpl_read_and_free_strptr do
          FFI::OGR::API.OGR_G_ExportToJsonEx(@c_pointer, options_ptr)
        end
      end

      # Tries to convert the current geometry to a LineString (but may not).
      #
      # @return [#to_line_string]
      def to_line_string
        result = OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_ForceToLineString(clone.c_pointer)
        end

        raise OGR::Failure, 'Failure forcing geometry to LineString' unless result

        result
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

      # Tries to convert the current geometry to a Polygon geometry (but may
      # not).
      #
      # @return [#to_polygon]
      def to_polygon
        result = OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_ForceToPolygon(clone.c_pointer)
        end

        raise OGR::Failure, 'Failure forcing geometry to Polygon' unless result

        result
      end

      # Tries to onvert the current geometry to a MultiPoint geometry (but may
      # not).
      #
      # @return [#to_multi_point]
      def to_multi_point
        result = OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_ForceToMultiPoint(clone.c_pointer)
        end

        raise OGR::Failure, 'Failure forcing geometry to MultiPoint' unless result

        result
      end

      # Tries to convert the current geometry to a MultiLineString geometry (but
      # may not).
      #
      # @return [#to_multi_line_string]
      def to_multi_line_string
        result = OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_ForceToMultiLineString(clone.c_pointer)
        end

        raise OGR::Failure, 'Failure forcing geometry to MultiLineString' unless result

        result
      end

      # Tries to convert the current geometry to a MultiPolygon geometry (but
      # may not).
      #
      # @return [#to_multi_polygon]
      def to_multi_polygon
        result = OGR::Geometry.build_owned_geometry do
          FFI::OGR::API.OGR_G_ForceToMultiPolygon(clone.c_pointer)
        end

        raise OGR::Failure, 'Failure forcing geometry to MultiPolygon' unless result

        result
      end

      # @param geometry_type [FFI::OGR::Core::WKBGeometryType]
      # @param options
      # @return Should return an object of the type that corresponds to +geometry_type+,
      #   but that's no guaranteed.
      def force_to_type(geometry_type, **options)
        options_ptr = GDAL::Options.pointer(options)
        new_geometry_ptr = FFI::OGR::API.OGR_G_ForceTo(clone.c_pointer, geometry_type, options_ptr)

        raise 'New geometry pointer was null' if new_geometry_ptr.null?

        OGR::Geometry.new_owned(new_geometry_ptr)
      end
    end
  end
end
