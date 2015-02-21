require 'ffi'
require_relative '../cpl/conv'

module FFI
  module OGR
    class StyleParam < FFI::Struct
      layout :param, :int,
        :token, :string,
        :georef, FFI::CPL::Conv.find_type(:GBool),
        :type, FFI::OGR::Featurestyle::SType
    end
  end
end
