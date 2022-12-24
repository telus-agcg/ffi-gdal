# frozen_string_literal: true

require 'ogr/spatial_reference'
require_relative 'ewkb_record'
require_relative 'wkb_record'

module OGR
  module Geometry
    # Extends OGR::Geometry with methods that allow creating a Geometry from
    # EKWB or outputting a Geometry as EWKB (EWKB is the WKB format that PostGIS
    # uses).
    module EWKBIOExtensions
      # Methods to extend OGR::Geometry with.
      module ClassMethods
        # @param ewkb_data [String] Binary EWKB string.
        # @param [OGR::Geometry]
        def create_from_ewkb(ewkb_data)
          e = EWKBRecord.read(ewkb_data)

          if e.srid?
            spatial_ref = OGR::SpatialReference.new.import_from_epsg(e.srid)
            create_from_wkb(e.to_wkb, spatial_ref)
          else
            create_from_wkb(e.to_wkb)
          end
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

      # @return [String] Binary string representative of EWKB.
      def to_ewkb
        wkb_record = WKBRecord.read(to_wkb)
        srid = spatial_reference ? spatial_reference.authority_code.to_i : 0

        EWKBRecord.from_wkb_record(wkb_record, srid).to_binary_s
      end
    end
  end
end

OGR::Geometry.include OGR::Geometry::EWKBIOExtensions
