# frozen_string_literal: true

require 'bindata'
require 'ffi-gdal'
require 'ogr'
require_relative 'wkb_record'

# rubocop:disable Naming/PredicateName
module OGR
  module Geometry
    # Parses raw EWKB and turns into a data structure. Only really exists for
    # converting to and from EWKB.
    #
    # @see http://trac.osgeo.org/postgis/browser/trunk/doc/ZMSgeoms.txt
    # @see {{OGR::Geometry::EWKBRecord}}
    class EWKBRecord < BinData::Record
      uint8 :endianness, assert: -> { [0, 1].include?(value) }

      # Choose the type based on the endianness.
      choice :wkb_type, selection: :endianness do
        uint32be 0
        uint32le 1
      end

      # Make sure the geometry_type is one OGR knows about.
      virtual assert: -> { FFI::OGR::Core::WKBGeometryType.symbol_map.value?(geometry_type) }

      # If the wkb_type has the SRID flag set, there's an SRID.
      choice :srid, onlyif: :has_srid?, selection: :endianness do
        uint32be 0
        uint32le 1
      end

      # The #geometry attribute is just the rest of the data. We don't care what
      # kind of geom it actually is; that doesn't matter for building EWKB.
      rest :geometry

      WKB_Z     = 0x8000_0000
      WKB_M     = 0x4000_0000
      WKB_SRID  = 0x2000_0000

      # @param wkb_record [OGR::Geometry::WKBRecord]
      # @param srid [Fixnum]
      # @return [OGR::Geometry::EWKBRecord]
      def self.from_wkb_record(wkb_record, srid = 0)
        ewkb_type_flag = if srid.zero?
                           wkb_record.wkb_type
                         else
                           (wkb_record.wkb_type | WKB_SRID)
                         end

        ewkb_type_flag |= WKB_Z if wkb_record.has_z?

        new(endianness: wkb_record.endianness,
            wkb_type: ewkb_type_flag,
            srid: srid,
            geometry: wkb_record.geometry)
      end

      # @return [Boolean] Is the Z flag set?
      def has_z?
        wkb_type & WKB_Z != 0
      end

      # @return [Boolean] Is the M flag set?
      def has_m?
        wkb_type & WKB_M != 0
      end

      # @return [Boolean] Is the SRID flag set?
      def has_srid?
        wkb_type & WKB_SRID != 0
      end

      # @return [Fixnum] Enum number that matches the FFI::OGR::Core::WKBGeometryType.
      def geometry_type
        type = wkb_type & 0x0fff_ffff

        has_z? ? (type | WKB_Z) : type
      end

      # @return [OGR::Geometry::WKBRecord]
      def to_wkb_record
        WKBRecord.from_ewkb_record(self)
      end

      # @return [String] WKB binary string.
      def to_wkb
        to_wkb_record.to_binary_s
      end
    end
  end
end
# rubocop:enable Naming/PredicateName
