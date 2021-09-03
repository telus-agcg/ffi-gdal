# frozen_string_literal: true

module OGR
  class SpatialReference
    module CoordinateSystemGetterSetters
      # Set the user-visible LOCAL_CS name.
      #
      # @param name [String]
      # @raise [OGR::Failure]
      def set_local_cs(name) # rubocop:disable Naming/AccessorMethodName
        OGR::ErrorHandling.handle_ogr_err("Unable to set LOCAL_CS to '#{name}'") do
          FFI::OGR::SRSAPI.OSRSetLocalCS(@c_pointer, name)
        end
      end
      alias local_cs= set_local_cs

      # Set the user-visible PROJCS name.
      #
      # @param name [String]
      # @raise [OGR::Failure]
      def set_proj_cs(name) # rubocop:disable Naming/AccessorMethodName
        OGR::ErrorHandling.handle_ogr_err("Unable to set PROJCS to '#{name}'") do
          FFI::OGR::SRSAPI.OSRSetProjCS(@c_pointer, name)
        end
      end
      alias proj_cs= set_proj_cs

      # Set the user-visible PROJCS name.
      #
      # @param name [String]
      # @raise [OGR::Failure]
      def set_geoc_cs(name) # rubocop:disable Naming/AccessorMethodName
        OGR::ErrorHandling.handle_ogr_err("Unable to set GEOCCS to '#{name}'") do
          FFI::OGR::SRSAPI.OSRSetGeocCS(@c_pointer, name)
        end
      end
      alias geoc_cs= set_geoc_cs

      # Set the GEOGCS based on a well-known name.
      #
      # @param name [String]
      # @raise [OGR::Failure]
      def set_well_known_geog_cs(name) # rubocop:disable Naming/AccessorMethodName
        OGR::ErrorHandling.handle_ogr_err("Unable to set GEOGCS to '#{name}'") do
          FFI::OGR::SRSAPI.OSRSetWellKnownGeogCS(@c_pointer, name)
        end
      end
      alias well_known_geog_cs= set_well_known_geog_cs

      # @param definition [String]
      # @raise [OGR::Failure]
      def set_from_user_input(definition) # rubocop:disable Naming/AccessorMethodName
        OGR::ErrorHandling.handle_ogr_err('Invalid projection info given.') do
          FFI::OGR::SRSAPI.OSRSetFromUserInput(@c_pointer, definition)
        end
      end

      # @return [Array<Float>]
      # @raise [OGR::Failure]
      def towgs84
        coefficients = FFI::MemoryPointer.new(:double, 7)

        OGR::ErrorHandling.handle_ogr_err('No TOWGS84 node available') do
          FFI::OGR::SRSAPI.OSRGetTOWGS84(@c_pointer, coefficients, 7)
        end

        coefficients.get_array_of_double(0, 7)
      end

      # @param x_distance [Float] (In meters.)
      # @param y_distance [Float] (In meters.)
      # @param z_distance [Float] (In meters.)
      # @param x_rotation [Float] (In arc seconds.)
      # @param y_rotation [Float] (In arc seconds.)
      # @param z_rotation [Float] (In arc seconds.)
      # @param scaling_factor [Float] (In parts-per-million.)
      # @raise [OGR::Failure]
      def set_towgs84(x_distance: nil, y_distance: nil, z_distance: 0.0,
        x_rotation: 0.0, y_rotation: 0.0, z_rotation: 0.0, scaling_factor: 0.0)
        OGR::ErrorHandling.handle_ogr_err('No existing DATUM node') do
          FFI::OGR::SRSAPI.OSRSetTOWGS84(
            @c_pointer,
            x_distance, y_distance, z_distance,
            x_rotation, y_rotation, z_rotation,
            scaling_factor
          )
        end
      end

      # @param name [String]
      # @param horizontal_spatial_ref [OGR::SpatialReference] (a PROJCS or GEOGCS)
      # @param vertical_spatial_ref [OGR::SpatialReference] (a VERT_CS)
      # @raise [OGR::Failure]
      # @raise [FFI::GDAL::InvalidPointer]
      def set_compound_cs(name, horizontal_spatial_ref, vertical_spatial_ref)
        OGR::ErrorHandling.handle_ogr_err("Unable to set compound CS '#{name}'") do
          FFI::OGR::SRSAPI.OSRSetCompoundCS(
            @c_pointer,
            name,
            horizontal_spatial_ref.c_pointer,
            vertical_spatial_ref.c_pointer
          )
        end
      end

      # Set the geographic coordinate system.
      #
      # @param geog_name [String] User-visible name for the geographic
      #   coordinate system (not to serve as a key).
      # @param datum_name [String] key name for this datum. The OpenGIS
      #   specification lists some known values, and otherwise EPSG datum names
      #   with a standard transformation are considered legal keys.
      # @param spheroid_name [String] user-visible spheroid name (not to serve as a key).
      # @param semi_major [Float] the semi major axis of the spheroid.
      # @param spheroid_inverse_flattening [Float] the inverse flattening for the
      #   spheroid. This can be computed from the semi minor axis as
      #   1/f = 1.0 / (1.0 - semiminor/semimajor).
      # @param prime_meridian_name [String] The name of the prime meridian (not
      #   to serve as a key) If this is nil a default value of "Greenwich" will
      #   be used.
      # @param prime_meridian_offset [Float] the longitude of Greenwich relative to this prime
      #   meridian. Always in Degrees
      # @param angular_units_name [String] the angular units name (see
      #   OGR::SpatialReference for some standard names). If nil, a value of
      #   "degrees" will be assumed.
      # @param convert_to_radians [Float] value to multiply angular units by to
      #   transform them to radians. A value of SRS_UA_DEGREE_CONV will be used
      #   if angular_units_name is nil.
      # @raise [OGR::Failure]
      def set_geog_cs(geog_name, datum_name, spheroid_name, semi_major, spheroid_inverse_flattening,
        prime_meridian_name: nil, prime_meridian_offset: nil, angular_units_name: nil, convert_to_radians: nil)
        OGR::ErrorHandling.handle_ogr_err("Unable to set GEOGCS '#{geog_name}'") do
          FFI::OGR::SRSAPI.OSRSetGeogCS(
            @c_pointer,
            geog_name, datum_name, spheroid_name,
            semi_major, spheroid_inverse_flattening,
            prime_meridian_name, prime_meridian_offset,
            angular_units_name, convert_to_radians
          )
        end
      end

      # Set the vertical coordinate system.
      #
      # @param name [String] User-visible name of the CS.
      # @param datum_name [String] User-visible name of the datum.  It's helpful
      #   to have this match the EPSG name.
      # @param datum_type [Integer] The OGC datum type, usually 2005.
      # @raise [OGR::Failure]
      def set_vert_cs(name, datum_name, datum_type)
        OGR::ErrorHandling.handle_ogr_err("Unable to set vertical CS '#{name}'") do
          FFI::OGR::SRSAPI.OSRSetVertCS(@c_pointer, name, datum_name, datum_type)
        end
      end

      # @param return_wgs84_on_nil [Boolean] The C-API gives you the option to
      #   return the value for constant +SRS_WGS84_SEMIMAJOR+ (6378137.0) if no
      #   semi-major is found.  If set to +true+, this will return that value if
      #   the semi-major isn't found.
      # @return [Float]
      def semi_major(return_wgs84_on_nil: false)
        err_ptr = FFI::MemoryPointer.new(:int)
        value = FFI::OGR::SRSAPI.OSRGetSemiMajor(@c_pointer, err_ptr)
        ogr_err = FFI::OGR::Core::Err[err_ptr.read_int]
        wgs84_value = return_wgs84_on_nil ? value : nil

        ogr_err == :OGRERR_FAILURE ? wgs84_value : value
      end

      # @param return_wgs84_on_nil [Boolean] The C-API gives you the option to
      #   return the value for constant +SRS_WGS84_SEMIMAJOR+ (6378137.0) if no
      #   semi-major is found.  If set to +true+, this will return that value if
      #   the semi-major isn't found.
      # @return [Float]
      def semi_minor(return_wgs84_on_nil: false)
        err_ptr = FFI::MemoryPointer.new(:int)
        value = FFI::OGR::SRSAPI.OSRGetSemiMinor(@c_pointer, err_ptr)
        ogr_err = FFI::OGR::Core::Err[err_ptr.read_int]
        wgs84_value = return_wgs84_on_nil ? value : nil

        ogr_err == :OGRERR_FAILURE ? wgs84_value : value
      end

      # @param return_wgs84_on_nil [Boolean] The C-API gives you the option to
      #   return the value for constant +SRS_WGS84_INVFLATTENING+ (298.257223563)
      #   if no semi-major is found.  If set to +true+, this will return that
      #   value if the semi-major isn't found.
      # @return [Float]
      def spheroid_inverse_flattening(return_wgs84_on_nil: false)
        err_ptr = FFI::MemoryPointer.new(:int)
        value = FFI::OGR::SRSAPI.OSRGetInvFlattening(@c_pointer, err_ptr)
        ogr_err = FFI::OGR::Core::Err[err_ptr.read_int]
        wgs84_value = return_wgs84_on_nil ? value : nil

        ogr_err == :OGRERR_FAILURE ? wgs84_value : value
      end
      alias inv_flattening spheroid_inverse_flattening

      # @param target_key [String] The partial or complete path to the node to
      #   set an authority on ("PROJCS", "GEOGCS|UNIT").
      # @param authority [String] I.e. "EPSG".
      # @param code [Integer] Code value for the authority.
      # @raise [OGR::Failure]
      def set_authority(target_key, authority, code)
        OGR::ErrorHandling.handle_ogr_err("Unable to set authority: '#{target_key}', '#{authority}', '#{code}'") do
          FFI::OGR::SRSAPI.OSRSetAuthority(
            @c_pointer,
            target_key,
            authority,
            code
          )
        end
      end

      # Get the authority code for a node. This method is used to query an
      # AUTHORITY[] node from within the WKT tree, and fetch the code value.
      # While in theory values may be non-numeric, for the EPSG authority all
      # code values should be integral.
      #
      # @param target_key [String, nil] The partial or complete path to the node to get
      #   an authority from ("PROJCS", "GEOCS", "GEOCS|UNIT"). Leave empty to
      #   search at the root element.
      # @return [String, nil]
      def authority_code(target_key = nil)
        FFI::OGR::SRSAPI.OSRGetAuthorityCode(@c_pointer, target_key).freeze
      end

      # Get the authority name for a node. This method is used to query an
      # AUTHORITY[] node from within the WKT tree, and fetch the authority name
      # value. The most common authority is "EPSG".
      #
      # @param target_key [String, nil] The partial or complete path to the node to get
      #   an authority from ("PROJCS", "GEOCS", "GEOCS|UNIT").  Leave empty to
      #   search at the root element.
      # @return [String, nil]
      def authority_name(target_key = nil)
        FFI::OGR::SRSAPI.OSRGetAuthorityName(@c_pointer, target_key).freeze
      end

      # @param projection_name [String]
      # @raise [OGR::Failure]
      def set_projection(projection_name) # rubocop:disable Naming/AccessorMethodName
        OGR::ErrorHandling.handle_ogr_err("Unable to set projection to '#{projection_name}'") do
          FFI::OGR::SRSAPI.OSRSetProjection(@c_pointer, projection_name)
        end
      end
      alias projection= set_projection

      # @param param_name [String]
      # @param value [Float]
      # @raise [OGR::Failure]
      def set_projection_parameter(param_name, value)
        OGR::ErrorHandling.handle_ogr_err("Unable to set projection parameter '#{param_name}' to #{value}") do
          FFI::OGR::SRSAPI.OSRSetProjParm(@c_pointer, param_name, value)
        end
      end

      # @param name [String]
      # @param default_value [Float] The value to return if the parameter
      #   doesn't exist.
      # @raise [OGR::Failure]
      def projection_parameter(name, default_value: nil)
        value = nil

        OGR::ErrorHandling.handle_ogr_err("Unable to get projection parameter '#{name}'") do
          ogr_err_ptr = FFI::MemoryPointer.new(:int)
          value = FFI::OGR::SRSAPI.OSRGetProjParm(@c_pointer, name, default_value, ogr_err_ptr)
          ogr_err_int = ogr_err_ptr.null? ? 0 : ogr_err_ptr.read_int
          FFI::OGR::Core::Err[ogr_err_int]
        end

        value
      end

      # @param param_name [String]
      # @param value [Float]
      # @raise [OGR::Failure]
      def set_normalized_projection_parameter(param_name, value)
        msg = "Unable to set normalized projection parameter '#{param_name}' to '#{value}'"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRSetNormProjParm(@c_pointer, param_name, value)
        end
      end

      # @param name [String] Name of the parameter to fetch; must be from the
      #   set of SRS_PP codes in ogr_srs_api.h.
      # @param default_value [Float] The value to return if the parameter
      #   doesn't exist.
      # @raise [OGR::Failure]
      def normalized_projection_parameter(name, default_value: nil)
        value = nil

        OGR::ErrorHandling.handle_ogr_err("Unable to get projection parameter '#{name}'") do
          ogr_err_ptr = FFI::MemoryPointer.new(:int)
          FFI::OGR::SRSAPI.OSRGetNormProjParm(@c_pointer, name, default_value, ogr_err_ptr)
          ogr_err_int = ogr_err_ptr.null? ? 0 : ogr_err_ptr.read_int
          FFI::OGR::Core::Err[ogr_err_int]
        end

        value
      end

      # @param zone [Integer]
      # @param northern_hemisphere [Boolean] True for northern hemisphere, false for southern.
      # @raise [OGR::Failure]
      def set_utm(zone, northern_hemisphere:)
        msg = "Unable to set UTM to zome #{zone} (northern_hemisphere: #{northern_hemisphere})"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRSetUTM(@c_pointer, zone, northern_hemisphere)
        end
      end

      # @param is_northern_hemisphere [Boolean]
      # @return [Integer] The zone, or 0 if this isn't a UTM definition.
      def utm_zone(northern_hemisphere:)
        north_ptr = FFI::MemoryPointer.new(:bool)
        north_ptr.write(:bool, northern_hemisphere)

        FFI::OGR::SRSAPI.OSRGetUTMZone(@c_pointer, north_ptr)
      end

      # @param zone [Integer] State plane zone number (USGS numbering scheme).
      # @param use_nad83 [Boolean] Use NAD83 zone definition or not.
      # @param override_unit_name [String, nil] Linear u nit name to apply
      #   overriding the legal definition for this zone.
      # @param override_unit_conversion_factor [Float, nil] Linear unit
      #   conversion factor to apply overriding the legal definition for this
      #   zone.
      # @raise [OGR::Failure]
      def set_state_plane(zone, use_nad83: nil, override_unit_name: nil, override_unit_conversion_factor: nil)
        OGR::ErrorHandling.handle_ogr_err("Unable to set state plane to zone #{zone}") do
          FFI::OGR::SRSAPI.OSRSetStatePlaneWithUnits(
            @c_pointer,
            zone,
            use_nad83,
            override_unit_name,
            override_unit_conversion_factor
          )
        end
      end

      # @param axis_number [Integer] The Axis to query (0, 1, or 2)
      # @param target_key [String] 'GEOGCS' or 'PROJCS'.
      # @return [String, nil]
      def axis(axis_number, target_key)
        axis_orientation_ptr = FFI::MemoryPointer.new(:int)

        name = FFI::OGR::SRSAPI.OSRGetAxis(@c_pointer, target_key, axis_number, axis_orientation_ptr)
        ao_value = axis_orientation_ptr.read_int

        { name: name.freeze, orientation: FFI::OGR::SRSAPI::AxisOrientation[ao_value] }
      end

      # @param center_lat [Float]
      # @param center_long [Float]
      # @param scale [Float]
      # @param false_easting [Float]
      # @param false_northing [Float]
      # @raise [OGR::Failure]
      def set_transverse_mercator(center_lat, center_long, scale, false_easting, false_northing)
        msg = 'Unable to set transverse mercator: ' \
              "#{center_lat}, #{center_long}, #{scale}, #{false_easting}, #{false_northing}"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRSetTM(
            @c_pointer,
            center_lat, center_long,
            scale,
            false_easting, false_northing
          )
        end
      end
      alias set_tm set_transverse_mercator
    end
  end
end
