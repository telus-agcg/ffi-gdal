# frozen_string_literal: true

require 'bindata'
require 'ffi-gdal'
require 'ogr'

module OGR
  module Geometry
    # Parses raw WKB and turns into a data structure. Only really exists for
    # converting to and from EWKB.
    #
    # @see {{OGR::Geometry::EWKBRecord}}
    class WKBRecord < BinData::Record
      uint8 :endianness, assert: -> { [0, 1].include?(value) }

      # Choose the type based on the endianness
      choice :wkb_type, selection: :endianness do
        uint32be 0
        uint32le 1
      end

      # Make sure the geometry_type is one OGR knows about.
      virtual assert: -> { FFI::OGR::Core::WKBGeometryType.symbol_map.value?(geometry_type) }

      # The #geometry attribute is just the rest of the data. We don't care what
      # kind of geom it actually is; that doesn't matter for building EWKB.
      rest :geometry

      WKB_Z = 0x8000_0000

      # @param ewkb_record [OGR::Geometry::EWKBRecord]
      # @return [OGR::Geometry::WKBRecord]
      def self.from_ewkb_record(ewkb_record)
        new(endianness: ewkb_record.endianness,
            wkb_type: ewkb_record.geometry_type,
            geometry: ewkb_record.geometry)
      end

      # @param ewkb_data [String] Binary string with the EWKB data.
      # @return [OGR::Geometry::WKBRecord]
      def self.from_ewkb(ewkb_data)
        from_ewkb_record(EWKBRecord.read(ewkb_data))
      end

      # @return [Boolean] Is the Z flag set?
      def has_z? # rubocop:disable Naming/PredicateName
        geometry_type & WKB_Z != 0
      end

      # @return [Fixnum] Enum number that matches the FFI::OGR::Core::WKBGeometryType.
      #   Defined to keep the API consistent with EWKBRecord.
      def geometry_type
        # ISO SQL/MM style Z types are between 1001 and 1007
        if wkb_type.value >= 1001 && wkb_type.value <= 1007
          raw_type_int = wkb_type.value - 1000
          raw_type_int | WKB_Z
        else
          wkb_type.value
        end
      end
    end
  end
end
