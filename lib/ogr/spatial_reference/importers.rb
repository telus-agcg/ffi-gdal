# frozen_string_literal: true

require_relative '../error_handling'

module OGR
  class SpatialReference
    module Importers
      # @param code [Integer] EPSG geographic, projected or vertical CRS code.
      # @return [OGR::SpatialReference] `self`, but updated with the EPSG code.
      # @raise [GDAL::UnsupportedOperation] On unknown EPSG code.
      def import_from_epsg(code)
        OGR::ErrorHandling.handle_ogr_err("Unable to import from EPSG: #{code}") do
          FFI::OGR::SRSAPI.OSRImportFromEPSG(@c_pointer, code)
        end

        self
      end

      # @param code [Integer]
      # @raise [OGR::Failure]
      # @note Since GDAL 3.0, this method is identical to #import_from_epsg.
      def import_from_epsga(code)
        OGR::ErrorHandling.handle_ogr_err("Unable to import from EPSGA: #{code}") do
          FFI::OGR::SRSAPI.OSRImportFromEPSGA(@c_pointer, code)
        end

        self
      end

      # @param wkt [String]
      # @raise [OGR::Failure]
      def import_from_wkt(wkt)
        wkt_ptr = FFI::Buffer.new_in(:string)
        wkt_ptr.put_string(0, wkt)

        wkt_ptr_ptr = FFI::Buffer.new_in(:pointer)
        wkt_ptr_ptr.write_pointer(wkt_ptr)

        OGR::ErrorHandling.handle_ogr_err("Unable to import from WKT: #{wkt}") do
          FFI::OGR::SRSAPI.OSRImportFromWkt(@c_pointer, wkt_ptr_ptr)
        end

        self
      end

      # The SpatialReference is updated from the given PROJ-style coordinate system string.
      #
      # Example: pszProj4 = "+proj=utm +zone=11 +datum=WGS84"
      #
      # It is also possible to import "+init=epsg:n" style definitions.
      #
      # @param proj4 [String]
      # @raise [OGR::Failure]
      def import_from_proj4(proj4)
        OGR::ErrorHandling.handle_ogr_err("Unable to import from PROJ.4: #{proj4}") do
          FFI::OGR::SRSAPI.OSRImportFromProj4(@c_pointer, proj4)
        end

        self
      end

      # Import coordinate system from ESRI .prj format(s).
      #
      # This function will read the text loaded from an ESRI .prj file, and translate
      # it into an OGRSpatialReference definition. This should support many (but
      # by no means all) old style (Arc/Info 7.x) .prj files, as well as the newer
      # pseudo-OGC WKT .prj files. Note that new style .prj files are in OGC WKT
      # format, but require some manipulation to correct datum names, and units
      # on some projection parameters. This is addressed within #import_from_esri
      # by an automatic call to #morph_from_esri
      #
      # Currently only GEOGRAPHIC, UTM, STATEPLANE, GREATBRITIAN_GRID, ALBERS,
      # EQUIDISTANT_CONIC, TRANSVERSE (mercator), POLAR, MERCATOR and POLYCONIC
      # projections are supported from old style files.
      #
      # At this time there is no equivalent #to_esri method. Writing old style
      # .prj files is not supported by SpatialReference. However the #morph_to_esri
      # and #to_wkt methods can be used to generate output suitable to write to
      # new style (Arc 8) .prj files.
      #
      # @param esri_text [Array<String>]
      # @raise [OGR::Failure]
      def import_from_esri(esri_text)
        text_array = esri_text.split("\n")
        esri_ptr_ptr = GDAL._string_array_to_pointer(text_array)

        OGR::ErrorHandling.handle_ogr_err("Unable to import from ESRI: #{esri_text}") do
          FFI::OGR::SRSAPI.OSRImportFromESRI(@c_pointer, esri_ptr_ptr)
        end

        self
      end

      # PCI software uses 16-character string to specify coordinate system and
      # datum/ellipsoid. You should supply at least this string here.
      #
      # @param projection_string [String] String containing the definition. Looks
      #   like "pppppppppppp Ennn" or "pppppppppppp Dnnn", where "pppppppppppp"
      #   is a projection code, "Ennn" is an ellipsoid code, "Dnnn" a datum code.
      # @param units [String, nil] Grid units code "DEGREE" or "METRE"). If nil,
      #   "METRE" will be used.
      # @param proj_params [Array<String>] Array of 17 coordinate system parameters.
      #   Particular projections use different parameters; unused ones may be set
      #   to zero. If nil is supplied instead of an array, default values will
      #   be used (i.e., zeroes). Params are:
      #   [0] Spheroid semi major axis
      #   [1] Spheroid semi minor axis
      #   [2] Reference Longitude
      #   [3] Reference Latitude
      #   [4] First Standard Parallel
      #   [5] Second Standard Parallel
      #   [6] False Easting
      #   [7] False Northing
      #   [8] Scale Factor
      #   [9] Height above sphere surface
      #   [10] Longitude of 1st point on center line
      #   [11] Latitude of 1st point on center line
      #   [12] Longitude of 2nd point on center line
      #   [13] Latitude of 2nd point on center line
      #   [14] Azimuth east of north for center line
      #   [15] Landsat satellite number
      #   [16] Landsat path number
      # @raise [OGR::Failure]
      def import_from_pci(projection_string, units, proj_params = nil)
        if proj_params.empty?
          proj_ptr = nil
        else
          proj_ptr = FFI::MemoryPointer.new(:double, proj_params.size)
          proj_ptr.write_array_of_double(proj_params)
        end

        OGR::ErrorHandling.handle_ogr_err("Unable to import from PCI: #{projection_string}") do
          FFI::OGR::SRSAPI.OSRImportFromPCI(@c_pointer, projection_string, units, proj_ptr)
        end

        self
      end

      # @param projection_system_code [Integer] Input projection system code, used in GCTP.
      # @param zone [Integer] Input zone for UTM and State Plane projection systems.
      #   For Southern Hemisphere UTM use a negative zone code; ignored for all
      #   other projections.
      # @param datum [Integer] Input spheroid.
      # @param proj_params [Array<Float>] Array of 15 coordinate system parameters.
      #   These parameters differ for different projections.
      # @raise [OGR::Failure]
      # @see https://gdal.org/api/ogrspatialref.html#classOGRSpatialReference_1a4a971615901e5c4a028e6b49fb5918d9
      def import_from_usgs(projection_system_code, zone, datum, proj_params)
        if proj_params.empty?
          proj_ptr = nil
        else
          proj_ptr = FFI::MemoryPointer.new(:double, proj_params.size)
          proj_ptr.write_array_of_double(proj_params)
        end

        msg = "Unable to import from USGS: #{projection_system_code}, #{zone}, #{datum}, #{proj_params}"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRImportFromUSGS(
            @c_pointer,
            projection_system_code,
            zone,
            proj_ptr,
            datum
          )
        end

        self
      end

      # Import coordinate system from "Panorama" GIS projection definition.
      #
      # @param projection_system_code [Integer]
      # @param datum [Integer] Input coordinate system.
      # @param spheroid [Integer]
      # @param proj_params [Array<Float>] Array of 8 coordinate system parameters.
      #   These parameters differ for different projections.
      # @see https://gdal.org/api/ogrspatialref.html#_CPPv4N19OGRSpatialReference18importFromPanoramaElllPd
      def import_from_panorama(projection_system_code, datum, spheroid, proj_params)
        if proj_params.empty?
          proj_params_ptr = nil
        else
          proj_params_ptr = FFI::MemoryPointer.new(:double, proj_params.size)
          proj_params_ptr.write_array_of_double(proj_params)
        end

        msg = "Unable to import from Panorama: #{projection_system_code}, #{datum}, #{spheroid}, #{proj_params}"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRImportFromPanorama(
            @c_pointer,
            projection_system_code,
            datum,
            spheroid,
            proj_params_ptr
          )
        end

        self
      end

      # Read SRS from a WKT dictionary. This method will attempt to find the indicated
      # coordinate system identity in the indicated dictionary file. If found, the
      # WKT representation is imported and used to initialize this SpatialReference.
      #
      # @param dictionary_file_path [String]
      # @param dictionary_lookup_code [String]
      # @raise [OGR::Failure]
      def import_from_dict(dictionary_file_path, dictionary_lookup_code)
        OGR::ErrorHandling.handle_ogr_err("Unable to import from WKT dictionary: #{dictionary_file_path}") do
          FFI::OGR::SRSAPI.OSRImportFromDict(@c_pointer, dictionary_file_path, dictionary_lookup_code)
        end

        self
      end

      # Import coordinate system from OziExplorer projection definition.
      #
      # @param map_file_lines [Array<String>] This is an array of strings
      #   containing the whole OziExplorer .MAP file.
      # @raise [OGR::Failure]
      def import_from_ozi(map_file_lines)
        array_ptr = GDAL._string_array_to_pointer(map_file_lines)

        OGR::ErrorHandling.handle_ogr_err('Unable to import from Ozi .map file') do
          FFI::OGR::SRSAPI.OSRImportFromOzi(@c_pointer, array_ptr)
        end

        self
      end

      # Use for importing a GML coordinate system.
      #
      # @param xml [String]
      # @raise [OGR::Failure]
      def import_from_xml(xml)
        OGR::ErrorHandling.handle_ogr_err("Unable to import from XML: #{xml}") do
          FFI::OGR::SRSAPI.OSRImportFromXML(@c_pointer, xml)
        end

        self
      end

      # @param coord_sys [String] The Mapinfo style CoordSys definition string.
      # @raise [OGR::Failure]
      def import_from_mapinfo(coord_sys)
        OGR::ErrorHandling.handle_ogr_err("Unable to import from MapInfo: #{coord_sys}") do
          FFI::OGR::SRSAPI.OSRImportFromMICoordSys(@c_pointer, coord_sys)
        end

        self
      end

      # @param projection_name [String] I.e. "NUTM11" or "GEOGRAPHIC".
      # @param datum_name [String] I.e. "NAD83".
      # @param linear_unit_name [String] Plural form of linear units, i.e. "FEET".
      # @raise [OGR::Failure]
      def import_from_erm(projection_name, datum_name, linear_unit_name)
        msg = "Unable to import from ERMapper: #{projection_name}, #{datum_name}, #{linear_unit_name}"

        OGR::ErrorHandling.handle_ogr_err(msg) do
          FFI::OGR::SRSAPI.OSRImportFromERM(
            @c_pointer,
            projection_name,
            datum_name,
            linear_unit_name
          )
        end

        self
      end

      # @param url [String] URL to fetch the spatial reference from.
      # @raise [OGR::Failure]
      def import_from_url(url)
        OGR::ErrorHandling.handle_ogr_err("Unable to import from URL: #{url}") do
          FFI::OGR::SRSAPI.OSRImportFromUrl(@c_pointer, url)
        end

        self
      end
    end
  end
end
