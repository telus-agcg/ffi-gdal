require_relative '../ffi/ogr'

module OGR
  # Represents a geographic coordinate system.  There are two primary types:
  #   1. "geographic", where positions are measured in long/lat.
  #   2. "projected", where positions are measure in meters or feet.
  class SpatialReference
    include FFI::GDAL

    # Builds a spatial reference object using either the passed-in WKT string,
    # OGR::SpatialReference object, or a pointer to an in-memory
    # SpatialReference object.  If nothing is passed in, an empty
    # SpatialReference object is created, in which case you'll need to populate
    # relevant attributes.
    #
    # @param spatial_reference_or_wkt [OGR::SpatialReference, FFI::Pointer,
    #   String]
    def initialize(spatial_reference_or_wkt=nil)
      @ogr_spatial_ref_pointer = if spatial_reference_or_wkt.is_a? OGR::SpatialReference
        spatial_reference_or_wkt.c_pointer
      elsif spatial_reference_or_wkt.is_a? String
        OSRNewSpatialReference(spatial_reference_or_wkt)
      elsif spatial_reference_or_wkt.is_a? FFI::Pointer
        spatial_reference_or_wkt
      else
        OSRNewSpatialReference(nil)
      end

      close_me = -> { OSRDestroySpatialReference(@ogr_spatial_ref_pointer) }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @ogr_spatial_ref_pointer
    end

    # Uses the C-API to clone this spatial reference object.
    def clone
      new_spatial_ref_ptr = OSRClone(@ogr_spatial_ref_pointer)

      self.class.new(ogr_spatial_ref_pointer: new_spatial_ref_ptr)
    end

    def validate
      ogr_err = OSRValidate(@ogr_spatial_ref_pointer)
    end

    def fixup_ordering!
      ogr_err = OSRFixupOrdering(@ogr_spatial_ref_pointer)
    end

    def fixup!
      ogr_err = OSRFixup(@ogr_spatial_ref_pointer)
    end

    def strip_ct_parameters!
      ogr_err = OSRStripCTParms(@ogr_spatial_ref_pointer)
    end

    # @param name [String] The case-insensitive tree node to look for.
    # @param child [Fixnum] The child of the node to fetch.
    # @return [String, nil]
    def attribute_value(name, child=0)
      OSRGetAttrValue(@ogr_spatial_ref_pointer, name, child)
    end

    # @return [Hash{unit_name: String, value: Float}]
    def angular_units
      name = FFI::MemoryPointer.new(:string)
      name_ptr = FFI::MemoryPointer.new(:pointer)
      name_ptr.write_pointer(name)

      value = OSRGetAngularUnits(@ogr_spatial_ref_pointer, name_ptr)

      { unit_name: name_ptr.read_pointer.read_string, value: value }
    end

    # @return [Hash{unit_name: String, value: Float}]
    def linear_units
      name = FFI::MemoryPointer.new(:string)
      name_ptr = FFI::MemoryPointer.new(:pointer)
      name_ptr.write_pointer(name)

      value = OSRGetLinearUnits(@ogr_spatial_ref_pointer, name_ptr)

      { unit_name: name_ptr.read_pointer.read_string, value: value }
    end

    # @param target_key [String] I.e. "PROJCS" or "VERT_CS".
    # @return [Hash]
    def target_linear_units(target_key)
      name = FFI::MemoryPointer.new(:string)
      name_ptr = FFI::MemoryPointer.new(:pointer)
      name_ptr.write_pointer(name)

      value = OSRGetTargetLinearUnits(@ogr_spatial_ref_pointer, target_key, name_ptr)

      { unit_name: name_ptr.read_pointer.read_string, value: value }
    end

    # @return [Array<Float>]
    def towgs84
      coefficients = FFI::MemoryPointer.new(:double, 7)
      ogr_err = OSRGetTOWGS84(@ogr_spatial_ref_pointer, coefficients, 7)

      coefficients.read_array_of_double(0)
    end

    # @param target_key [String] The partial or complete path to the node to get
    #   an authority from ("PROJCS", "GEOCS", "GEOCS|UNIT").  Leave empty to
    #   search at the root element.
    # @return [String, nil]
    def authority_code(target_key=nil)
      OSRGetAuthorityCode(@ogr_spatial_ref_pointer, target_key)
    end

    # @param target_key [String] The partial or complete path to the node to get
    #   an authority from ("PROJCS", "GEOCS", "GEOCS|UNIT").  Leave empty to
    #   search at the root element.
    # @return [String, nil]
    def authority_name(target_key=nil)
      OSRGetAuthorityName(@ogr_spatial_ref_pointer, target_key)
    end

    # @param axis_number [Fixnum] The Axis to query (0 or 1.)
    # @param target_key [String]
    # @return [String, nil]
    def axis(axis_number, target_key=nil)
      axis_orientation_ptr = FFI::MemoryPointer.new(:int)

      name = OSRGetAxis(@ogr_spatial_ref_pointer, target_key, axis_number, axis_orientation_ptr)
      ao_value = axis_orientation_ptr.read_int

      { name: name, orientation: OGRAxisOrientation[ao_value] }
    end

    # @return [Float]
    def spheroid_inverse_flattening
      err_ptr = FFI::MemoryPointer.new(:int)
      value = OSRGetInvFlattening(@ogr_spatial_ref_pointer, err_ptr)
      ogr_err = OGRErr[err_ptr.read_int]

      if ogr_err == :OGRERR_FAILURE && value.is_a?(Float)
        warn "WARN: #spheroid_inverse_flattening received error _and_ a value. Something is fishy..."
      end

      value
    end

    # @return [Float]
    def semi_major
      err_ptr = FFI::MemoryPointer.new(:int)
      value = OSRGetSemiMajor(@ogr_spatial_ref_pointer, err_ptr)
      ogr_err = OGRErr[err_ptr.read_int]

      if ogr_err == :OGRERR_FAILURE && value.is_a?(Float)
        warn "WARN: #semi_major received error _and_ a value. Something is fishy..."
      end

      value
    end

    # @param hemisphere [Symbol] :north or :south.
    # @return [Fixnum] The zone, or 0 if this isn't a UTM definition.
    def utm_zone(hemisphere=:north)
      north = case hemisphere
      when :north then 1
      when :south then 0
      else raise "Unknown hemisphere type #{hemisphere}. Please choose :north or :south."
      end
      north_ptr = FFI::MemoryPointer.new(:bool)
      north_ptr.write_bytes(north.to_s)

      OSRGetUTMZone(@ogr_spatial_ref_pointer, north_ptr)
    end

    # @return [Float]
    def semi_minor
      err_ptr = FFI::MemoryPointer.new(:int)
      value = OSRGetSemiMinor(@ogr_spatial_ref_pointer, err_ptr)
      ogr_err = OGRErr[err_ptr.read_int]

      if ogr_err == :OGRERR_FAILURE && value.is_a?(Float)
        warn "WARN: #semi_minor received error _and_ a value. Something is fishy..."
      end

      value
    end

    def from_epsg(code)
      ogr_err = OSRImportFromEPSG(@ogr_spatial_ref_pointer, code)
    end

    def from_epsga(code)
      ogr_err = OSRImportFromEPSGA(@ogr_spatial_ref_pointer, code)
    end

    def from_erm(proj, datum, units)
      ogr_err = OSRImportFromERM(@ogr_spatial_ref_pointer, proj, datum, units)
    end

    # def from_esri(prj)
    #   @ogr_spatial_ref_pointer ||= FFI::MemoryPointer.new
    #
    #   OSRImportFromERM(@ogr_spatial_ref_pointer, proj, datum, units)
    # end

    def from_mapinfo(coord_sys)
      ogr_err = OSRImportFromMICoordSys(@ogr_spatial_ref_pointer, coord_sys)
    end

    def from_pci(proj, units, proj_params)
      ogr_err = OSRImportFromPCI(@ogr_spatial_ref_pointer, proj, units, proj_params)
    end

    def from_proj4(proj4)
      ogr_err = OSRImportFromProj4(@ogr_spatial_ref_pointer, proj4)
    end

    def from_url(url)
      ogr_err = OSRImportFromUrl(@ogr_spatial_ref_pointer, url)
    end

    def from_usgs(projsys, zone, proj_params, datum)
      ogr_err = OSRImportFromUSGS(@ogr_spatial_ref_pointer, projsys, zone, proj_params, datum)
    end

    def from_wkt(wkt)
      wkt_ptr = FFI::MemoryPointer.from_string(wkt)
      wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      wkt_ptr_ptr.write_pointer(wkt_ptr)

      ogr_err = OSRImportFromWkt(@ogr_spatial_ref_pointer, wkt_ptr_ptr)
    end

    def from_xml(xml)
      ogr_err = OSRImportFromXML(@ogr_spatial_ref_pointer, xml)
    end

    def to_proj4
      proj4 = FFI::MemoryPointer.new(:string)
      proj4_ptr = FFI::MemoryPointer.new(:pointer)
      proj4_ptr.write_pointer(proj4)

      ogr_err = OSRExportToProj4(@ogr_spatial_ref_pointer, proj4_ptr)

      proj4_ptr.read_pointer.read_string
    end

    def to_wkt
      wkt_ptr = FFI::MemoryPointer.new(:string)
      wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      wkt_ptr_ptr.write_pointer(wkt_ptr)

      ogr_err = OSRExportToWkt(@ogr_spatial_ref_pointer, wkt_ptr_ptr)

      wkt_ptr_ptr.read_pointer.read_string
    end

    # @param simplify [Boolean] +true+ strips off +AXIS+, +AUTHORITY+ and
    #   +EXTENSION+ nodes.
    def to_pretty_wkt(simplify=false)
      wkt_ptr = FFI::MemoryPointer.new(:string)
      wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      wkt_ptr_ptr.write_pointer(wkt_ptr)

      ogr_err = OSRExportToPrettyWkt(@ogr_spatial_ref_pointer, wkt_ptr_ptr, simplify)

      wkt_ptr_ptr.read_pointer.read_string
    end

    # @return [Boolean]
    def geographic?
      OSRIsGeographic(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def local?
      OSRIsLocal(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def projected?
      OSRIsProjected(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def compound?
      OSRIsCompound(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def geocentric?
      OSRIsGeocentric(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def vertical?
      OSRIsVertical(@ogr_spatial_ref_pointer)
    end

    # @return [FFI::Pointer] Pointer to an OGRCreateCoordinateTransformation.
    def create_coordinate_transfomration(destination_spatial_ref)
      dest_ptr = GDAL._pointer(OGR::SpatialReference, destination_spatial_ref)

      OGRCreateCoordinateTransformation(@ogr_spatial_ref_pointer, dest_ptr)
    end
  end
end
