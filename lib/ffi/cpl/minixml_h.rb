module FFI
  module GDAL
    #--------------------------------------------------------------------------
    # Enums
    #--------------------------------------------------------------------------
    CPLXMLNodeType = enum :CXT_Element, 0,
      :CXT_Text, 1,
      :CXT_Attribute, 2,
      :CXT_Comment, 3,
      :CXT_Literal, 4
  end
end

require_relative 'xml_node'
