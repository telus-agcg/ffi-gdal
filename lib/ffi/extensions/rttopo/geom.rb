# frozen_string_literal: true

require 'ffi'
require_relative 'gbox'

module FFI
  module Rttopo
    class Geom < FFI::Struct
      layout :type, :uint8,
             :flags, :uint8,
             :bbox, GBOX.ptr,
             :srid, :int32,
             :data, :pointer
    end
  end
end
