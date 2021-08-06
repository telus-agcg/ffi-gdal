# frozen_string_literal: true

require 'ffi'
require_relative '../gdal'

module FFI
  module CPL
    module MiniXML
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

      XMLNodeType = enum %i[CXT_Element CXT_Text CXT_Attribute CXT_Comment CXT_Literal]
    end
  end
end
