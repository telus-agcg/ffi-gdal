# frozen_string_literal: true

require 'ffi'
require_relative '../gdal'

module FFI
  module OGR
    module Featurestyle
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      #------------------------------------------------------------------------
      # Enums
      #------------------------------------------------------------------------
      StyleType = enum :OGRSTypeString,
                       :OGRSTypeDouble,
                       :OGRSTypeInteger,
                       :OGRSTypeBoolean

      #------------------------------------------------------------------------
      # Typedefs
      #------------------------------------------------------------------------
      SType = StyleType
      StyleParamId = FFI::OGR::StyleParam
    end
  end
end
