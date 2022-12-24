# frozen_string_literal: true

require 'ffi'

module FFI
  module Rttopo
    class GBOX < FFI::Struct
      layout :flags, :uint8,
             :xmin, :double,
             :xmax, :double,
             :ymin, :double,
             :ymax, :double,
             :zmin, :double,
             :zmax, :double,
             :mmin, :double,
             :mmax, :double
    end
  end
end
