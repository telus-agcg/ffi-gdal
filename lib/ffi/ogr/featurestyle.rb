require 'ffi'

module FFI
  module OGR
    autoload :StyleParam,
      File.expand_path('style_param', __dir__)
    autoload :StyleValue,
      File.expand_path('style_value', __dir__)

    module Featurestyle
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

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
