# frozen_string_literal: true

require 'ffi-gdal'
require_relative 'rttopo/geom'

module FFI
  module Rttopo
    extend ::FFI::Library

    # @return [String]
    def self.rttopo_library_path
      @rttopo_library_path ||= ENV.fetch('RTTOPO_LIBRARY_PATH', 'rttopo')
    end

    if rttopo_library_path.nil? || rttopo_library_path.empty?
      raise FFI::GDAL::LibraryNotFound, "Can't find required rttopo library using path: '#{rttopo_library_path}'"
    end

    ffi_lib(rttopo_library_path)

    RTWKB_ISO       = 0x01
    RTWKB_SFSQL     = 0x02
    RTWKB_EXTENDED  = 0x04
    RTWKB_NDR       = 0x08
    RTWKB_XDR       = 0x10
    RTWKB_HEX       = 0x20

    RTWKT_ISO       = 0x01
    RTWKT_SFSQL     = 0x02
    RTWKT_EXTENDED  = 0x04

    attach_function :rtgeom_init, %i[pointer pointer pointer], :pointer
    attach_function :rtgeom_finish, [:pointer], :void
    attach_function :rtgeom_from_wkb, %i[pointer pointer size_t bool], Geom.ptr
    attach_function :rtgeom_to_wkt, [:pointer, Geom.ptr, :uint8, :int, :pointer], :pointer
    attach_function :rtgeom_to_wkb, [:pointer, Geom.ptr, :uint8, :pointer], :pointer
    attach_function :rtfree, %i[pointer pointer], :void

    attach_function :rtgeom_make_valid, [:pointer, Geom.ptr], Geom.ptr
  end
end
