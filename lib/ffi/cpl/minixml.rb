# frozen_string_literal: true

require 'ffi'
require_relative '../../ext/ffi_library_function_checks'
require_relative '../gdal'

module FFI
  module CPL
    module MiniXML
      extend ::FFI::Library
      @ffi_libs = FFI::GDAL.loaded_ffi_libs

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
      attach_gdal_function :CPLParseXMLString, %i[string], CPL::XMLNode.ptr
      attach_gdal_function :CPLDestroyXMLNode, [CPL::XMLNode.ptr], :void
      attach_gdal_function :CPLGetXMLNode, [CPL::XMLNode.ptr, :string], CPL::XMLNode.ptr
      attach_gdal_function :CPLSearchXMLNode, [CPL::XMLNode.ptr, :string], CPL::XMLNode.ptr
      attach_gdal_function :CPLGetXMLValue, [CPL::XMLNode.ptr, :string, :string], :strptr
      attach_gdal_function :CPLCreateXMLNode, [CPL::XMLNode.ptr, CPL::XMLNode.ptr, :string], CPL::XMLNode.ptr
      attach_gdal_function :CPLSerializeXMLTree, [CPL::XMLNode.ptr], :string
      attach_gdal_function :CPLAddXMLChild, [CPL::XMLNode.ptr, CPL::XMLNode.ptr], :void
      attach_gdal_function :CPLRemoveXMLChild, [CPL::XMLNode.ptr, CPL::XMLNode.ptr], :bool
      attach_gdal_function :CPLAddXMLSibling, [CPL::XMLNode.ptr, CPL::XMLNode.ptr], :void
      attach_gdal_function :CPLCreateXMLElementAndValue,
                      [CPL::XMLNode.ptr, :string, :string],
                      CPL::XMLNode.ptr
      attach_gdal_function :CPLCloneXMLTree, [CPL::XMLNode.ptr], CPL::XMLNode.ptr
      attach_gdal_function :CPLSetXMLValue, [CPL::XMLNode.ptr, :string, :string], :bool
      attach_gdal_function :CPLStripXMLNamespace, [CPL::XMLNode.ptr, :string, :bool], :void
      attach_gdal_function :CPLCleanXMLElementName, %i[string], :void
      attach_gdal_function :CPLParseXMLFile, %i[string], CPL::XMLNode.ptr
      attach_gdal_function :CPLSerializeXMLTreeToFile, [CPL::XMLNode.ptr, :string], :bool
    end
  end
end
