require 'ffi'

module FFI
  module CPL
    module MiniXML
      extend ::FFI::Library
      ffi_lib [::FFI::CURRENT_PROCESS, ::FFI::GDAL.gdal_library_path]

      #-------------------------------------------------------------------------
      # Enums
      #-------------------------------------------------------------------------
      XMLNodeType = enum :CXT_Element, 0,
        :CXT_Text, 1,
        :CXT_Attribute, 2,
        :CXT_Comment, 3,
        :CXT_Literal, 4
    end
  end
end
