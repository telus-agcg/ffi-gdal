# frozen_string_literal: true

require "ogr"
require "ffi/extensions/rttopo"

module OGR
  module Geometry
    # Methods for {{OGR::Geometry}}s that use rttopo to operate on
    # themselves.
    #
    # @see http://postgis.net/docs/doxygen/2.1/da/de7/librttopo_8h_af8d208cf4c0bb7c9f96c75bddc6c498a.html#af8d208cf4c0bb7c9f96c75bddc6c498a
    module RttopoExtensions
      # Uses rttopo's make_valid to make the current geometry valid.
      #
      # @return [OGR::Geometry] Returns a new geometry, based on the
      #   rttopo_make_valid call.
      def make_valid
        ctx = FFI::Rttopo.rtgeom_init FFI::MemoryPointer::NULL, FFI::MemoryPointer::NULL, FFI::MemoryPointer::NULL
        geom = FFI::Rttopo.rtgeom_from_wkb(ctx, to_wkb, wkb_size, false)
        valid_geom = FFI::Rttopo.rtgeom_make_valid(ctx, geom)
        valid_wkb_size = FFI::MemoryPointer.new(:size_t)
        valid_wkb_ptr = FFI::Rttopo.rtgeom_to_wkb(ctx, valid_geom, FFI::Rttopo::RTWKB_EXTENDED, valid_wkb_size)
        valid_wkb = valid_wkb_ptr.read_bytes(valid_wkb_size.read_int)

        FFI::Rttopo.rtfree ctx, geom
        FFI::Rttopo.rtfree ctx, valid_geom
        FFI::Rttopo.rtfree ctx, valid_wkb_ptr
        FFI::Rttopo.rtgeom_finish ctx
        OGR::Geometry.create_from_wkb(valid_wkb)
      end
    end
  end
end

OGR::GeometryCollection25D.include(OGR::Geometry::RttopoExtensions)
OGR::LineString.include(OGR::Geometry::RttopoExtensions)
OGR::LineString25D.include(OGR::Geometry::RttopoExtensions)
OGR::LinearRing.include(OGR::Geometry::RttopoExtensions)
OGR::MultiLineString.include(OGR::Geometry::RttopoExtensions)
OGR::MultiLineString25D.include(OGR::Geometry::RttopoExtensions)
OGR::MultiPoint.include(OGR::Geometry::RttopoExtensions)
OGR::MultiPoint25D.include(OGR::Geometry::RttopoExtensions)
OGR::MultiPolygon.include(OGR::Geometry::RttopoExtensions)
OGR::MultiPolygon25D.include(OGR::Geometry::RttopoExtensions)
OGR::Point.include(OGR::Geometry::RttopoExtensions)
OGR::Point25D.include(OGR::Geometry::RttopoExtensions)
OGR::Polygon.include(OGR::Geometry::RttopoExtensions)
OGR::Polygon25D.include(OGR::Geometry::RttopoExtensions)
