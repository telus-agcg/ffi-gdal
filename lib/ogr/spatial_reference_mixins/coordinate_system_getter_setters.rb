# frozen_string_literal: true

module OGR
  module SpatialReferenceMixins
    module CoordinateSystemGetterSetters
      # Set the user-visible LOCAL_CS name.
      #
      # @param name [String]
      # @return +true+ if successful, otherwise raises an OGR exception.
      def set_local_cs(name) # rubocop:disable Naming/AccessorMethodName
        ogr_err = FFI::OGR::SRSAPI.OSRSetLocalCS(@c_pointer, name)

        ogr_err.handle_result
      end
      alias local_cs= set_local_cs

      # Set the user-visible PROJCS name.
      #
      # @param name [String]
      # @return +true+ if successful, otherwise raises an OGR exception.
      def set_proj_cs(name) # rubocop:disable Naming/AccessorMethodName
        ogr_err = FFI::OGR::SRSAPI.OSRSetProjCS(@c_pointer, name)

        ogr_err.handle_result
      end
      alias proj_cs= set_proj_cs

      # Set the user-visible PROJCS name.
      #
      # @param name [String]
      # @return +true+ if successful, otherwise raises an OGR exception.
      def set_geoc_cs(name) # rubocop:disable Naming/AccessorMethodName
        ogr_err = FFI::OGR::SRSAPI.OSRSetGeocCS(@c_pointer, name)

        ogr_err.handle_result
      end
      alias geoc_cs= set_geoc_cs

      # Set the GEOGCS based on a well-known name.
      #
      # @param name [String]
      # @return +true+ if successful, otherwise raises an OGR exception.
      # @raise [NotImplementedError] If your version of GDAL/OGR doesn't define
      #   the C function needed for this.
      def set_well_known_geog_cs(name) # rubocop:disable Naming/AccessorMethodName
        ogr_err = FFI::OGR::SRSAPI.OSRSetWellKnownGeogCS(@c_pointer, name)

        ogr_err.handle_result
      end
      alias well_known_geog_cs= set_well_known_geog_cs

      # @param definition [String]
      def set_from_user_input(definition) # rubocop:disable Naming/AccessorMethodName
        ogr_err = FFI::OGR::SRSAPI.OSRSetFromUserInput(@c_pointer, definition)

        ogr_err.handle_result 'Invalid projection info given.'
      end

      # @return [Array<Float>]
      def towgs84
        coefficients = FFI::MemoryPointer.new(:double, 7)
        ogr_err = FFI::OGR::SRSAPI.OSRGetTOWGS84(@c_pointer, coefficients, 7)
        ogr_err.handle_result

        coefficients.read_array_of_double(0)
      end

      # @param x_distance [Float] (In meters.)
      # @param y_distance [Float] (In meters.)
      # @param z_distance [Float] (In meters.)
      # @param x_rotation [Float] (In arc seconds.)
      # @param y_rotation [Float] (In arc seconds.)
      # @param z_rotation [Float] (In arc seconds.)
      # @param scaling_factor [Float] (In parts-per-million.)
      def set_towgs84(x_distance: nil, y_distance: nil, z_distance: nil,
        x_rotation: 0.0, y_rotation: 0.0, z_rotation: 0.0, scaling_factor: 0.0)
        ogr_err = FFI::OGR::SRSAPI.OSRSetTOWGS84(
          @c_pointer,
          x_distance, y_distance, z_distance,
          x_rotation, y_rotation, z_rotation,
          scaling_factor
        )

        ogr_err.handle_result
      end

      # @param name [String]
      # @param horizontal_spatial_ref [OGR::SpatialReference] (a PROJCS or GEOGCS)
      # @param vertical_spatial_ref [OGR::SpatialReference] (a VERT_CS)
      # @return [Boolean]
      def set_compound_cs(name, horizontal_spatial_ref, vertical_spatial_ref)
        horizontal_spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, horizontal_spatial_ref)
        vertical_spatial_ref_ptr = GDAL._pointer(OGR::SpatialReference, vertical_spatial_ref)

        ogr_err = FFI::OGR::SRSAPI.OSRSetCompoundCS(
          @c_pointer,
          name,
          horizontal_spatial_ref_ptr,
          vertical_spatial_ref_ptr
        )

        ogr_err.handle_result
      end

      # Set the user-visible GEOCCS name.
      #
      # @param [String] geog_name
      # @param [String] datum_name
      # @param [String] spheroid_name
      # @param [Float] semi_major
      # @param [Float] spheroid_inverse_flattening
      # @param [String] prime_meridian
      # @param [Double] offset
      # @param [String] angular_unit_label
      # @param [Float] transform_to_radians
      # @return +true+ if successful, otherwise raises an OGR exception.
      def set_geog_cs(geog_name, datum_name, spheroid_name, semi_major, spheroid_inverse_flattening,
        prime_meridian, offset, angular_unit_label, transform_to_radians)
        ogr_err = FFI::OGR::SRSAPI.OSRSetGeogCS(
          @c_pointer,
          geog_name, datum_name, spheroid_name,
          semi_major, spheroid_inverse_flattening,
          prime_meridian, offset,
          angular_unit_label, transform_to_radians
        )

        ogr_err.handle_result
      end

      # Set the vertical coordinate system.
      #
      # @param name [String] User-visible name of the CS.
      # @param datum_name [String] User-visible name of the datum.  It's helpful
      #   to have this match the EPSG name.
      # @param datum_type [String] The OGC datum type, usually 2005.
      def set_vert_cs(name, datum_name, datum_type)
        ogr_err = FFI::OGR::SRSAPI.OSRSetVertCS(@c_pointer, name, datum_name, datum_type)

        ogr_err.handle_result
      end

      # @param return_wgs84_on_nil [Boolean] The C-API gives you the option to
      #   return the value for constant +SRS_WGS84_SEMIMAJOR+ (6378137.0) if no
      #   semi-major is found.  If set to +true+, this will return that value if
      #   the semi-major isn't found.
      # @return [Float]
      def semi_major(return_wgs84_on_nil = false)
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
      def semi_minor(return_wgs84_on_nil = false)
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
      def spheroid_inverse_flattening(return_wgs84_on_nil = false)
        err_ptr = FFI::MemoryPointer.new(:int)
        value = FFI::OGR::SRSAPI.OSRGetInvFlattening(@c_pointer, err_ptr)
        ogr_err = FFI::OGR::Core::Err[err_ptr.read_int]
        wgs84_value = return_wgs84_on_nil ? value : nil

        ogr_err == :OGRERR_FAILURE ? wgs84_value : value
      end

      # @param target_key [String] The partial or complete path to the node to
      #   set an authority on ("PROJCS", "GEOGCS|UNIT").
      # @param authority [String] I.e. "EPSG".
      # @param code [Integer] Code value for the authority.
      def set_authority(target_key, authority, code)
        ogr_err = FFI::OGR::SRSAPI.OSRSetAuthority(
          @c_pointer,
          target_key,
          authority,
          code
        )

        ogr_err.handle_result
      end

      # @param target_key [String] The partial or complete path to the node to get
      #   an authority from ("PROJCS", "GEOCS", "GEOCS|UNIT").  Leave empty to
      #   search at the root element.
      # @return [String, nil]
      def authority_code(target_key = nil)
        FFI::OGR::SRSAPI.OSRGetAuthorityCode(@c_pointer, target_key)
      end

      # @param target_key [String] The partial or complete path to the node to get
      #   an authority from ("PROJCS", "GEOCS", "GEOCS|UNIT").  Leave empty to
      #   search at the root element.
      # @return [String, nil]
      def authority_name(target_key = nil)
        FFI::OGR::SRSAPI.OSRGetAuthorityName(@c_pointer, target_key)
      end

      # @param projection_name [String]
      # @return +true+ if successful, otherwise raises an OGR exception.
      def set_projection(projection_name) # rubocop:disable Naming/AccessorMethodName
        ogr_err = FFI::OGR::SRSAPI.OSRSetProjection(@c_pointer, projection_name)

        ogr_err.handle_result
      end
      alias projection= set_projection

      # @param param_name [String]
      # @param value [Float]
      def set_projection_parameter(param_name, value)
        ogr_err = FFI::OGR::SRSAPI.OSRSetProjParm(@c_pointer, param_name, value)

        ogr_err.handle_result
      end

      # @param name [String]
      # @param default_value [Float] The value to return if the parameter
      #   doesn't exist.
      def projection_parameter(name, default_value = 0.0)
        FFI::OGR::SRSAPI.OSRGetProjParm(@c_pointer, name, default_value, nil)
      end

      # @param param_name [String]
      # @param value [Float]
      def set_normalized_projection_parameter(param_name, value)
        ogr_err = FFI::OGR::SRSAPI.OSRSetNormProjParm(@c_pointer, param_name, value)

        ogr_err.handle_result
      end

      # @param name [String] Name of the parameter to fetch; must be from the
      #   set of SRS_PP codes in ogr_srs_api.h.
      # @param default_value [Float] The value to return if the parameter
      #   doesn't exist.
      def normalized_projection_parameter(name, default_value = 0.0)
        FFI::OGR::SRSAPI.OSRGetNormProjParm(@c_pointer, name, default_value, nil)
      end

      # @param zone [Integer]
      # @param north [Boolean] True for northern hemisphere, false for southern.
      def set_utm(zone, north)
        ogr_err = FFI::OGR::SRSAPI.OSRSetUTM(@c_pointer, zone, north)

        ogr_err.handle_result
      end

      # @param hemisphere [Symbol] :north or :south.
      # @return [Integer] The zone, or 0 if this isn't a UTM definition.
      def utm_zone(hemisphere = :north)
        north =
          case hemisphere
          when :north then 1
          when :south then 0
          else raise "Unknown hemisphere type #{hemisphere}. Please choose :north or :south."
          end
        north_ptr = FFI::MemoryPointer.new(:bool)
        north_ptr.write_bytes(north.to_s)

        FFI::OGR::SRSAPI.OSRGetUTMZone(@c_pointer, north_ptr)
      end

      # @param zone [Integer] State plane zone number (USGS numbering scheme).
      # @param nad83 [Boolean] Use NAD83 zone definition or not.
      def set_state_plane(zone, nad83 = true, override_unit_label = nil, override_unit_transform = 0.0)
        ogr_err = FFI::OGR::SRSAPI.OSRSetStatePlaneWithUnits(
          @c_pointer,
          zone,
          nad83,
          override_unit_label,
          override_unit_transform
        )

        ogr_err.handle_result
      end

      # @param axis_number [Integer] The Axis to query (0 or 1.)
      # @param target_key [String]
      # @return [String, nil]
      def axis(axis_number, target_key = nil)
        axis_orientation_ptr = FFI::MemoryPointer.new(:int)

        name = FFI::OGR::SRSAPI.OSRGetAxis(@c_pointer, target_key, axis_number, axis_orientation_ptr)
        ao_value = axis_orientation_ptr.read_int

        { name: name, orientation: AxisOrientation[ao_value] }
      end

      def set_albers_conic_equal_area
        raise NotImplementedError
      end
      alias set_acea set_albers_conic_equal_area

      def set_ae
        raise NotImplementedError
      end

      def set_bonne
        raise NotImplementedError
      end

      def set_cea
        raise NotImplementedError
      end

      def set_cs
        raise NotImplementedError
      end

      def set_ec
        raise NotImplementedError
      end

      def set_eckert
        raise NotImplementedError
      end

      def set_eckert_iv
        raise NotImplementedError
      end

      def set_eckert_vi
        raise NotImplementedError
      end

      def set_equirectangular
        raise NotImplementedError
      end

      def set_equirectangular2
        raise NotImplementedError
      end

      def set_gc
        raise NotImplementedError
      end

      def set_gh
        raise NotImplementedError
      end

      def set_igh
        raise NotImplementedError
      end

      def set_geos
        raise NotImplementedError
      end

      def set_gauss_schreiber_transverse_mercator
        raise NotImplementedError
      end

      def set_gnomonic
        raise NotImplementedError
      end

      def set_om
        raise NotImplementedError
      end

      def set_hom
        raise NotImplementedError
      end

      def set_hom_2_pno
        raise NotImplementedError
      end

      def set_iwm_polyconic
        raise NotImplementedError
      end

      def set_krovak
        raise NotImplementedError
      end

      def set_laea
        raise NotImplementedError
      end

      def set_lcc
        raise NotImplementedError
      end

      def set_lcc_1sp
        raise NotImplementedError
      end

      def set_lccb
        raise NotImplementedError
      end

      def set_mc
        raise NotImplementedError
      end

      def set_mercator
        raise NotImplementedError
      end

      def set_mollweide
        raise NotImplementedError
      end

      def set_nzmg
        raise NotImplementedError
      end

      def set_os
        raise NotImplementedError
      end

      def set_orthographic
        raise NotImplementedError
      end

      def set_polyconic
        raise NotImplementedError
      end

      def set_ps
        raise NotImplementedError
      end

      def set_robinson
        raise NotImplementedError
      end

      def set_sinusoidal
        raise NotImplementedError
      end

      def set_stereographic
        raise NotImplementedError
      end

      def set_soc
        raise NotImplementedError
      end

      # @param center_lat [Float]
      # @param center_long [Float]
      # @param scale [Float]
      # @param false_easting [Float]
      # @param false_northing [Float]
      def set_transverse_mercator(center_lat, center_long, scale, false_easting, false_northing)
        ogr_err = FFI::OGR::SRSAPI.OSRSetTM(
          @c_pointer,
          center_lat, center_long,
          scale,
          false_easting, false_northing
        )

        ogr_err.handle_result
      end
      alias set_tm set_transverse_mercator

      def set_tm_variant
        raise NotImplementedError
      end

      def set_tmg
        raise NotImplementedError
      end

      def set_tmso
        raise NotImplementedError
      end

      def set_vdg
        raise NotImplementedError
      end

      def set_wagner
        raise NotImplementedError
      end

      def set_qsc
        raise NotImplementedError
      end
    end
  end
end
