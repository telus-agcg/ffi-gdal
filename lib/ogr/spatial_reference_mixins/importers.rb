# frozen_string_literal: true

module OGR
  module SpatialReferenceMixins
    module Importers
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # @param code [Integer]
        # @return [OGR::SpatialReference]
        def new_from_epsg(code)
          srs = new
          srs.import_from_epsg(code)

          srs
        end

        # @param code [Integer]
        # @return [OGR::SpatialReference]
        def new_from_epsga(code)
          srs = new
          srs.import_from_epsga(code)

          srs
        end

        # @param projection_name [String] I.e. "NUTM11" or "GEOGRAPHIC".
        # @param datum_name [String] I.e. "NAD83".
        # @param linear_unit_name [String] Plural form of linear units, i.e. "FEET".
        # @return [OGR::SpatialReference]
        def new_from_erm(projection_name, datum_name, linear_unit_name)
          srs = new
          srs.import_from_erm(projection_name, datum_name, linear_unit_name)

          srs
        end

        # @param prj_text [Array<String>]
        # @return [OGR::SpatialReference]
        def new_from_esri(prj_text)
          srs = new
          srs.import_from_esri(prj_text)

          srs
        end

        # @param coord_sys [String] The Mapinfo style CoordSys definition string.
        # @return [OGR::SpatialReference]
        def new_from_mapinfo(coord_sys)
          srs = new
          srs.import_from_mapinfo(coord_sys)

          srs
        end

        # @param proj [String]
        # @param units [String]
        # @param proj_params [Array<String>]
        # @return [OGR::SpatialReference]
        def new_from_pci(proj, units, *proj_params)
          srs = new
          srs.import_from_pci(proj, units, *proj_params)

          srs
        end

        # @param proj4 [String]
        # @return [OGR::SpatialReference]
        def new_from_proj4(proj4)
          srs = new
          srs.import_from_proj4(proj4)

          srs
        end

        # @param url [String] URL to fetch the spatial reference from.
        # @return [OGR::SpatialReference]
        def new_from_url(url)
          srs = new
          srs.import_from_url(url)

          srs
        end

        # @param projection_system_code
        # @return [OGR::SpatialReference]
        def new_from_usgs(projection_system_code, zone, datum, *proj_params)
          srs = new
          srs.import_from_usgs(projection_system_code, zone, datum, *proj_params)

          srs
        end

        # This wipes the existing SRS definition and reassigns it based on the
        # contents of +wkt+.
        #
        # @param wkt [String]
        # @return [OGR::SpatialReference]
        def new_from_wkt(wkt)
          srs = new
          srs.import_from_wkt(wkt)

          srs
        end

        # Use for importing a GML coordinate system.
        #
        # @param xml [String]
        # @return [OGR::SpatialReference]
        def new_from_xml(xml)
          srs = new
          srs.import_from_xml(xml)

          srs
        end

        # @return [OGR::SpatialReference]
        def build_spatial_ref(spatial_reference_or_wkt = nil)
          object = new(spatial_reference_or_wkt)
          ogr_err = yield object.c_pointer
          ogr_err.handle_result

          object
        end
      end

      # @param code [Integer]
      # @raise [GDAL::UnsupportedOperation] On unknown EPSG code.
      def import_from_epsg(code)
        ogr_err = FFI::OGR::SRSAPI.OSRImportFromEPSG(@c_pointer, code)

        ogr_err.handle_result
      end

      # @param code [Integer]
      def import_from_epsga(code)
        ogr_err = FFI::OGR::SRSAPI.OSRImportFromEPSGA(@c_pointer, code)

        ogr_err.handle_result
      end

      # @param wkt [String]
      def import_from_wkt(wkt)
        wkt_ptr = FFI::MemoryPointer.from_string(wkt)
        wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        wkt_ptr_ptr.write_pointer(wkt_ptr)
        ogr_err = FFI::OGR::SRSAPI.OSRImportFromWkt(@c_pointer, wkt_ptr_ptr)

        ogr_err.handle_result
      end

      # @param proj4 [String]
      def import_from_proj4(proj4)
        ogr_err = FFI::OGR::SRSAPI.OSRImportFromProj4(@c_pointer, proj4)

        ogr_err.handle_result
      end

      # @param esri_text [Array<String>]
      def import_from_esri(esri_text)
        text_array = esri_text.split("\n")
        esri_ptr_ptr = GDAL._string_array_to_pointer(text_array)
        ogr_err = FFI::OGR::SRSAPI.OSRImportFromESRI(@c_pointer, esri_ptr_ptr)

        ogr_err.handle_result
      end

      # @param proj [String]
      # @param units [String]
      # @param proj_params [Array<String>]
      def import_from_pci(proj, units, *proj_params)
        if proj_params.empty?
          proj_ptr = nil
        else
          proj_ptr = FFI::MemoryPointer.new(:double, proj_params.size)
          proj_ptr.write_array_of_double(proj_params)
        end

        ogr_err = FFI::OGR::SRSAPI.OSRImportFromPCI(@c_pointer, proj, units, proj_ptr)

        ogr_err.handle_result
      end

      # @param projection_system_code [Integer]
      # @param zone [Integer]
      # @param datum [Integer]
      # @param proj_params [Array<Float>]
      def import_from_usgs(projection_system_code, zone, datum, *proj_params)
        if proj_params.empty?
          proj_ptr = nil
        else
          proj_ptr = FFI::MemoryPointer.new(:double, proj_params.size)
          proj_ptr.write_array_of_double(proj_params)
        end

        ogr_err = FFI::OGR::SRSAPI.OSRImportFromUSGS(
          @c_pointer,
          projection_system_code,
          zone,
          proj_ptr,
          datum
        )

        ogr_err.handle_result
      end

      # Use for importing a GML coordinate system.
      #
      # @param xml [String]
      def import_from_xml(xml)
        ogr_err = FFI::OGR::SRSAPI.OSRImportFromXML(@c_pointer, xml)

        ogr_err.handle_result
      end

      # @param coord_sys [String] The Mapinfo style CoordSys definition string.
      def import_from_mapinfo(coord_sys)
        ogr_err = FFI::OGR::SRSAPI.OSRImportFromMICoordSys(@c_pointer, coord_sys)

        ogr_err.handle_result
      end

      # @param projection_name [String] I.e. "NUTM11" or "GEOGRAPHIC".
      # @param datum_name [String] I.e. "NAD83".
      # @param linear_unit_name [String] Plural form of linear units, i.e. "FEET".
      def import_from_erm(projection_name, datum_name, linear_unit_name)
        ogr_err = FFI::OGR::SRSAPI.OSRImportFromERM(
          @c_pointer,
          projection_name,
          datum_name,
          linear_unit_name
        )

        ogr_err.handle_result
      end

      # @param url [String] URL to fetch the spatial reference from.
      def import_from_url(url)
        ogr_err = FFI::OGR::SRSAPI.OSRImportFromUrl(@c_pointer, url)

        ogr_err.handle_result
      end
    end
  end
end
