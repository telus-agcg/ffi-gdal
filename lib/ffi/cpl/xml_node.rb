require 'ffi'
require_relative 'minixml_h'

module FFI
  module GDAL
    class CPLXMLNode < FFI::Struct
      layout :type, CPLXMLNodeType,
        :value, :string,
        :next, CPLXMLNode.ptr,
        :child, CPLXMLNode.ptr
    end
  end
end
