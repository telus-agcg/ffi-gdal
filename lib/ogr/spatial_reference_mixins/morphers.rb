module OGR
  module SpatialReferenceMixins
    module Morphers
      # Converts, in place, to ESRI WKT format.
      #
      # @return [OGR::SpatialReference, false] If successful, returns self.
      def morph_to_esri!
        ogr_err = FFI::OGR::SRSAPI.OSRMorphToESRI(@ogr_spatial_ref_pointer)
        result = ogr_err.handle_result

        result ? self : result
      end

      # Converts, in place, from ESRI WKT format.
      #
      # @return [OGR::SpatialReference, false] If successful, returns self.
      def morph_from_esri!
        ogr_err = FFI::OGR::SRSAPI.OSRMorphFromESRI(@ogr_spatial_ref_pointer)
        result = ogr_err.handle_result

        result ? self : result
      end
    end
  end
end
