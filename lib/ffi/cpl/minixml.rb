require 'ffi'
# require_relative 'xml_node'

module FFI
  module CPL
    autoload :MiniXML, __FILE__
    autoload :XMLNode, File.expand_path('xml_node', __dir__)

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

      #-------------------------------------------------------------------------
      # Functions
      #-------------------------------------------------------------------------
      attach_function :CPLParseXMLString, %i[string], XMLNode.ptr
      attach_function :CPLDestroyXMLNode, [XMLNode.ptr], :void
      attach_function :CPLGetXMLNode, [XMLNode.ptr, :string], XMLNode.ptr
      attach_function :CPLSearchXMLNode, [XMLNode.ptr, :string], XMLNode.ptr
      attach_function :CPLGetXMLValue, [XMLNode.ptr, :string, :string], :string
      attach_function :CPLCreateXMLNode, [XMLNode.ptr, XMLNode.ptr, :string], XMLNode.ptr
      attach_function :CPLSerializeXMLTree, [XMLNode.ptr], :string
      attach_function :CPLAddXMLChild, [XMLNode.ptr, XMLNode.ptr], :void
      attach_function :CPLRemoveXMLChild, [XMLNode.ptr, XMLNode.ptr], :bool
      attach_function :CPLAddXMLSibling, [XMLNode.ptr, XMLNode.ptr], :void
      attach_function :CPLCreateXMLElementAndValue,
        [XMLNode.ptr, :string, :string],
        XMLNode.ptr
      attach_function :CPLCloneXMLTree, [XMLNode.ptr], XMLNode.ptr
      attach_function :CPLSetXMLValue, [XMLNode.ptr, :string, :string], :bool
      attach_function :CPLStripXMLNamespace, [XMLNode.ptr, :string, :bool], :void
      attach_function :CPLCleanXMLElementName, %i[string], :void
      attach_function :CPLParseXMLFile, %i[string], XMLNode.ptr
      attach_function :CPLSerializeXMLTreeToFile, [XMLNode.ptr, :string], :bool
    end
  end
end
