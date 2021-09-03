# frozen_string_literal: true

require_relative '../error_handling'

module OGR
  class SpatialReference
    module Importers
      # @param code [Integer]
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
      def import_from_epsga(code)
        OGR::ErrorHandling.handle_ogr_err("Unable to import from EPSGA: #{code}") do
          FFI::OGR::SRSAPI.OSRImportFromEPSGA(@c_pointer, code)
        end

        self
      end

      # @param wkt [String]
      # @raise [OGR::Failure]
      def import_from_wkt(wkt)
        wkt_ptr = FFI::MemoryPointer.from_string(wkt)
        wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        wkt_ptr_ptr.write_pointer(wkt_ptr)

        OGR::ErrorHandling.handle_ogr_err("Unable to import from WKT: #{wkt}") do
          FFI::OGR::SRSAPI.OSRImportFromWkt(@c_pointer, wkt_ptr_ptr)
        end

        self
      end

      # @param proj4 [String]
      # @raise [OGR::Failure]
      def import_from_proj4(proj4)
        OGR::ErrorHandling.handle_ogr_err("Unable to import from PROJ.4: #{proj4}") do
          FFI::OGR::SRSAPI.OSRImportFromProj4(@c_pointer, proj4)
        end

        self
      end

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

      # @param proj [String]
      # @param units [String]
      # @param proj_params [Array<String>]
      # @raise [OGR::Failure]
      def import_from_pci(proj, units, *proj_params)
        if proj_params.empty?
          proj_ptr = nil
        else
          proj_ptr = FFI::MemoryPointer.new(:double, proj_params.size)
          proj_ptr.write_array_of_double(proj_params)
        end

        OGR::ErrorHandling.handle_ogr_err("Unable to import from PCI: #{proj}") do
          FFI::OGR::SRSAPI.OSRImportFromPCI(@c_pointer, proj, units, proj_ptr)
        end

        self
      end

      # @param projection_system_code [Integer]
      # @param zone [Integer]
      # @param datum [Integer]
      # @param proj_params [Array<Float>]
      # @raise [OGR::Failure]
      def import_from_usgs(projection_system_code, zone, datum, *proj_params)
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
