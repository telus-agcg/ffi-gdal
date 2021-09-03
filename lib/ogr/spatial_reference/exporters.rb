# frozen_string_literal: true

module OGR
  class SpatialReference
    module Exporters
      # @return [{ projection_name: String, datum_name: String, units: String }]
      # @raise [OGR::NotEnoughData] If name, datum name, and units are not set.
      def to_erm
        projection_name = FFI::Buffer.new_out(:string)
        datum_name = FFI::Buffer.new_out(:string)
        units = FFI::Buffer.new_out(:string)

        OGR::ErrorHandling.handle_ogr_err('Required parameters (name, datum name, units) are not defined') do
          FFI::OGR::SRSAPI.OSRExportToERM(@c_pointer, projection_name, datum_name, units)
        end

        {
          projection_name: projection_name.get_string(0),
          datum_name: datum_name.get_string(0),
          units: units.get_string(0)
        }
      end

      # @return [Array<String>]
      # @raise [OGR::Failure]
      def to_mapinfo
        GDAL._cpl_read_and_free_string do |return_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to MapInfo') do
            FFI::OGR::SRSAPI.OSRExportToMICoordSys(@c_pointer, return_ptr_ptr)
          end
        end
      end

      # @return [{ projection_system_code: Integer, datum: Integer, spheroid_code: Integer,
      #   zone: Integer, projection_parameters: Array<Float> }]
      # @raise [OGR::Failure]
      def to_panorama
        proj_buffer = FFI::Buffer.new_out(:long)
        datum_buffer = FFI::Buffer.new_out(:long)
        spheroid_code_buffer = FFI::Buffer.new_out(:long)
        zone_buffer = FFI::Buffer.new_out(:long)
        prj_params_ptr_ptr = GDAL._pointer_pointer(:double)
        prj_params_ptr_ptr.autorelease = false

        OGR::ErrorHandling.handle_ogr_err('Unable to export to Panorama') do
          FFI::OGR::SRSAPI.OSRExportToPanorama(@c_pointer, proj_buffer, datum_buffer, spheroid_code_buffer,
                                               zone_buffer, prj_params_ptr_ptr)
        end

        result = {
          projection_system_code: proj_buffer.read_long,
          datum: datum_buffer.read_long,
          spheroid_code: spheroid_code_buffer.read_long,
          zone: zone_buffer.read_long,
          projection_parameters: prj_params_ptr_ptr.read_array_of_double(0)
        }

        FFI::CPL::VSI.VSIFree(prj_params_ptr_ptr)

        result
      end

      # @return [{ projection_name: String, units: String, projection_parameters: Array<Float> }]
      # @raise [OGR::Failure]
      def to_pci
        proj_ptr_ptr = GDAL._pointer_pointer(:string)
        proj_ptr_ptr.autorelease = false
        units_ptr_ptr = GDAL._pointer_pointer(:string)
        units_ptr_ptr.autorelease = false
        prj_params_ptr_ptr = GDAL._pointer_pointer(:double)
        prj_params_ptr_ptr.autorelease = false

        OGR::ErrorHandling.handle_ogr_err('Unable to export to PCI') do
          FFI::OGR::SRSAPI.OSRExportToPCI(@c_pointer, proj_ptr_ptr, units_ptr_ptr, prj_params_ptr_ptr)
        end

        result = {
          projection_name: proj_ptr_ptr.read_pointer.read_string,
          units: units_ptr_ptr.read_pointer.read_string,
          projection_parameters: prj_params_ptr_ptr.read_array_of_double(0)
        }

        FFI::CPL::VSI.VSIFree(proj_ptr_ptr)
        FFI::CPL::VSI.VSIFree(units_ptr_ptr)
        FFI::CPL::VSI.VSIFree(prj_params_ptr_ptr)

        result
      end

      # @return [String]
      # @raise [GDAL::UnsupportedOperation] If empty definition.
      # @note Use of this function is discouraged. Its behavior in GDAL >= 3 / PROJ >= 6
      #   is significantly different from earlier versions. In particular +datum
      #   will only encode WGS84, NAD27 and NAD83, and +towgs84/+nadgrids terms
      #   will be missing most of the time. PROJ strings to encode CRS should be
      #   considered as a legacy solution. Using a AUTHORITY:CODE or WKT representation
      #   is the recommended way.
      def to_proj4
        GDAL._cpl_read_and_free_string do |proj4_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to PROJ.4') do
            FFI::OGR::SRSAPI.OSRExportToProj4(@c_pointer, proj4_ptr_ptr)
          end
        end
      end

      # @return [{ projection_system_code: Integer, zone: Integer, projection_parameters: Array<Float>,
      #   datum: Integer }]
      # @raise [OGR::Failure]
      def to_usgs
        proj_sys_ptr = FFI::Buffer.new_out(:long)
        zone_ptr = FFI::Buffer.new_out(:long)
        prj_params_ptr_ptr = GDAL._pointer_pointer(:double)
        prj_params_ptr_ptr.autorelease = false
        datum_ptr = FFI::Buffer.new_out(:long)

        OGR::ErrorHandling.handle_ogr_err('Unable to export to USGS GCTP') do
          FFI::OGR::SRSAPI.OSRExportToUSGS(@c_pointer, proj_sys_ptr, zone_ptr, prj_params_ptr_ptr, datum_ptr)
        end

        result = {
          projection_system_code: proj_sys_ptr.read_long,
          zone: zone_ptr.read_long,
          projection_parameters: prj_params_ptr_ptr.read_array_of_double(0),
          datum: datum_ptr.read_long
        }

        FFI::CPL::VSI.VSIFree(prj_params_ptr_ptr)

        result
      end

      # Convert this SRS into WKT 1 format.
      #
      # @return [String]
      # @raise [OGR::Failure]
      def to_wkt
        GDAL._cpl_read_and_free_string do |wkt_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to WKT') do
            FFI::OGR::SRSAPI.OSRExportToWkt(@c_pointer, wkt_ptr_ptr)
          end
        end
      end

      # Convert this SRS into a nicely formatted WKT 1 string for display to a
      # person.
      #
      # @param simplify [Boolean] +true+ strips off +AXIS+, +AUTHORITY+ and
      #   +EXTENSION+ nodes.
      # @raise [OGR::Failure]
      # @return [String]
      def to_pretty_wkt(simplify: false)
        GDAL._cpl_read_and_free_string do |wkt_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to pretty WKT') do
            FFI::OGR::SRSAPI.OSRExportToPrettyWkt(@c_pointer, wkt_ptr_ptr, simplify)
          end
        end
      end

      # Converts the loaded coordinate reference system into XML format to the
      # extent possible. LOCAL_CS coordinate systems are not translatable.
      #
      # @return [String]
      # @raise [OGR::Failure]
      def to_xml
        GDAL._cpl_read_and_free_string do |xml_ptr_ptr|
          OGR::ErrorHandling.handle_ogr_err('Unable to export to XML (GML)') do
            FFI::OGR::SRSAPI.OSRExportToXML(@c_pointer, xml_ptr_ptr, nil)
          end
        end
      end
      alias to_gml to_xml
    end
  end
end
