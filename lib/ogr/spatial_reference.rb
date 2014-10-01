require_relative '../ffi/ogr'

module OGR
  class SpatialReference
    include FFI::GDAL

    def initialize(wkt=nil, ogr_spatial_ref_pointer: nil)
      @ogr_spatial_ref_pointer = if ogr_spatial_ref_pointer
        ogr_spatial_ref_pointer
      else
        OSRNewSpatialReference(wkt)
      end
    end

    def c_pointer
      @ogr_spatial_ref_pointer
    end

    def validate
      OSRValidate(@ogr_spatial_ref_pointer)
    end

    def fixup_ordering!
      OSRFixupOrdering(@ogr_spatial_ref_pointer)
    end

    def fixup!
      OSRFixup(@ogr_spatial_ref_pointer)
    end

    def strip_ct_parameters!
      OSRStripCTParms(@ogr_spatial_ref_pointer)
    end

    def from_epsg(code)
      OSRImportFromEPSG(@ogr_spatial_ref_pointer, code)
    end

    def from_epsga(code)
      OSRImportFromEPSGA(@ogr_spatial_ref_pointer, code)
    end

    def from_erm(proj, datum, units)
      OSRImportFromERM(@ogr_spatial_ref_pointer, proj, datum, units)
    end

    # def from_esri(prj)
    #   @ogr_spatial_ref_pointer ||= FFI::MemoryPointer.new
    #
    #   OSRImportFromERM(@ogr_spatial_ref_pointer, proj, datum, units)
    # end

    def from_mapinfo(coord_sys)
      OSRImportFromMICoordSys(@ogr_spatial_ref_pointer, coord_sys)
    end

    def from_pci(proj, units, proj_params)
      OSRImportFromPCI(@ogr_spatial_ref_pointer, proj, units, proj_params)
    end

    def from_proj4(proj4)
      OSRImportFromProj4(@ogr_spatial_ref_pointer, proj4)
    end

    def from_url(url)
      OSRImportFromUrl(@ogr_spatial_ref_pointer, url)
    end

    def from_usgs(projsys, zone, proj_params, datum)
      OSRImportFromUSGS(@ogr_spatial_ref_pointer, projsys, zone, proj_params, datum)
    end

    def from_wkt(wkt)
      wkt_ptr = FFI::MemoryPointer.from_string(wkt)
      wkt_ptr_ptr = FFI::MemoryPointer.new(:pointer)
      wkt_ptr_ptr.write_pointer(wkt_ptr)

      OSRImportFromWkt(@ogr_spatial_ref_pointer, wkt_ptr_ptr)
    end

    def from_xml(xml)
      OSRImportFromXML(@ogr_spatial_ref_pointer, xml)
    end

    def geographic?
      OSRIsGeographic(@ogr_spatial_ref_pointer)
    end

    def local?
      OSRIsLocal(@ogr_spatial_ref_pointer)
    end

    def projected?
      OSRIsProjected(@ogr_spatial_ref_pointer)
    end

    def compound?
      OSRIsCompound(@ogr_spatial_ref_pointer)
    end

    def geocentric?
      OSRIsGeocentric(@ogr_spatial_ref_pointer)
    end

    def vertical?
      OSRIsVertical(@ogr_spatial_ref_pointer)
    end
  end
end
