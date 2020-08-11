# frozen_string_literal: true

module OGR
  module SpatialReferenceMixins
    module Exporters
      # @return [Hash]
      # @raise [OGR::NotEnoughData] If name, datum name, and units are not set.
      def to_erm
        projection_name = FFI::MemoryPointer.new(:string)
        datum_name = FFI::MemoryPointer.new(:string)
        units = FFI::MemoryPointer.new(:string)

        ogr_err = FFI::OGR::SRSAPI.OSRExportToERM(@c_pointer, projection_name, datum_name, units)
        ogr_err.handle_result 'Required parameters (name, datum name, units) are not defined'

        {
          projection_name: projection_name.read_string,
          datum_name: datum_name.read_string,
          units: units.read_string
        }
      end

      # @return [Array<String>]
      def to_mapinfo
        return_ptr_ptr = GDAL._pointer_pointer(:string)
        ogr_err = FFI::OGR::SRSAPI.OSRExportToMICoordSys(@c_pointer, return_ptr_ptr)
        ogr_err.handle_result

        return_ptr_ptr.get_array_of_string(0)
      end

      # @return [Hash]
      def to_pci
        proj_ptr = GDAL._pointer_pointer(:string)
        units_ptr = GDAL._pointer_pointer(:string)
        prj_params_ptr = GDAL._pointer_pointer(:double)

        ogr_err = FFI::OGR::SRSAPI.OSRExportToPCI(@c_pointer, proj_ptr, units_ptr, prj_params_ptr)
        ogr_err.handle_result

        {
          projection: proj_ptr.read_pointer.read_string,
          units: units_ptr.read_pointer.read_string,
          projection_parameters: prj_params_ptr.read_array_of_double(0)
        }
      end

      # @return [String]
      # @raise [GDAL::UnsupportedOperation] If empty definition.
      def to_proj4
        proj4_ptr = GDAL._pointer_pointer(:string)
        ogr_err = FFI::OGR::SRSAPI.OSRExportToProj4(@c_pointer, proj4_ptr)
        ogr_err.handle_result

        GDAL._read_pointer_pointer_safely(proj4_ptr, :string)
      end

      # @return [Hash]
      def to_usgs
        proj_sys = FFI::MemoryPointer.new(:long)
        zone = FFI::MemoryPointer.new(:long)
        datum = FFI::MemoryPointer.new(:long)
        prj_params_ptr = GDAL._pointer_pointer(:double)

        ogr_err = FFI::OGR::SRSAPI.OSRExportToUSGS(@c_pointer, proj_sys, zone, prj_params_ptr, datum)
        ogr_err.handle_result

        {
          projection_system_code: proj_sys.read_long,
          zone: zone.read_long,
          projection_parameters: prj_params_ptr.read_array_of_double(0),
          datum: datum.read_long
        }
      end

      # @return [String]
      def to_wkt
        wkt_ptr_ptr = GDAL._pointer_pointer(:string)
        ogr_err = FFI::OGR::SRSAPI.OSRExportToWkt(@c_pointer, wkt_ptr_ptr)
        ogr_err.handle_result

        GDAL._read_pointer_pointer_safely(wkt_ptr_ptr, :string)
      end

      # @param simplify [Boolean] +true+ strips off +AXIS+, +AUTHORITY+ and
      #   +EXTENSION+ nodes.
      def to_pretty_wkt(simplify: false)
        wkt_ptr_ptr = GDAL._pointer_pointer(:string)
        ogr_err = FFI::OGR::SRSAPI.OSRExportToPrettyWkt(@c_pointer, wkt_ptr_ptr, simplify)
        ogr_err.handle_result

        GDAL._read_pointer_pointer_safely(wkt_ptr_ptr, :string)
      end

      # @return [String]
      def to_xml(dialect = nil)
        xml_ptr_ptr = GDAL._pointer_pointer(:string)
        ogr_err = FFI::OGR::SRSAPI.OSRExportToXML(@c_pointer, xml_ptr_ptr, dialect)
        ogr_err.handle_result

        xml_ptr_ptr.get_array_of_string(0).join
      end
    end
  end
end
