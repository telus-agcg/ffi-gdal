require_relative '../ffi/ogr'

module OGR
  # Represents a geographic coordinate system.  There are two primary types:
  #   1. "geographic", where positions are measured in long/lat.
  #   2. "projected", where positions are measure in meters or feet.
  class SpatialReference

    # @return [Array<String>]
    def self.projection_methods
      return @projection_methods if @projection_methods

      methods_ptr_ptr = FFI::GDAL.OPTGetProjectionMethods
      count = FFI::GDAL.CSLCount(methods_ptr_ptr)

      # For some reason #get_array_of_string leaves off the first 6.
      pointer_array = methods_ptr_ptr.get_array_of_pointer(0, count)

      pointer_array.map(&:read_string).sort
    end

    # @param projection_method [String] One of
    #   OGR::SpatialReference.projection_methods.
    # @return [Hash{parameter => Array<String>, user_visible_name => String}]
    def self.parameter_list(projection_method)
      name_ptr = FFI::MemoryPointer.new(:string)
      name_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      name_ptr_ptr.write_pointer(name_ptr)

      params_ptr_ptr = FFI::GDAL.OPTGetParameterList(projection_method,
        name_ptr_ptr)
      count = FFI::GDAL.CSLCount(params_ptr_ptr)

      # For some reason #get_array_of_string leaves off the first 6.
      pointer_array = params_ptr_ptr.get_array_of_pointer(0, count)

      name = if !name_ptr_ptr.read_pointer.null?
        name_ptr_ptr.read_pointer.read_string
      else
        nil
      end

      {
        parameters: pointer_array.map(&:read_string).sort,
        user_visible_name: name
      }
    end

    def self.parameter_info(projection_method, parameter_name)
      name_ptr = FFI::MemoryPointer.new(:string)
      name_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      name_ptr_ptr.write_pointer(name_ptr)

      type_ptr = FFI::MemoryPointer.new(:string)
      type_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      type_ptr_ptr.write_pointer(type_ptr)

      default_value_ptr = FFI::MemoryPointer.new(:double)

      result = FFI::GDAL.OPTGetParameterInfo(projection_method, parameter_name,
        name_ptr_ptr, type_ptr_ptr, default_value_ptr)

      return {} unless result

      name = if !name_ptr_ptr.read_pointer.null?
        name_ptr_ptr.read_pointer.read_string
      else
        nil
      end

      type = if !type_ptr_ptr.read_pointer.null?
        type_ptr_ptr.read_pointer.read_string
      else
        nil
      end

      {
        type: type,
        default_value: default_value_ptr.read_double,
        user_visible_name: name
      }
    end

    # @param code [Fixnum]
    # @return [OGR::SpatialReference]
    def self.new_from_epsg(code)
      build_spatial_ref do |spatial_ref|
        FFI::GDAL.OSRImportFromEPSG(spatial_ref.c_pointer, code)
      end
    end

    # @param code [Fixnum]
    # @return [OGR::SpatialReference]
    def self.new_from_epsga(code)
      build_spatial_ref do |spatial_ref|
        FFI::GDAL.OSRImportFromEPSGA(spatial_ref.c_pointer, code)
      end
    end

    # @param projection_name [String] I.e. "NUTM11" or "GEOGRAPHIC".
    # @param datum_name [String] I.e. "NAD83".
    # @param linear_unit_name [String] Plural form of linear units, i.e. "FEET".
    # @return [OGR::SpatialReference]
    def self.new_from_erm(projection_name, datum_name, linear_unit_name)
      build_spatial_ref do |spatial_ref|
        FFI::GDAL.OSRImportFromERM(spatial_ref.c_pointer, projection_name,
          datum_name, linear_unit_name)
      end
    end

    # @param prj_text [Array<String>]
    # @return [OGR::SpatialReference]
    def self.new_from_esri(prj_text)
      build_spatial_ref do |spatial_ref|
        prj_ptr = FFI::MemoryPointer.new(:string, prj_text.size)
        prj_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        prj_ptr_ptr.write_pointer(prj_ptr)

        FFI::GDAL.OSRImportFromESRI(spatial_ref.c_pointer, prt_ptr)
      end
    end

    # @param coord_sys [String] The Mapinfo style CoordSys definition string.
    # @return [OGR::SpatialReference]
    def self.new_from_mapinfo(coord_sys)
      build_spatial_ref do |spatial_ref|
        FFI::GDAL.OSRImportFromMICoordSys(spatial_ref.c_pointer, coord_sys)
      end
    end

    # @param proj [String]
    # @param units [String]
    # @param proj_params [Array<String>]
    # @return [OGR::SpatialReference]
    def self.new_from_pci(proj, units, *proj_params)
      build_spatial_ref do |spatial_ref|
        if proj_params.empty?
          proj_ptr = nil
        else
          proj_ptr = FFI::MemoryPointer.new(:double, proj_params.size)
          proj_ptr.write_array_of_double(proj_params)
        end

        FFI::GDAL.OSRImportFromPCI(spatial_ref.c_pointer, proj, units, proj_ptr)
      end
    end

    # @param proj4 [String]
    # @return [OGR::SpatialReference]
    def self.new_from_proj4(proj4)
      build_spatial_ref do |spatial_ref|
        FFI::GDAL.OSRImportFromProj4(spatial_ref.c_pointer, proj4)
      end
    end

    # @param url [String] URL to fetch the spatial reference from.
    # @return [OGR::SpatialReference]
    def self.new_from_url(url)
      build_spatial_ref do |spatial_ref|
        FFI::GDAL.OSRImportFromUrl(spatial_ref.c_pointer, url)
      end
    end

    def self.new_from_user_input(definition)
      build_spatial_ref do |spatial_ref|
        FFI::GDAL.OSRSetFromUserInput(spatial_ref.c_pointer, definition)
      end
    end

    # @param projection_system_code
    # @return [OGR::SpatialReference]
    def self.new_from_usgs(projection_system_code, zone, datum, *proj_params)
      build_spatial_ref do |spatial_ref|
        if proj_params.empty?
          proj_ptr = nil
        else
          proj_ptr = FFI::MemoryPointer.new(:double, proj_params.size)
          proj_ptr.write_array_of_double(proj_params)
        end

        FFI::GDAL.OSRImportFromUSGS(spatial_ref.c_pointer,
          projection_system_code, zone, proj_ptr, datum)
      end
    end

    # This wipes the existing SRS definition and reassigns it based on the
    # contents of +wkt+.
    #
    # @param wkt [String]
    # @return [OGR::SpatialReference]
    def self.new_from_wkt(wkt)
      build_spatial_ref do |spatial_ref|
        wkt_ptr = FFI::MemoryPointer.from_string(wkt)
        wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        wkt_ptr_ptr.write_pointer(wkt_ptr)

        FFI::GDAL.OSRImportFromWkt(spatial_ref.c_pointer, wkt_ptr_ptr)
      end
    end

    # Use for importing a GML coordinate system.
    #
    # @param xml [String]
    # @return [OGR::SpatialReference]
    def self.new_from_xml(xml)
      build_spatial_ref do |spatial_ref|
        FFI::GDAL.OSRImportFromXML(spatial_ref.c_pointer, xml)
      end
    end

    # @return [OGR::SpatialReference]
    def self.build_spatial_ref(spatial_reference_or_wkt=nil)
      object = new(spatial_reference_or_wkt)
      ogr_err = yield object

      object
    end
    private_class_method :build_spatial_ref

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
        FFI::GDAL.OSRNewSpatialReference(spatial_reference_or_wkt)
      elsif spatial_reference_or_wkt.is_a? FFI::Pointer
        spatial_reference_or_wkt
      else
        FFI::GDAL.OSRNewSpatialReference(nil)
      end

      close_me = -> { destroy! }
      ObjectSpace.define_finalizer self, close_me
    end

    def c_pointer
      @ogr_spatial_ref_pointer
    end

    def destroy!
      FFI::GDAL.OSRDestroySpatialReference(@ogr_spatial_ref_pointer)
    end

    # Uses the C-API to clone this spatial reference object.
    def clone
      new_spatial_ref_ptr = FFI::GDAL.OSRClone(@ogr_spatial_ref_pointer)

      self.class.new(new_spatial_ref_ptr)
    end

    # Makes a duplicate of the GEOGCS node of this spatial referece.
    #
    # @return [OGR::SpatialReference]
    def clone_geogcs
      new_spatial_ref_ptr = FFI::GDAL.OSRCloneGeogCS(@ogr_spatial_ref_pointer)

      self.class.new(new_spatial_ref_ptr)
    end

    def validate
      ogr_err = FFI::GDAL.OSRValidate(@ogr_spatial_ref_pointer)
    end

    def fixup_ordering!
      ogr_err = FFI::GDAL.OSRFixupOrdering(@ogr_spatial_ref_pointer)
    end

    def fixup!
      ogr_err = FFI::GDAL.OSRFixup(@ogr_spatial_ref_pointer)
    end

    def strip_ct_parameters!
      ogr_err = FFI::GDAL.OSRStripCTParms(@ogr_spatial_ref_pointer)
    end

    # @param name [String] The case-insensitive tree node to look for.
    # @param child [Fixnum] The child of the node to fetch.
    # @return [String, nil]
    def attribute_value(name, child=0)
      FFI::GDAL.OSRGetAttrValue(@ogr_spatial_ref_pointer, name, child)
    end

    # @return [Hash{unit_name: String, value: Float}]
    def angular_units
      name = FFI::MemoryPointer.new(:string)
      name_ptr = FFI::MemoryPointer.new(:pointer)
      name_ptr.write_pointer(name)

      value = FFI::GDAL.OSRGetAngularUnits(@ogr_spatial_ref_pointer, name_ptr)

      { unit_name: name_ptr.read_pointer.read_string, value: value }
    end

    # @return [Hash{unit_name: String, value: Float}]
    def linear_units
      name = FFI::MemoryPointer.new(:string)
      name_ptr = FFI::MemoryPointer.new(:pointer)
      name_ptr.write_pointer(name)

      value = FFI::GDAL.OSRGetLinearUnits(@ogr_spatial_ref_pointer, name_ptr)

      { unit_name: name_ptr.read_pointer.read_string, value: value }
    end

    # @param target_key [String] I.e. "PROJCS" or "VERT_CS".
    # @return [Hash]
    def target_linear_units(target_key)
      name = FFI::MemoryPointer.new(:string)
      name_ptr = FFI::MemoryPointer.new(:pointer)
      name_ptr.write_pointer(name)

      value = FFI::GDAL.OSRGetTargetLinearUnits(@ogr_spatial_ref_pointer, target_key, name_ptr)

      { unit_name: name_ptr.read_pointer.read_string, value: value }
    end

    # @return [Hash]
    def prime_meridian
      pm = FFI::MemoryPointer.new(:string)
      pm_ptr = FFI::MemoryPointer.new(:pointer)
      pm_ptr.write_pointer(pm)

      value = FFI::GDAL.OSRGetPrimeMeridian(@ogr_spatial_ref_pointer, pm_ptr)

      { name: pm_ptr.read_pointer.read_string, value: value }
    end

    # @param projection_name [String]
    def projection=(projection_name)
      ogr_err = FFI::GDAL.OSRSetProjection(@ogr_spatial_ref_pointer, projection_name)
    end

    # Sets the EPSG authority info if possible.
    def auto_identify_epsg!
      ogr_err = FFI::GDAL.OSRAutoIdentifyEPSG(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean] +true+ if this coordinate system should be treated as
    #   having lat/long coordinate ordering.
    def epsg_treats_as_lat_long?
      FFI::GDAL.OSREPSGTreatsAsLatLong(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean] +true+ if this coordinate system should be treated as
    #   having northing/easting coordinate ordering.
    def epsg_treats_as_northing_easting?
      FFI::GDAL.OSREPSGTreatsAsNorthingEasting(@ogr_spatial_ref_pointer)
    end

    # @return [Array<Float>]
    def towgs84
      coefficients = FFI::MemoryPointer.new(:double, 7)
      ogr_err = FFI::GDAL.OSRGetTOWGS84(@ogr_spatial_ref_pointer, coefficients, 7)

      coefficients.read_array_of_double(0)
    end

    # @param target_key [String] The partial or complete path to the node to get
    #   an authority from ("PROJCS", "GEOCS", "GEOCS|UNIT").  Leave empty to
    #   search at the root element.
    # @return [String, nil]
    def authority_code(target_key=nil)
      FFI::GDAL.OSRGetAuthorityCode(@ogr_spatial_ref_pointer, target_key)
    end

    # @param target_key [String] The partial or complete path to the node to get
    #   an authority from ("PROJCS", "GEOCS", "GEOCS|UNIT").  Leave empty to
    #   search at the root element.
    # @return [String, nil]
    def authority_name(target_key=nil)
      FFI::GDAL.OSRGetAuthorityName(@ogr_spatial_ref_pointer, target_key)
    end

    # @param axis_number [Fixnum] The Axis to query (0 or 1.)
    # @param target_key [String]
    # @return [String, nil]
    def axis(axis_number, target_key=nil)
      axis_orientation_ptr = FFI::MemoryPointer.new(:int)

      name = FFI::GDAL.OSRGetAxis(@ogr_spatial_ref_pointer, target_key, axis_number, axis_orientation_ptr)
      ao_value = axis_orientation_ptr.read_int

      { name: name, orientation: OGRAxisOrientation[ao_value] }
    end

    # @return [Float]
    def spheroid_inverse_flattening
      err_ptr = FFI::MemoryPointer.new(:int)
      value = FFI::GDAL.OSRGetInvFlattening(@ogr_spatial_ref_pointer, err_ptr)
      ogr_err = OGRErr[err_ptr.read_int]

      if ogr_err == :OGRERR_FAILURE && value.is_a?(Float)
        warn "WARN: #spheroid_inverse_flattening received error _and_ a value. Something is fishy..."
      end

      value
    end

    # @return [Float]
    def semi_major
      err_ptr = FFI::MemoryPointer.new(:int)
      value = FFI::GDAL.OSRGetSemiMajor(@ogr_spatial_ref_pointer, err_ptr)
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

      FFI::GDAL.OSRGetUTMZone(@ogr_spatial_ref_pointer, north_ptr)
    end

    # @return [Float]
    def semi_minor
      err_ptr = FFI::MemoryPointer.new(:int)
      value = FFI::GDAL.OSRGetSemiMinor(@ogr_spatial_ref_pointer, err_ptr)
      ogr_err = OGRErr[err_ptr.read_int]

      if ogr_err == :OGRERR_FAILURE && value.is_a?(Float)
        warn "WARN: #semi_minor received error _and_ a value. Something is fishy..."
      end

      value
    end

    # Set the user-visible LOCAL_CS name.
    #
    # @param name [String]
    def local_cs=(name)
      ogr_err = FFI::GDAL.OSRSetLocalCS(@ogr_spatial_ref_pointer, name)
    end

    # Set the user-visible GEOCCS name.
    #
    # @param name [String]
    def geoccs=(name)
      ogr_err = FFI::GDAL.OSRSetGeocCS(@ogr_spatial_ref_pointer, name)
    end

    # Set the GEOCCS based on a well-knon name.
    #
    # @param name [String]
    def well_known_geoccs=(name)
      ogr_err = FFI::GDAL.OSRSetWellKnownGeocCS(@ogr_spatial_ref_pointer, name)
    end

    # Set the user-visible PROJCS name.
    #
    # @param name [String]
    def projcs=(name)
      ogr_err = FFI::GDAL.OSRSetProjCS(@ogr_spatial_ref_pointer, name)
    end

    # @return [Hash]
    def to_erm
      projection_name = FFI::MemoryPointer.new(:string)
      datum_name = FFI::MemoryPointer.new(:string)
      units = FFI::MemoryPointer.new(:string)

      ogr_err = FFI::GDAL.OSRExportToERM(@ogr_spatial_ref_pointer, projection_name,
        datum_name, units)

      {
        projection_name: projection_name.read_string,
        datum_name: datum_name.read_string,
        units: units.read_string
      }
    end

    # @return [Array<String>]
    def to_mapinfo
      return_ptr = FFI::MemoryPointer.new(:string)
      return_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      return_ptr_ptr.write_pointer(return_ptr)

      ogr_err = FFI::GDAL.OSRExportToMICoordSys(@ogr_spatial_ref_pointer,
        return_ptr_ptr)

      return_ptr_ptr.get_array_of_string(0)
    end

    # @return [Hash]
    def to_pci
      proj = FFI::MemoryPointer.new(:string)
      proj_ptr = FFI::MemoryPointer.new(:pointer)
      proj_ptr.write_pointer(proj)

      units = FFI::MemoryPointer.new(:string)
      units_ptr = FFI::MemoryPointer.new(:pointer)
      units_ptr.write_pointer(units)

      prj_params = FFI::MemoryPointer.new(:double)
      prj_params_ptr = FFI::MemoryPointer.new(:pointer)
      prj_params_ptr.write_pointer(prj_params)

      ogr_err = FFI::GDAL.OSRExportToPCI(@ogr_spatial_ref_pointer, proj_ptr,
        units_ptr, prj_params_ptr)

      binding.pry
      {
        projection: proj_ptr.read_pointer.read_string,
        units: units_ptr.read_pointer.read_string,
        projection_parameters: prj_params_ptr.read_array_of_double(0)
      }
    end

    # @return [String]
    def to_proj4
      proj4 = FFI::MemoryPointer.new(:string)
      proj4_ptr = FFI::MemoryPointer.new(:pointer)
      proj4_ptr.write_pointer(proj4)

      ogr_err = FFI::GDAL.OSRExportToProj4(@ogr_spatial_ref_pointer, proj4_ptr)

      proj4_ptr.read_pointer.read_string
    end

    # @return [Hash]
    def to_usgs
      proj_sys = FFI::MemoryPointer.new(:long)
      zone = FFI::MemoryPointer.new(:long)
      datum = FFI::MemoryPointer.new(:long)
      prj_params = FFI::MemoryPointer.new(:double)
      prj_params_ptr = FFI::MemoryPointer.new(:pointer)
      prj_params_ptr.write_pointer(prj_params)

      ogr_err = FFI::GDAL.OSRExportToUSGS(@ogr_spatial_ref_pointer, proj_sys,
        zone, prj_params_ptr, datum)

      {
        projection_system_code: proj_sys.read_long,
        zone: zone.read_long,
        projection_parameters: prj_params_ptr.read_array_of_double(0),
        datum: datum.read_long
      }
    end

    # @return [String]
    def to_wkt
      wkt_ptr = FFI::MemoryPointer.new(:string)
      wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      wkt_ptr_ptr.write_pointer(wkt_ptr)

      ogr_err = FFI::GDAL.OSRExportToWkt(@ogr_spatial_ref_pointer, wkt_ptr_ptr)

      wkt_ptr_ptr.read_pointer.read_string
    end

    # @param simplify [Boolean] +true+ strips off +AXIS+, +AUTHORITY+ and
    #   +EXTENSION+ nodes.
    def to_pretty_wkt(simplify=false)
      wkt_ptr = FFI::MemoryPointer.new(:string)
      wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      wkt_ptr_ptr.write_pointer(wkt_ptr)

      ogr_err = FFI::GDAL.OSRExportToPrettyWkt(@ogr_spatial_ref_pointer,
        wkt_ptr_ptr, simplify)

      wkt_ptr_ptr.read_pointer.read_string
    end

    # @return [Hash]
    def to_xml
      xml_ptr = FFI::MemoryPointer.new(:string)
      xml_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      xml_ptr_ptr.write_pointer(xml_ptr)
      dialect = FFI::MemoryPointer.new(:string)

      ogr_err = FFI::GDAL.OSRExportToXML(@ogr_spatial_ref_pointer, xml_ptr_ptr,
        dialect)

      {
        dialect: dialect.read_string,
        xml: xml_ptr_ptr.get_array_of_string(0)
      }
    end

    # Converts, in place, to ESRI WKT format.
    def morph_to_esri!
      FFI::GDAL.OSRMorphToESRI(@ogr_spatial_ref_pointer)
    end

    # Converts, in place, from ESRI WKT format.
    def morph_from_esri!
      FFI::GDAL.OSRMorphFromESRI(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def geographic?
      FFI::GDAL.OSRIsGeographic(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def local?
      FFI::GDAL.OSRIsLocal(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def projected?
      FFI::GDAL.OSRIsProjected(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def compound?
      FFI::GDAL.OSRIsCompound(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def geocentric?
      FFI::GDAL.OSRIsGeocentric(@ogr_spatial_ref_pointer)
    end

    # @return [Boolean]
    def vertical?
      FFI::GDAL.OSRIsVertical(@ogr_spatial_ref_pointer)
    end

    # @param other_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    # @return [Boolean]
    def same?(other_spatial_ref)
      spatial_ref_ptr = GDAL._pointer(other_spatial_ref)

      FFI::GDAL.OSRIsSame(@ogr_spatial_ref_pointer, spatial_ref_ptr)
    end
    alias_method :==, :same?

    # @param other_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    # @return [Boolean]
    def geoccs_is_same?(other_spatial_ref)
      spatial_ref_ptr = GDAL._pointer(other_spatial_ref)

      FFI::GDAL.OSRIsSameGeogCS(@ogr_spatial_ref_pointer, spatial_ref_ptr)
    end

    # @param other_spatial_ref [OGR::SpatialReference, FFI::Pointer]
    # @return [Boolean]
    def vertcs_is_same?(other_spatial_ref)
      spatial_ref_ptr = GDAL._pointer(other_spatial_ref)

      FFI::GDAL.OSRIsSameVertCS(@ogr_spatial_ref_pointer, spatial_ref_ptr)
    end

    # @return [FFI::Pointer] Pointer to an OGRCreateCoordinateTransformation.
    def create_coordinate_transfomration(destination_spatial_ref)
      dest_ptr = GDAL._pointer(OGR::SpatialReference, destination_spatial_ref)

      FFI::GDAL.OGRCreateCoordinateTransformation(@ogr_spatial_ref_pointer, dest_ptr)
    end
  end
end
