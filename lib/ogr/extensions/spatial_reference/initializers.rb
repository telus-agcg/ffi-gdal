# frozen_string_literal: true

require 'ogr/spatial_reference'

module OGR
  module SpatialReferenceMixins
    module Initializers
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
        # @raise [OGR::Failure]
        def build_spatial_ref(spatial_reference_or_wkt = nil)
          object = new(spatial_reference_or_wkt)
          ogr_err = yield object.c_pointer

          OGR::ErrorHandling.handle_ogr_err('Unable to build SpatialReference') do
            ogr_err
          end

          object
        end
      end
    end
  end
end

OGR::SpatialReference.include(OGR::SpatialReferenceMixins::Initializers)
