module OGR
  module SpatialReferenceMixins
    module Exporters
      # @return [Hash]
      # @raise [OGR::NotEnoughData] If name, datum name, and units are not set.
      def to_erm
        projection_name = FFI::MemoryPointer.new(:string)
        datum_name = FFI::MemoryPointer.new(:string)
        units = FFI::MemoryPointer.new(:string)

        ogr_err = FFI::GDAL.OSRExportToERM(@ogr_spatial_ref_pointer, projection_name,
          datum_name, units)
        ogr_err.handle_result 'Required parameters (name, datum name, units) are not defined'

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
        ogr_err.handle_result

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
        proj4 = FFI::MemoryPointer.new(:string)
        proj4_ptr = FFI::MemoryPointer.new(:pointer)
        proj4_ptr.write_pointer(proj4)

        ogr_err = FFI::GDAL.OSRExportToProj4(@ogr_spatial_ref_pointer, proj4_ptr)
        ogr_err.handle_result

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
        wkt_ptr = FFI::MemoryPointer.new(:string)
        wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        wkt_ptr_ptr.write_pointer(wkt_ptr)

        ogr_err = FFI::GDAL.OSRExportToWkt(@ogr_spatial_ref_pointer, wkt_ptr_ptr)
        ogr_err.handle_result

        wkt_ptr_ptr.read_pointer.read_string
      end

      # @param simplify [Boolean] +true+ strips off +AXIS+, +AUTHORITY+ and
      #   +EXTENSION+ nodes.
      def to_pretty_wkt(simplify = false)
        wkt_ptr = FFI::MemoryPointer.new(:string)
        wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        wkt_ptr_ptr.write_pointer(wkt_ptr)

        ogr_err = FFI::GDAL.OSRExportToPrettyWkt(@ogr_spatial_ref_pointer,
          wkt_ptr_ptr, simplify)
        ogr_err.handle_result

        wkt_ptr_ptr.read_pointer.read_string
      end

      # @return [Hash]
      def to_xml(dialect = nil)
        xml_ptr = FFI::MemoryPointer.new(:string)
        xml_ptr_ptr = FFI::MemoryPointer.new(:pointer)
        xml_ptr_ptr.write_pointer(xml_ptr)

        ogr_err = FFI::GDAL.OSRExportToXML(@ogr_spatial_ref_pointer, xml_ptr_ptr,
          dialect)
        ogr_err.handle_result

        xml_ptr_ptr.get_array_of_string(0)
      end
    end
  end
end
