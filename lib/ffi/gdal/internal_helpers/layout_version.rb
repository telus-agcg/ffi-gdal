# frozen_string_literal: true

module FFI
  module GDAL
    module InternalHelpers
      LayoutVersion = ::Struct.new(:version, :layout, keyword_init: true)
    end
  end
end
